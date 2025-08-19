function [EWrot,NSrot] = rotar_sismogramas(EW,NS,teta)

for p = 1:length(EW)
    EWrot{p,1} = EW{p}*cosd(teta)+NS{p}*sind(teta);  %longitudinal
    NSrot{p,1} =-EW{p}*sind(teta)+NS{p}*cosd(teta);  %transversal
end
