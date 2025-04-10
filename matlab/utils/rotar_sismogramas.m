function [EWrot,NSrot] = rotar_sismogramas(ESTR,teta,Narch)

for p = 1:Narch
    EWrot{p,1} = ESTR.EW{p}*cosd(teta)+ESTR.NS{p}*sind(teta);  %longitudinal
    NSrot{p,1} =-ESTR.EW{p}*sind(teta)+ESTR.NS{p}*cosd(teta);  %transversal
end
