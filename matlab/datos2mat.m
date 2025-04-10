clear
format short

cargar_rutas_locales

addpath('utils')
sep = obtener_separador_linux_window();

listest = dir(rutadatos);
bal = cell2mat({listest.isdir}');
listest = {listest(bal).name}.';
listest(ismember(listest,[{'.'};{'..'}])) = [];

%% DATOS INICIALES
unidad = 'velo'; %velo; acel

%% S
buscar = {'ANGA'};    %¡¡¡ESCOGER ESTACIÓN!!!%
% buscar = listest;

%%
if ~exist(rutaarch,'dir'); mkdir(rutaarch); end

% Ciclo estaciones
[~,Nbuscar] = ismember(buscar,listest);
for k = 1:length(buscar)
    estac = listest{Nbuscar(k)};

    fprintf(1,'%d%s%d%s%s\n',k,'\',length(buscar),' --> ',estac);
    if ~exist([rutaarch,estac],'dir'); mkdir([rutaarch,estac]); end

    % Listas de carpetas y archivos
    files = trescanales(rutadatos,listest{Nbuscar(k)});

    %%%%% EVALUACIÓN %%%%%
    if isempty(files)
        continue
    end
    %%%%%%%%%%%%%%%%%%%%%%

    % Selección de días en particular
    filesnew = [];
    for i = 1:length(files)
        if contains(files{i}{1},{'20240707';'20240709'})
            filesnew = [filesnew;files(i)];
        end
    end
    files = filesnew;

    % Lectura de archivos
    for i = 1:length(files)
        filesi = files{i};

        fprintf(1,'\t%d%s%d\n',i,'\',length(files));

        mpsselec = 100;
        mpsselec2 = 200;
        [reg,direc,mps,hmsnum,sensor] = lecturafiles(filesi,mpsselec,mpsselec2);
        if isempty(reg)
            continue
        end

        % Revisiones
        if sum(contains(["E","N","Z"],direc)) ~= 3
            fprintf(1,'\t%s\n',['Núm direcciones~=3 ',files{i}{end}(1:end-4)]);
            continue
        end

        % Hora de inicio de la señal
        hmsDIRvec = datevec(max(hmsnum));
        hmsDIRvec(5) = hmsDIRvec(5);
        bal = extract(num2str(hmsDIRvec),digitsPattern);
        bal = bal(1:6);
        for ii = 2:6
            if size(bal{ii},2) == 1; bal(ii) = {['0',bal{ii}]}; end
        end
        fechahms = char(join(bal,''));
        nombarch = [rutaarch,estac,sep,fechahms,'.mat'];
        % if exist(nombarch,'file') ~= 0; continue; end

        [~,can] = ismember(["E","N","Z"],direc);
        datEW = reg{can(1)};
        datNS = reg{can(2)};
        datVE = reg{can(3)};

        datEW(isnan(datEW)) = 0;
        datNS(isnan(datNS)) = 0;
        datVE(isnan(datVE)) = 0;

        %%%%% EVALUACIÓN %%%%%
        minutosmin = 10;
        duracminima = minutosmin*60*mps;
        if length(datEW) < duracminima || length(datNS) < duracminima || length(datVE) < duracminima
            continue
        end
        Nrev = round(0.2*length(datEW));
        if sum(datEW(1+Nrev:end-Nrev)) == 0 || sum(datNS(1+Nrev:end-Nrev)) == 0 || sum(datVE(1+Nrev:end-Nrev)) == 0
            continue
        end
        %%%%%%%%%%%%%%%%%%%%%%

        % Hora de inicio común para las tres direcciones
        dt = 1/mps;
        hmsEW = datevec(hmsnum(1));
        hmsNS = datevec(hmsnum(2));
        hmsVE = datevec(hmsnum(3));
        EWini = round(((hmsDIRvec(5)*60+hmsDIRvec(6))-(hmsEW(5)*60+hmsEW(6)))/dt)+1;
        NSini = round(((hmsDIRvec(5)*60+hmsDIRvec(6))-(hmsNS(5)*60+hmsNS(6)))/dt)+1;
        VEini = round(((hmsDIRvec(5)*60+hmsDIRvec(6))-(hmsVE(5)*60+hmsVE(6)))/dt)+1;
        EW = datEW(EWini:end);
        NS = datNS(NSini:end);
        VE = datVE(VEini:end);
        mindat = min([length(EW) length(NS) length(VE)]);
        EW = EW(1:mindat);
        NS = NS(1:mindat);
        VE = VE(1:mindat);

        [EW,NS,VE,w1,w2] = acondsignal(EW,NS,VE,dt);

        REG.nombarch = [fechahms,'.mat'];
        REG.estac = estac;
        REG.sensor = sensor;
        REG.unidad = unidad;
        REG.mps = mps(1);
        REG.dt = dt;
        REG.w1 = w1;
        REG.w2 = w2;
        REG.NS = NS;
        REG.VE = VE;
        REG.EW = EW;
        REG.fechahms = fechahms;

        save(nombarch,'REG','-v7.3');
    end
end
