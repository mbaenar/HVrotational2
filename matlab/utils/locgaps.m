% Localización de gaps -------------------
function [grsig,grgap] = locgaps(data,dt)

% Localización NaN y ceros
% locnan0 = ~isnan(data).*~(data==0);
locnan0 = ~(data==0);
locnan = find(locnan0==0);
grgap = {};
mindat = length(data);
grsig = {1:mindat};
if ~isempty(locnan)
    Nlocnan = length(locnan);
    gap = locnan(2:end)-locnan(1:end-1);
    ngap = gap<=1;
    cont = 0;
    k = 1;
    while k <= Nlocnan-1
        if ngap(k) == 1
            cont = cont+1;
            v = [];
            while ngap(k) == 1
                v = [v k];
                k = k+1;
                if k > Nlocnan-1; break; end
            end
            grgap(cont,1) = {locnan([v,v(end)+1])};
        end
        k = k+1;
    end
    borrargrgap = [];
    for i = 1:length(grgap)
        if length(grgap{i}) <= 3
            borrargrgap = [borrargrgap;i];
        end 
    end
    grgap(borrargrgap) = [];
    if ~isempty(grgap)
        for gg = 1:length(grgap)+1
            if gg == 1; grsig(gg,1) = {1:grgap{gg}(1)-1}; end
            if gg > 1 && gg < length(grgap)+1; grsig(gg,1) = {grgap{gg-1}(end)+1:grgap{gg}(1)-1}; end
            if gg == length(grgap)+1; grsig(gg,1) = {grgap{gg-1}(end)+1:mindat}; end
        end
        borrargrsig = [];
        for gg = 1:length(grsig)
            if length(grsig{gg})*dt/60 < 5; borrargrsig = [borrargrsig;gg]; end
        end
        grsig(borrargrsig) = [];
    end
end
