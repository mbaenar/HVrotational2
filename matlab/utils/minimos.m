function [aa,bb] = minimos(SIG,band) %,Nmax
if band == 1 || band == -1
    SIGband = band*SIG;
elseif band == 2
    SIGband = abs(SIG);
end    
    
cont = 0;
for i = 2:length(SIGband)-1
    if SIGband(i) <= SIGband(i-1) && SIGband(i) < SIGband(i+1)
        if SIGband(i) > 0
            cont = cont+1;
            aa(cont,1) = SIG(i);
            bb(cont,1) = i;
        end
    end
end
if ~exist('aa','var'); aa = NaN; bb = 1; end
% cc = [aa bb];
% cc = flipud(sortrows(cc,1));
% cc = cc(1:Nmax,:);
% aa = cc(:,1);
% bb = cc(:,2);
