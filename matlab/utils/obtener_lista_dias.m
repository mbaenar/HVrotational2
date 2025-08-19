function [listdias,listdiashoras] = obtener_lista_dias(listreg,NdiasHV)

listdias00 = [];
for i = 1:length(listreg)
    listdias00{i,1} = listreg{i}(1:8);
end
listdias = unique(listdias00);

if length(listdias) < NdiasHV; NdiasHV = length(listdias); end
diaini = (1:NdiasHV:length(listdias)).';
if diaini(end)+NdiasHV-1 > numel(listdias)
    diaini(end) = [];
end

listdiashoras = [];
for i = 1:length(diaini)
    dia1 = diaini(i);
    dia2 = dia1+NdiasHV-1;
    listdiash = [];
    for j = dia1:dia2
        listdiash = [listdiash;listreg(ismember(listdias00,listdias{j}))];
    end
    listdiashoras{i,1} = strrep(listdiash,'.mat','');
    [dia1 dia2 dia2-dia1+1];
end
