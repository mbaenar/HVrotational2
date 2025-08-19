function files = trescanales(rutaarch,estac0)

sep = obtener_separador_linux_window();

% lista de carpetas dentro de cada estación
rutadatos = [rutaarch,estac0];
listarchcarp = dir(rutadatos);
listarchcarp = {listarchcarp.name}';
if strcmp(listarchcarp{1},'.') && strcmp(listarchcarp{2},'..')
    listarchcarp(1:2) = [];
end
%------------------
cont = 0;
carpetas = {};
carpetas(1,1) = {rutadatos};
for i = 1:length(listarchcarp)
    if isfolder([rutadatos,sep,listarchcarp{i}])
        cont = cont+1;
        carptemp = [rutadatos,sep,listarchcarp{i}];
        carpetas(cont+1,1) = {carptemp};
        %------------------
        listarchcarp2 = dir(carptemp).';
        listarchcarp2 = {listarchcarp2.name}';
        if strcmp(listarchcarp2{1},'.') && strcmp(listarchcarp2{2},'..')
            listarchcarp2(1:2) = [];
        end
        for j = 1:length(listarchcarp2)
            if isfolder([rutadatos,sep,listarchcarp{i},sep,listarchcarp2{j}])
                cont = cont+1;
                carptemp = [rutadatos,sep,listarchcarp{i},sep,listarchcarp2{j}];
                carpetas(cont+1,1) = {carptemp};
            end
        end
        %------------------
    end
end
%------------------
listregtot = {};
listfoldertot = {};
for i = 1:length(carpetas)
    listreg0 = dir(carpetas{i});
    bal = cell2mat({listreg0.isdir}');
    listreg = [{listreg0(~bal).folder};{listreg0(~bal).name}].';
    listreg = join(listreg,sep);
    listfolder = {listreg0(~bal).folder}.';
    listregtot = [listregtot;listreg];
end
bal = contains(listregtot,'#');
listregtot(bal) = [];
%------------------
longpatnum = [];
for i = 1:length(listregtot)
    ind = strfind(listregtot{i},sep);
    patnum(i,1) = {str2double(extract(listregtot{i}(ind(end)+1:end),digitsPattern)).'};
    longpatnum(i,1) = length(patnum{i,1});
end
uniqlong = unique(longpatnum);
%------------------
fileslongpatnum = {};
for i = 1:length(uniqlong)
    fileslongpatnum(i,1) = {find(longpatnum==uniqlong(i))};
end
%------------------
files = {};
filesNO = {};
cont = 0;
cont3 = 0;
for i = 1:length(fileslongpatnum)
    num = fileslongpatnum{i};
    patnum2 = cell2mat(patnum(num));
    listregtot2 = listregtot(num);

    while ~isempty(patnum2)
        resta = patnum2(1,:)-patnum2;
        ceros = sum(abs(resta),2);
        [tot,~] = find(ceros==0);
        if length(tot) >= 3
            cont = cont+1;
            files(cont,1) = {listregtot2(tot,:)};
        else
            ceros = sum(abs(resta(:,1:end-1)),2);
            [tot,~] = find(and(ceros==0,abs(resta(:,end))<=1));
            if length(tot) >= 3
                cont = cont+1;
                files(cont,1) = {listregtot2(tot,:)};
            else
                [tot,~] = find(and(ceros==0,abs(resta(:,end))<=2));
                if length(tot) >= 3
                    cont = cont+1;
                    files(cont,1) = {listregtot2(tot,:)};
                else
                    [tot,~] = find(and(ceros==0,abs(resta(:,end))<=3));
                    if length(tot) >= 3
                        cont = cont+1;
                        files(cont,1) = {listregtot2(tot,:)};
                    else
                        cont3 = cont3+1;
                        filesNO(cont3,1) = {listregtot2(tot,:)};
                    end
                end
            end
        end
        patnum2(tot,:) = [];
        listregtot2(tot,:) = [];
    end
end

elim = [];
for i = 1:length(files)
    [~,~,extens] = fileparts(files{i});
    extens = lower(extens);
    elimarch = contains(extens,{'.txt';'.jpg';'.pdf';'.xlsx'});
    files{i}(elimarch) = [];
    if isempty(files{i})
        elim = [elim;i];
    end
end
files(elim) = [];

% Revisión
suma = 0;
for i = 1:length(files)
    suma = suma+length(files{i});
end
for i = 1:length(filesNO)
    suma = suma+length(filesNO{i});
end
if suma ~= length(patnum); fprintf(1,'\t%s\n','revisar files trescanales.m suma~=length(patnum)'); end
%------------------

% Revisar
% common_to_use = listreguniq{1}(1:find(any(diff(char(listreguniq(:))),1),1,'first')-1)
% common_to_use = listreguniq{1}(1:find(any(char(listreguniq(1,:))-char(listreguniq)),1,'first')-1)
% listreg(contains(listreg,[{'.'};{'..'}])) = [];
