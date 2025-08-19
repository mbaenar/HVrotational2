function [diahoraselec,horariograb] = selecdiahora(fmthora,vecfechahms,hora,horario)

% Formato de hora
if strcmp(fmthora,'MXN')
    hrini = 7;
    hrfin = 24;
elseif strcmp(fmthora,'GMT')
    hrini = 5;
    hrfin = 11;
end

diahoraselec = vecfechahms;
horariograb = horario;
if horariograb == 1
    if strcmp(fmthora,'MXN'); diahoraselec = vecfechahms( and(hora>=hrini,hora<=hrfin)); end
    if strcmp(fmthora,'GMT'); diahoraselec = vecfechahms(~and(hora>=hrini,hora<=hrfin)); end
elseif horariograb == 2
    if strcmp(fmthora,'MXN'); diahoraselec = vecfechahms(~and(hora>=hrini,hora<=hrfin)); end
    if strcmp(fmthora,'GMT'); diahoraselec = vecfechahms( and(hora>=hrini,hora<=hrfin)); end
end
if isempty(diahoraselec)
    horariograb = 1;
    if strcmp(fmthora,'MXN'); diahoraselec = vecfechahms( and(hora>=hrini,hora<=hrfin)); end
    if strcmp(fmthora,'GMT'); diahoraselec = vecfechahms(~and(hora>=hrini,hora<=hrfin)); end
end
