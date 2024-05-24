function [ q ,trial_idx_ses,subject_ves,joint_ves,dim_sims,projs] = dr_into_joint_subspace( p,av_trials,err_trials,trans_data,n_pcs)


    %% split trials into dr and dc per session (needed for VE per ses analysis)
    % take half for DR and half for DC     
    % structure: sub /  ses / (av|err|t) / (dr|dc)
    
    trial_idx_ses = {};
    for sub = 1:p.nSubjects    
        for ses = 1:p.nSessions
            this_sample = randperm(size(av_trials{sub,ses},3));
            n_dr = floor(length(this_sample)/2);
            trial_idx_ses{sub,ses,1,1} = this_sample(1:n_dr);
            trial_idx_ses{sub,ses,1,2} = this_sample(n_dr+1:end);
            
            if isempty(err_trials{sub,ses})
                trial_idx_ses{sub,ses,2,1} = [];
                trial_idx_ses{sub,ses,2,2} = [];
            else
                this_sample = randperm(size(err_trials{sub,ses},3));
                n_dr = floor(length(this_sample)/2);
                trial_idx_ses{sub,ses,2,1} = this_sample(1:n_dr);
                trial_idx_ses{sub,ses,2,2} = this_sample(n_dr+1:end);
            end
        end
    end

    %% pool trials into tasks
    % also do overall pooling of task indices here. we need task specific
    % indices first for building task-specific trial averages. later we
    % pool trials overall, which requires trial indices over all trials
    
    task_sessions{1} = 3:4;
    task_sessions{2} = 5:9;
    trial_idx = {};
    for sub = 1:p.nSubjects    
        for t = 1:2
            task_trials_av{sub,t} = cat(3,av_trials{sub,task_sessions{t}});
            task_trials_err{sub,t} = cat(3,err_trials{sub,task_sessions{t}});
            task_trials_trans{sub,t} = cat(3,trans_data{sub,task_sessions{t}});
            
            for i = 1:2 % av/err
                for j = 1:2 %dr/dc
                    % since the ses indices relate to trials per session, we need to successively add number of trials
                    % from previous sessions such that the indices make sense globally
                    add_idx = 0; 
                    trial_idx{sub,t,i,j} = [];
                    for ses = task_sessions{t}
                        this_idx = trial_idx_ses{sub,ses,i,j};
                        this_idx = this_idx + add_idx;
                        % get the number of trials (dr + dc trials)
                        n_trials = length(trial_idx_ses{sub,ses,i,1}) + length(trial_idx_ses{sub,ses,i,2});
                        add_idx = add_idx+n_trials;
                        % concat
                        trial_idx{sub,t,i,j} = cat(2,trial_idx{sub,t,i,j},this_idx);
                    end
                end
            end
        end
    end

    
    %% prepare data for DR
    % calc trial avs per subject and task  
    t_avs = {};
    for sub = 1:p.nSubjects        
        for t = 1:2
            t_avs{sub,t,1} = squeeze(nanmean(task_trials_av{sub,t}(:,:,trial_idx{sub,t,1,1}),3));
            t_avs{sub,t,2} = squeeze(nanmean(task_trials_err{sub,t}(:,:,trial_idx{sub,t,2,1}),3));
            t_avs{sub,t,3} = squeeze(nanmean(task_trials_trans{sub,t},3));
        end
    end
    
    % cat subjects and normalize (mean subtract and normalize with Frobenius norm)
    t_avs_cat = {};
    for t = 1:2
        for c = 1:3
            this_cat = cat(1,t_avs{:,t,c});
            this_cat = this_cat - mean(this_cat,2);
            this_cat = this_cat./norm(this_cat,'fro');
            t_avs_cat{c,t} = this_cat;
        end
    end

    y = cat(2,t_avs_cat{:});
    
    %% recreate y without normalization for quantification below
    t_avs_cat_no_norm = {};
    for t = 1:2
        for c = 1:3
            this_cat = cat(1,t_avs{:,t,c});
            t_avs_cat_no_norm{c,t} = this_cat;
        end
    end
    y_no_norm = cat(2,t_avs_cat_no_norm{:});
    
    %% do DR
    % following the notation af Ani's paper:
    % y: joint neural activities
    % u: all coeffs from SVD
    % u_i: coeffs per subject
    % q: orthogonalized coeffs per subject 

    % do pca
    [u,s,v] = svd(y);

    full_coeff = u;
    
    % split up into subjects
    q = {};
    start_idx = 1;
    cell_idx = {};
    for sub = 1:p.nSubjects
        % figure out indices of cells for this sub
        n_cells = size(av_trials{sub},1);
        cell_idx{sub} = start_idx:start_idx+n_cells-1;
        start_idx = start_idx+n_cells;
        
        u_i = u(cell_idx{sub},1:n_pcs);
        [Q,R] = qr(u_i);
        q{sub} = Q(:,1:n_pcs);

        % qr decomposition flips some sings -> flip back
        ccs = [];
        for pc = 1:n_pcs
            cc = corrcoef(u_i(:,pc),q{sub}(:,pc));
            ccs(pc) = cc(1,2);
            if cc(1,2) < 0
                q{sub}(:,pc) = -q{sub}(:,pc);
            end
        end
    end       

    
    %% CONTROL: run PCA individually and save weigths
    q_individual = {};
    for sub = 1:p.nSubjects
        this_y = y(cell_idx{sub},:);
        [u,s,v] = svd(this_y);
        q_individual{sub} = u(:,1:n_pcs);
        
        % align sign of weigths such that q and q_ind have positive corr
        ccs = [];
        for pc = 1:n_pcs
            cc = corrcoef(q_individual{sub}(:,pc),q{sub}(:,pc));
            ccs(pc) = cc(1,2);
            if cc(1,2) < 0
                q_individual{sub}(:,pc) = -q_individual{sub}(:,pc);
            end
        end
    end
    
    %% CONTROL: shuffle time steps for every subject to destroy alignment info
    q_shuffle = {};
    y_shuffle = y;
    y_shuffle_no_norm = y_no_norm;

    % first shuffle time steps for all cells belonging to one subject
    for sub = 1:p.nSubjects
        rand_idx = randperm(size(y,2));
        
        blocks = {1:40,41:80,81:120,121:160,161:200,201:240};
        rand_idx_block = randperm(6);
        rand_idx = cat(2,blocks{rand_idx_block});
        
        y_shuffle(cell_idx{sub},:) = y(cell_idx{sub},rand_idx);
        y_shuffle_no_norm(cell_idx{sub},:) = y_no_norm(cell_idx{sub},rand_idx);
    end
    
    % then run joint PCA and QR as above
    [u,s,v] = svd(y_shuffle);
    full_coeff_shuffle = u;

    for sub = 1:p.nSubjects
        u_i = u(cell_idx{sub},1:n_pcs);
        [Q,R] = qr(u_i);
        q_shuffle{sub} = Q(:,1:n_pcs);

        % qr decomposition flips some sings -> flip back
        ccs = [];
        for pc = 1:n_pcs
            cc = corrcoef(u_i(:,pc),q_shuffle{sub}(:,pc));
            ccs(pc) = cc(1,2);
            if cc(1,2) < 0
                q_shuffle{sub}(:,pc) = -q_shuffle{sub}(:,pc);
            end
        end
    end       
   
    
    %% calculate VE for individual subjects 
    % for these 3 settings:
    % PCA + QR
    % individual PCA (upper limit)
    % Shuffle PCA + QR (lower limit)
    
    for i = 1:3
        if i == 1 % normal
            this_y = y;
            this_q = q;
        elseif i == 2 % individual control
            this_y = y;
            this_q = q_individual;
        elseif i == 3 % shuffle control
            this_y = y_shuffle;
            this_q = q_shuffle;    
        end
        
        for sub = 1:p.nSubjects
            org = this_y(cell_idx{sub},:);
            for pc = 1:n_pcs
                rec = (org' * this_q{sub}(:,pc) * this_q{sub}(:,pc)')';
                ve_sub(i,sub,pc) = 100*(1 - norm(org-rec,'fro')^2  / norm(org,'fro')^2);
            end
        end
    end
    
    subject_ves = cumsum(squeeze(mean(ve_sub,2))');

    %% calculate VE overall (compare normal and shuffle, individual is not defined)
    for i = 1:2
        if i == 1 % normal
            org = y;
            this_u = full_coeff;
        else % shuffle control
            org = y_shuffle; 
            this_u = full_coeff_shuffle;
        end
        
        for pc = 1:n_pcs
            rec = (org' * this_u(:,pc) * this_u(:,pc)')';
            ve_full(i,pc) = 100*(1 - norm(org-rec,'fro')^2  / norm(org,'fro')^2);
        end
    end

    joint_ves = cumsum(ve_full');

    %% calculate dimension similarity (all 3 q_s)
    dim_sims = [];
    for i = 1:3
         
        if i == 1 % normal
            this_y = y_no_norm;
            this_q = q;
        elseif i == 2 % individual control
            this_y = y_no_norm;
            this_q = q_individual;
        else % shuffle control
            this_y = y_shuffle_no_norm;
            this_q = q_shuffle;
        end
            
        % calc cc between different PCs for all sub combinations
        cc_all_comb = [];
        for pc1 = 1:n_pcs
            for pc2 = 1:n_pcs
                n_comb = 1;
                for sub1 = 1:p.nSubjects
                    sub1_pc = this_y(cell_idx{sub1},:)' * this_q{sub1}(:,pc1);
                    for sub2 = sub1+1:p.nSubjects
                        sub2_pc = this_y(cell_idx{sub2},:)' * this_q{sub2}(:,pc2);
                        cc = corrcoef(sub1_pc,sub2_pc);
                        cc_all_comb(pc1,pc2,n_comb) = cc(1,2);
                        n_comb = n_comb+1;
                    end
                end
            end
        end
        dim_sims = cat(3,dim_sims,mean(cc_all_comb,3));
    end
   
    
    %% calculate PCA-QR projections for all subs 
    % (for plotting projections and example of dims-sim measure)
    % actual dim-sim is calculated above for all 3 cases (PCA-QR and 2 controls)
    
    projs = [];
    for sub = 1:p.nSubjects
        projs(sub,:,:) = y_no_norm(cell_idx{sub},:)' * q{sub};
    end
        
    
end

