function bv = addQuadrant(bv)

    qs = zeros(1,length(bv));
    for i = 1:length(bv)
        qs(i) = get_quadrant(bv(1:2,i));
    end

    bv = cat(1,bv,qs);
end