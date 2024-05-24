function p = params_2DAA(varargin)

    %% set paths for reproducing analysis / plots here
    % folder containing the results of data processing (signal extraction etc.)
    p.processed_data_dir = 'C:\Users\Benjamin Ehret\Desktop\paper_data_final\processed_data'; 
    % folder containing the results of data analyses
    p.data_dir = 'C:\Users\Benjamin Ehret\Desktop\paper_data_final\plot_data'; 
    % folder containing all final plots
    p.out_dir = 'C:\Users\Benjamin Ehret\Desktop\paper_data_final\plots';

    %% general experiment settings
    % used for processing of raw data
    p.experimentName = '2DAA';
    p.rootDir = 'G:\';
    p.resultsDir = fullfile('G:','SRM_results'); 

    p.subjects = [2 3 5 6 7 8 9 10 11 12 13 14];
    p.good_subs = [1:12];
    
    if isempty(varargin)
        p.sessions = 1:11;
    else
        p.subjects = p.subjects(varargin{1});
        p.sessions = varargin{2};
    end
    
    p.rootDir = fullfile(p.rootDir,'E7_2DAA');
    p.nSubjects = length(p.subjects);
    p.nSessions = length(p.sessions);
    p.rawDataRootDir = 'D:\E1_miniscope_concat';

    p.alignment.refDay = 6;
    p.alignment.verifiedSubjects = [2 3 5 6 7 8 9 10 11 12 13 14]; 
    p.alignment.miniscopeFocus = [8 10 12 11 7 10 10 10 6 8 8 10];
    
    % ALIGNMENT ISSUES
    % some sessions can not be properly aligned -> exclude from analysis
    % sub 4 / thisSub 6: 10 11 completely different: exclude, maybe also 9
    % sub 6 / thisSub 8: 11 completely different: exclude, maybe also 10
    % sub 8 / thisSub 10: shift in ses 8 that stays until the end
    % sub 9 / thisSub 11: big shift ses 11, slight shift in 9,10: exclude 11, tolerate 9,10
    
    p.alignment.exclude = cell(p.nSubjects,1); 
    p.alignment.exclude{4} = [10,11];
    p.alignment.exclude{6} = [11];
    p.alignment.exclude{8} = [8:11];
    p.alignment.exclude{9} = [11];
    % this is handled as follows:
    % joint extraction is performed only on data from properly aligned
    % sessions. the traces of sessions that were not properly aligned are
    % set to nan at the end of applyFiltersJoint. 
    
    p.PCAICA.approximateExtraction.flag = 1;
    p.PCAICA.approximateExtraction.window = [3001 9000];    
    
    % in joint extraction, we use an individual number of ICs per subject
    % estimated through interaction with the data from single session
    % extraction
    p.PCAICA.individual.nICs = [600 450 400 500 400 600 500 600 600 600 600 600];
    p.PCAICA.individual.nPCs = p.PCAICA.individual.nICs * 1.2;


    %% miniscope preprocessing

    % parallel processing can significantly speed up preprocessing. 
    % The number of workers that run in parallel depends on your machine.  
    % At the moment this is only used in preprocessing (registerMovie). 
    p.useParallelProcessing = 1;
    p.numWorkers = 10;
    
    % data organization
    p.rawData_fileType = 'tif';
    p.downsampleSpace.factor = 2;
    p.downsampleSpace.secondaryDownsampleType = 'bilinear';
    p.rawData_dataType = 'uint16';
    
    % filtering
    p.filtering.lowpassFreq = 7; % see preprocessing/testFilters for exploring different values
    
    % turboreg
    p.turboreg.options.RegisType=1; % 1 is only translation, see turboreg website for other types
    p.turboreg.options.SmoothX=10;
    p.turboreg.options.SmoothY=10;
    p.turboreg.options.minGain=0.0;
    p.turboreg.options.Levels=4; 
    p.turboreg.options.Lastlevels=1;
    p.turboreg.options.Epsilon=1.192092896E-07;
    p.turboreg.options.zapMean=0;
    p.turboreg.options.Interp='bilinear';
    
    p.turboreg.refFrame = 100;
    p.turboreg.bandpassFreqs = [30 80]; % see preprocessing/testFilters for exploring different values
    p.turboreg.selectROI = 0;
    p.turboreg.ROI = [100 100 300 300];
    
    % downsample time
    % we record at 20 FPS and downsample to 5
    p.frameRateRaw = 20;
    p.downsampleTime.secondaryDownsampleType = 'bilinear';
    p.downsampleTime.factor = 4; 
    p.frameRate = p.frameRateRaw / p.downsampleTime.factor;
    
	%% signal extraction
    
    % PCA ICA
    p.PCAICA.mu = 0.1;
    p.PCAICA.term_tol = 1e-5;
    p.PCAICA.max_iter = 750;
    p.PCAICA.nPCs = 800;
    p.PCAICA.nICs = 600;    
    
    % this option is used for large data sets where the number of frames
    % becomes too big (nFrame^2 cov matrix in PCA). window specifies the
    % frames to use per session in joint extraction
    p.PCAICA.approximateExtraction.flag = 0;
    p.PCAICA.approximateExtraction.window = [3001 9000];
    
    %% annotation

    % areaThrsh can be used to exclude cells with small area 
    % (e.g. < 30 pixels for us) from annotation to save time. 
    % You have to check what value is appropriate for your recordings 
    p.annotation.areaThresh = 0; 
    
    % this values are used to detect peaks in the activity trace (only used
    % for annotation)
    p.annotation.numStdsForThresh = 3;
    p.annotation.minTimeBtwEvents = 10;
    
    %% behavior analysis

    p.behavior.smoothingWindow = 10;
    p.behavior.smoothingMethod = 'moving'; 
    p.behavior.frzThreshold = 5;

    p.n_iti_trans = 10;
    p.n_iti_rand = 21;

end

