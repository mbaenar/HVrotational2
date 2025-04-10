clear; clc
% close all
format short

cargar_rutas_locales

addpath('utils')
sep = obtener_separador_linux_window();

%% DATOS INICIALES
senhal = 'noise';

% Filtro inicial de las señales en bruto
w1new = 0;
w2new = 0;

% Factor de esquina para taper de señales
factap = 0.0;

% *****NORMALIZACIÓN*****
% band:   0=ninguna, 2=suma3direcc, 3=SW
% onebit: 1=SI, 0=NO

% SELECCIONAR DATOS
NdiasHV0 = 3;
segvent = [500];         % Segundos de las ventanas para inversión
porctrasl = [50];        % Porcentaje de traslape de las ventanas
horario = [3];	         % 1=DÍA, 2=NOCHE, 3=DÍANOCHE
normalizac = [2 0];      % Normalización: [band,onebit]
tiempoHV = [(NdiasHV0*24)*60];      % Tiempo (minutos) para cálculo de cada H/V (Tiempo de registro manipulable)
ventaleatHV = 1;         % 1=ventanas aleatoria, 0=ventanas continuas
NvBootstrap = 1;         % Número de ventanas para el boostrap
tSTA = 2; %1.35;         % En segundos
tLTA = 60;               % En segundos
Smax = 3.5;              % 0=todas las ventanas
Smin = 0.2;
dfnew = 1;
suav = 1;                % 0=no; 1=sí
fmthora = 'GMT';         % Formato de hora: 'GMT', 'MXN'

% Si baja el tLTA es más conservador
itertot = length(segvent)*length(porctrasl)*length(horario)*length(normalizac(:,1))*length(tiempoHV);
separador = obtener_separador_linux_window();

%% Buscar estación
listest = dir(rutaarch);
listest = {listest.name}';
bal = find(ismember(listest,[{'.'};{'..'}])==1);
listest(bal) = [];

buscar = listest;
% buscar = {'ICVM'};        % ¡¡¡ESCOGER ESTACIÓN!!!

%% Invierte la escala de colores,se puede comentar
col = get_colors(itertot);

%% Ciclo principal
tetarot = 0:10:180;
tetarot = 0; %:45:180; %:1:180;
if length(tetarot) > 1 && isempty(find(tetarot,90))
    tetarot = [tetarot,90];
end
tetarot = sort(tetarot);

% Formato de hora
if strcmp(fmthora,'MXN')
    hrini = 7;
    hrfin = 24;
elseif strcmp(fmthora,'GMT')
    hrini = 5;
    hrfin = 11;
end

% *****************************************************
% CICLO DE ESTACIONES
% *****************************************************
[~,Nbuscar] = ismember(buscar,listest);
for ee = 1:length(buscar)
    estac = listest{Nbuscar(ee)};
    fprintf(1,'%d%s%d%s%s\n',ee,'/',length(buscar),' --> ',estac);

    % *****************************************************
    % ESTRUCTURA HV.
    % *****************************************************
    % estac: nombre de la estación
    % paraadic: parámetros adicionales (fechas, número de ventanas para H/V, parámetros para STA/LTA, df)
    % clavecomb: clave de cada combinación de parámetros
    % Nvent: número de ventanas empleadas para el H/V
    % fcomb: vector de frecuencias
    % HVmean_comb: matriz con el H/V medio de cada combinación de parámetros (por columna)
    % NVmean_comb: matriz con el H/V de cada combinación de parámetros, usando solo la componente norte-sur (por columna)
    % EVmean_comb: matriz con el H/V de cada combinación de parámetros, usando solo la componente este-oeste (por columna)
    % tiempoHV_orig_min: tiempo solicitado para el cálculo del H/V
    % tiempoHV_real_min: tiempo real empleado para el cálculo del H/V
    % f_comb1: vector de frecuencias de la combinación de parámetros 1
    % HVtot_comb1: H/V de la combinación de parámetros 1
    % HVdir_comb1: H/V direccional norte-sur empleando la combinación de parámetros 1
    % tetarot: vector de ángulos de rotación para el H/V direccional
    HV = struct('estac',[],'paraadic',[],'clavecomb',[],'Nvent',[],'fcomb',[],'HVmean_comb',[],'NVmean_comb',[],'EVmean_comb',[], ...
        'tiempoHV_orig_min',[],'tiempoHV_real_min',[], ...
        'f_comb1',[],'HVtot_comb1',[],'HVdir_comb1',[],'tetarot',[]);
    HV.estac = estac;
    HV.paraadic.ventaleatHV = ventaleatHV;
    HV.paraadic.NvBootstrap = NvBootstrap;
    HV.paraadic.tSTA = tSTA;
    HV.paraadic.tLTA = tLTA;
    HV.paraadic.Smax = Smax;
    HV.paraadic.Smin = Smin;
    HV.paraadic.NdiasHV = NdiasHV0;
    HV.tetarot = tetarot;
    % *****************************************************

    crear_directorios(rutahv,estac)
    nombgrab = [rutahv,estac,[separador 'HV_'],estac];

    listreg = dir([rutaarch,estac,sep,'*.mat']);
    listreg = {listreg.name}'; %name

    NdiasHV = NdiasHV0; % Puede modificarse
    [listdias,listdiashoras] = obtener_lista_dias(listreg,NdiasHV);
    suma = 0;
    for ll = 1:length(listdiashoras)
        suma = suma+length(listdiashoras{ll});
    end
    if suma ~= length(listreg); fprintf(1,'\t%s\n','revisar suma~=length(listreg)'); end
    listaciclo = listdiashoras;

    % % Desbloquear si se va a calcular por días en particular
    % buscardia = {'20130413'; '20131213'; '20161022'; '20171230'; '20180503'; '20180704'; '20180711'; '20180821'; '20180829'; '20180921'; '20181006'; '20181007'; '20181013'; '20181016'; '20181201'; '20181212'; '20181221'; '20190114'; '20190123'; '20190223'; '20190317'; '20190403'; '20190405'; '20190407'; '20190421'; '20191106'; '20191115'; '20200113'; '20200804'; '20210314'};
    % buscardia = {'20250224'};
    % listaciclo2 = {};
    % Nbuscardia = [];
    % for dn = 1:length(listaciclo)
    %     listaciclo2(dn,1) = {listaciclo{dn}{1}(1:8)};
    % end
    % for dn = 1:length(buscardia)
    %     [~,bal] = ismember(buscardia(dn),listaciclo2);
    %     Nbuscardia(dn,1) = bal;
    % end

    % % Desbloquear si se va a calcular un H/V hora
    % listaciclo = {};
    % for bal0 = 1:length(listreg)
    %     listaciclo(bal0,1) = {listreg(bal0)};
    % end

    % *****************************************************
    % CICLO DE DÍAS U HORAS
    % *****************************************************
    leyenda = [];
    for dd = 1 %:length(listaciclo) %1:length(listaciclo)  %Nbuscardia.'
        diahoras = listaciclo{dd};
        nombgrab0 = [nombgrab,'_',diahoras{1}(1:8),'.mat'];
        % if exist(nombgrab0,'file') ~= 0; continue; end

        fprintf(1,'\t%s%d%s%d%s%s\n','Núm H/V ',dd,'/',length(listaciclo),' --> ',diahoras{1});

        % *****************************************************
        % CICLO DE HORARIO
        % *****************************************************
        for hh = 1:length(horario)
            hora = [];
            for bb = 1:length(diahoras)
                hora(bb,1) = str2double(diahoras{bb}(9:10));
            end

            diahoraselec = diahoras;
            if horario(hh) == 1
                if strcmp(fmthora,'MXN'); diahoraselec = diahoras( and(hora>=hrini,hora<=hrfin)); end
                if strcmp(fmthora,'GMT'); diahoraselec = diahoras(~and(hora>=hrini,hora<=hrfin)); end
            elseif horario(hh) == 2
                if strcmp(fmthora,'MXN'); diahoraselec = diahoras(~and(hora>=hrini,hora<=hrfin)); end
                if strcmp(fmthora,'GMT'); diahoraselec = diahoras( and(hora>=hrini,hora<=hrfin)); end
            end

            % *****************************************************
            % CICLO LECTURA DE DATOS SEGÚN EL HORARIO
            % *****************************************************
            ESTR = [];
            ii = 0;
            for p = 1:length(diahoraselec) %NdiasHV
                diahora = diahoraselec{p};
                load([rutaarch,estac,sep,diahora])

                minmas = 0;
                if p == 1 && length(diahoraselec) > 1
                    minmas = 10;
                end
                Nminmas = minmas*60/REG.dt+1;
                
                EW2 = REG.EW(Nminmas:end);
                NS2 = REG.NS(Nminmas:end);
                VE2 = REG.VE(Nminmas:end);
                w1 = REG.w1;
                w2 = REG.w2;
                
                % % ¡¡¡REVISAR!!!Para registros de 24 horas
                % long24hr = 23.5*60*60/REG.dt;
                % if length(EW2) >= long24hr
                %     Nhrini = hrini*60*60/REG.dt;
                %     Nhrfin = hrfin*60*60/REG.dt;
                %     if horario(hh) == 1
                %         if strcmp(fmthora,'MXN')
                %             EW2 = EW2(Nhrini:Nhrfin);
                %             NS2 = NS2(Nhrini:Nhrfin);
                %             VE2 = VE2(Nhrini:Nhrfin);
                %         end
                %         if strcmp(fmthora,'GMT')
                %             EW2(Nhrini:Nhrfin) = 0;
                %             NS2(Nhrini:Nhrfin) = 0;
                %             VE2(Nhrini:Nhrfin) = 0;
                %         end
                %     elseif horario(hh) == 2
                %         if strcmp(fmthora,'MXN')
                %             EW2 = EW2(1:Nhrini);
                %             NS2 = NS2(1:Nhrini);
                %             VE2 = VE2(1:Nhrini);
                %         end
                %         if strcmp(fmthora,'GMT')
                %             EW2 = EW2(Nhrini:Nhrfin);
                %             NS2 = NS2(Nhrini:Nhrfin);
                %             VE2 = VE2(Nhrini:Nhrfin);
                %         end
                %     end
                % end

                if sum(EW2) ~= 0 || sum(NS2) ~= 0 || sum(VE2) ~= 0
                    ii = ii+1;
                    ESTR.EW{ii,1} = double(EW2);
                    ESTR.NS{ii,1} = double(NS2);
                    ESTR.VE{ii,1} = double(VE2);
                    ESTR.vecfechahms{ii,1} = [diahora(1:8),'_',diahora(9:end-4)];
                    if ii == 1
                        ESTR.dt = REG.dt;
                        ESTR.unidad = REG.unidad;
                    end

                    % Nuevo filtro entre w1 y w2
                    if w1new > 0 || w2new > 0
                        if w1new ~= 0; w1 = w1new; end
                        if w2new ~= 0; w2 = w2new; end
                        ESTR.EW{ii} = filtsig(ESTR.EW{ii},ESTR.dt,w1,w2,factap);
                        ESTR.NS{ii} = filtsig(ESTR.NS{ii},ESTR.dt,w1,w2,factap);
                        ESTR.VE{ii} = filtsig(ESTR.VE{ii},ESTR.dt,w1,w2,factap);
                    end
                end
            end
            if ii == 0; continue; end
            
            HV.paraadic.fechahms = ESTR.vecfechahms;

            dt = ESTR.dt;
            unid = ESTR.unidad;
            fmax = 1/(2*dt);
            Narch = size(ESTR.EW,1);
            f0 = [];

            % *****************************************************
            % CICLO ÁNGULOS DE ROTACIÓN
            % *****************************************************
            HV.HVdir_comb1 = [];
            contteta = 0;
            for Nteta = 1:length(tetarot)
                contteta = contteta+1;
                iter = 0;
                ccd = 0;

                % Rotación sismogramas
                teta = tetarot(Nteta);
                [EWrot,NSrot] = rotar_sismogramas(ESTR,teta,Narch);

                fprintf(1,'\t\t%s%d%s%d%s%d%s\n','teta ',Nteta,'/',length(tetarot),' --> ',teta,'°');

                % *****************************************************
                % CICLO LONGITUD DE VENTANAS
                % *****************************************************
                for vv = 1:length(segvent)
                    flim1 = 0; %0
                    flim2 = fmax; %5; %20
                    [f,fin,ini,ptosvent,Nespec,df] = obtener_vector_de_frecuencia(segvent(vv), ...
                        dt,dfnew,fmax,flim1,flim2);

                    % *****************************************************
                    % CICLO TRASLAPE DE VENTANAS
                    % *****************************************************
                    wincleantot = [];
                    for tt = 1:length(porctrasl)

                        % VENTANEO
                        [Nventefec,M,iv,fv,wincleantot,wincleanEW,wincleanNS, ...
                            wincleanVE,STALTAEW,STALTANS,STALTAVE] = ventaneo(porctrasl(tt), ...
                            ptosvent,EWrot,NSrot,ESTR.VE,dt,tSTA,tLTA,Smax,Smin,Narch);

                        % Figuras para revisión
                        plot_figura300(EWrot,NSrot,ESTR.VE,Narch,dt,wincleantot,iv,fv,Smax,STALTANS,STALTAEW,STALTAVE)
                        close(300)

                        % DIVISIÓN DE LA SEÑAL EN VENTANAS DE TIEMPO
                        [EWv,NSv,VEv,fechahmsvent] = division_ventanas_tiempo(EWrot,NSrot,ESTR.VE,ESTR.vecfechahms,ptosvent, ...
                            Nventefec,Narch,wincleantot,iv,fv);

                        % *****************************************************
                        % CICLO DE NORMALIZACIÓN
                        % *****************************************************
                        for norm = 1:length(normalizac(:,1))
                            band = normalizac(norm,1);
                            onebit = normalizac(norm,2);

                            % Carpeta y archivo para grabar resultados
                            nombcomb = nombre_combinac(senhal,unid,band,w1,w2,onebit,horario(hh),segvent(vv),porctrasl(tt));

                            % NORMALIZACIÓN
                            [fNSventnorm,fVEventnorm,fEWventnorm,~,~,~,~,~] = F_normalizacionfrec(NSv,VEv,EWv, ...
                                Nespec,band,onebit,dt,factap);

                            [fNSvent,fEWvent,fVEvent,fHHvent] = obtener_valores_absolutos(fNSventnorm,fEWventnorm,fVEventnorm,ini,fin);

                            fNSventnorm = [];
                            fEWventnorm = [];
                            fVEventnorm = [];

                            % *****************************************************
                            % CICLO DE TIEMPOS PARA CÁLCULO DE H/V
                            % *****************************************************
                            for nh = 1:length(tiempoHV)
                                iter = iter+1;
                                fprintf(1,'\t\t\t%s%d%s%d\n','iter ',iter,'/',itertot);

                                % CÁLCULO DE H/V
                                [HVmean,NVmean,EVmean,NventHV,vini,tiempoHVnuevo,numHV,HVvent] = F_HVruido(f,fNSvent,fEWvent, ...
                                    fVEvent,fHHvent,segvent(vv),porctrasl(tt),tiempoHV(nh),suav,ventaleatHV,NvBootstrap);

                                tiempoHVnuevo_str = num2str(round(tiempoHVnuevo*100)/100);
                                clavecomb = ['CD-HV',tiempoHVnuevo_str,'hr','-',nombcomb,'-Nw',num2str(NventHV(1)),'-NwBS',num2str(numHV)];

                                if contteta == 1
                                    ccd = ccd+1;
                                    HV.clavecomb{ccd} = clavecomb;
                                    HV.Nvent{ccd} = NventHV(1);
                                    HV.fcomb{ccd} = f;
                                    HV.HVmean_comb{ccd} = HVmean;
                                    HV.NVmean_comb{ccd} = NVmean;
                                    HV.EVmean_comb{ccd} = EVmean;
                                    HV.tiempoHV_orig_min{ccd} = tiempoHV(nh);
                                    HV.tiempoHV_real_min{ccd} = tiempoHVnuevo*60;
                                end

                                if iter == 1
                                    HV.HVdir_comb1 = [HV.HVdir_comb1;NVmean.'];
                                    if contteta == 1
                                        HV.f_comb1 = HV.fcomb{1};
                                        HV.HVtot_comb1 = HV.HVmean_comb{1};
                                    end
                                end
                            end
                            NSv = [];
                            VEv = [];
                            EWv = [];
                        end
                    end
                end

                %% Figura
                if contteta == 1 && Nventefec > 0
                    [leyenda] = figure_ee(ee,leyenda,HV,estac);
                    drawnow
                    % print(gcf,nombgrab0(1:end-4),'-dpng','-r600')
                    % close(h)

                    % % Generación de archivo de texto para inversión
                    % f1 = 0.001;
                    % f2 = 1;
                    % paso = 3;
                    % fs = 6;
                    % [HVesc,fsesc] = archivo_inversion(HV.HVmean_comb{1},HV.fcomb{1},f1,f2,paso,fs);
                    % dlmwrite([rutahv,'HV-',estac,'.txt'],[fsesc,HVesc],'delimiter','\t','precision','%14.8f')
                end
            end
            % if Nventefec > 0
            %     save(nombgrab0,'HV','-v7.3');
            % end
        end
    end
end
