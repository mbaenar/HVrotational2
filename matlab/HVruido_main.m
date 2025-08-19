% Programa para calcular el cociente espectral HVSR-direccional
% bajo la hipótesis de campos difusos, empleando señales de
% ruido sísmico ambiental.
% Elaborado por Marcela Baena Rivera, Instituto de Ingeniería, UNAM

clear
format short

cargar_rutas_locales
addpath('utils')
sep = obtener_separador_linux_window();

if ~exist(rutahv,'dir'); mkdir(rutahv); end

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
flim1 = 0;   %0         % Frecuencia inicial de cálculo
flim2 = 2;   %fmax      % Frecuencia final de cálculo
suav = 1;                % 0=no; 1=sí
fmthora = 'GMT';         % Formato de hora: 'GMT', 'MXN'

% Si el tSTA es pequeño, es más conservador

itertot = length(segvent)*length(porctrasl)*length(horario)*length(normalizac(:,1))*length(tiempoHV);

%% Buscar estación
listest = dir(rutaarch);
listest = {listest.name}';
bal = find(ismember(listest,[{'.'};{'..'}])==1);
listest(bal) = [];

buscar = listest;
% buscar = {'CM012';'CM064'};

[~,Nbuscar] = ismember(buscar,listest);

%% Bloque principal de ciclos del procesamiento

% Ángulos de rotación para el cálculo del HVDIR
tetarot = 0:10:180; %:45:180
% tetarot = 0;
if length(tetarot) > 1 && ~ismember(90,tetarot)
    tetarot = [tetarot,90];
end
tetarot = sort(tetarot);

% *****************************************************
% CICLO GLOBAL DE ESTACIONES
% *****************************************************
% parfor ee = 1:length(buscar)
for ee = 1:length(buscar)
    estac = listest{Nbuscar(ee)};
    fprintf(1,'%d%s%d%s%s\n',ee,'/',length(buscar),' --> ',estac);

    % *****************************************************
    % ESTRUCTURA "HV"
    % *****************************************************
    % estac: nombre de la estación
    % paramadic: parámetros adicionales (fechas, número de ventanas para H/V, parámetros para STA/LTA, df)
    % clavecomb: clave de cada combinación de parámetros
    % fechahms: fechas empleadas en cada combinación de parámetros
    % Nvent: número de ventanas empleadas para el H/V
    % fcomb: vector de frecuencias
    % HVmean_comb: matriz con el H/V medio de cada combinación de parámetros (por columna)
    % NVmean_comb: matriz con el H/V de cada combinación de parámetros, usando solo la componente norte-sur (por columna)
    % EVmean_comb: matriz con el H/V de cada combinación de parámetros, usando solo la componente este-oeste (por columna)
    % tiempoHV_orig_min: tiempo solicitado para el cálculo del H/V
    % tiempoHV_real_min: tiempo real empleado para el cálculo del H/V
    % HVdir_comb1: H/V direccional norte-sur empleando la combinación de parámetros 1
    % tetarot: vector de ángulos de rotación para el H/V direccional
    HV = struct('estac',[],'paramadic',[],'clavecomb',[],'fechahms',[],'Nvent',[],'fcomb',[],'HVmean_comb',[],'NVmean_comb',[],'EVmean_comb',[], ...
        'tiempoHV_orig_min',[],'tiempoHV_real_min',[],'HVdir_comb1',[],'tetarot',[]);
    HV.estac = estac;
    HV.paramadic.ventaleatHV = ventaleatHV;
    HV.paramadic.NvBootstrap = NvBootstrap;
    HV.paramadic.tSTA = tSTA;
    HV.paramadic.tLTA = tLTA;
    HV.paramadic.Smax = Smax;
    HV.paramadic.Smin = Smin;
    HV.paramadic.NdiasHV = NdiasHV0;
    HV.tetarot = tetarot;
    % *****************************************************

    crear_directorios(rutahv,estac)
    nombgrab = [rutahv,estac,[sep 'HV_'],estac];

    listreg = dir([rutaarch,estac,sep,'*.mat']);
    listreg = {listreg.name}'; %name

    NdiasHV = NdiasHV0;  % Puede modificarse
    [listdias,listdiashoras] = obtener_lista_dias(listreg,NdiasHV);
    durdiashoras = zeros(length(listdiashoras),1);
    for ll = 1:length(listdiashoras)
        durdiashoras(ll) = length(listdiashoras{ll});
    end
    if sum(durdiashoras) ~= length(listreg); fprintf(1,'\t%s\n','revisar suma~=length(listreg)'); end
    listaciclo = listdiashoras;
    [~,bal] = sort(durdiashoras,'descend');

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
    % CICLO GLOBAL DE DÍAS U HORAS
    % *****************************************************
    leyenda = [];
    ciclodiashoras = bal(1);   % Escoger       %1:length(listaciclo); %Nbuscardia.'
    for dd = ciclodiashoras
        diahoras = listaciclo{dd};
        nombgrab0 = [nombgrab,'_',diahoras{1},'.mat'];
        % if exist(nombgrab0,'file') ~= 0; continue; end

        fprintf(1,'\t%s%d%s%d%s%s\n','Núm H/V ',dd,'/',length(listaciclo),' --> ',diahoras{1});

        % *****************************************************
        % LECTURA DE DATOS. ESTRUCTURA "ESTR"
        % *****************************************************
        [ESTR,ii] = F_ESTR(rutaarch,estac,diahoras,w1new,w2new,fmthora);
        
        if ii == 0; continue; end

        dt = ESTR.dt;
        w1 = ESTR.w1;
        w2 = ESTR.w2;
        unid = ESTR.unidad;
        fmax = 1/(2*dt);

        % *****************************************************
        % CICLO GLOBAL DE HORARIO
        % *****************************************************
        iter = 0;
        ccd = 0;
        for hh = 1:length(horario)
            hora = zeros(length(ESTR.vecfechahms),1);
            for bb = 1:length(ESTR.vecfechahms)
                hora(bb,1) = str2double(ESTR.vecfechahms{bb}(9:10));
            end

            [diahoraselec,horariograb] = selecdiahora(fmthora,ESTR.vecfechahms,hora,horario(hh));
            if isempty(diahoraselec)
                continue
            end

            [~,ind] = ismember(diahoraselec,ESTR.vecfechahms);
            vecfechahms2 = ESTR.vecfechahms(ind);
            EWind = ESTR.EW(ind);
            NSind = ESTR.NS(ind);
            VEind = ESTR.VE(ind);

            % *****************************************************
            % CICLO GLOBAL LONGITUD DE VENTANAS
            % *****************************************************
            for vv = 1:length(segvent)
                flim2def = flim2;
                if flim2def > fmax; flim2def = fmax; end
                [f,fin,ini,ptosvent,Nespec,df] = obtener_vector_de_frecuencia(segvent(vv), ...
                    dt,dfnew,fmax,flim1,flim2def);

                % *****************************************************
                % CICLO GLOBAL TRASLAPE DE VENTANAS
                % *****************************************************
                wincleantot = [];
                for tt = 1:length(porctrasl)

                    % VENTANEO
                    [Nventefec,M,iv,fv,wincleantot,STALTAEW,STALTANS,STALTAVE] = ventaneo(porctrasl(tt), ...
                        ptosvent,EWind,NSind,VEind,dt,tSTA,tLTA,Smax,Smin);

                    % % Figuras para revisión
                    % plot_figura300(EWind,NSind,VEind,dt,wincleantot,iv,fv,Smax,STALTANS,STALTAEW,STALTAVE)
                    % close(300)

                    % *****************************************************
                    % CICLO GLOBAL DE NORMALIZACIÓN
                    % *****************************************************
                    for norm = 1:length(normalizac(:,1))
                        band = normalizac(norm,1);
                        onebit = normalizac(norm,2);

                        % Carpeta y archivo para grabar resultados
                        nombcomb = nombre_combinac(senhal,unid,band,w1,w2,onebit,horariograb,segvent(vv),porctrasl(tt));

                        % *****************************************************
                        % CICLO GLOBAL DE TIEMPO PARA CÁLCULO DE H/V
                        % *****************************************************
                        for nh = 1:length(tiempoHV)
                            iter = iter+1;
                            fprintf(1,'\t\t%s%d%s%d\n','iter ',iter,'/',itertot);

                            % *****************************************************
                            % CICLO LOCAL ÁNGULOS DE ROTACIÓN
                            % *****************************************************
                            contteta = 0;
                            if iter == 1
                                HV.HVdir_comb1 = [];
                            end
                            Ntetarot = length(tetarot);
                            if iter > 1
                                Ntetarot = 1;
                            end
                            for Nteta = 1:Ntetarot
                                contteta = contteta+1;

                                % ROTACIÓN SISMOGRAMAS
                                teta = tetarot(Nteta);
                                [EWindrot,NSindrot] = rotar_sismogramas(EWind,NSind,teta);

                                fprintf(1,'\t\t\t%s%d%s%d%s%d%s\n','teta ',Nteta,'/',length(tetarot),' --> ',teta,'°');

                                % DIVISIÓN DE LA SEÑAL EN VENTANAS DE TIEMPO
                                [EWv,NSv,VEv] = division_ventanas_tiempo(EWindrot,NSindrot,VEind, ...
                                    ptosvent,Nventefec,wincleantot,iv,fv);

                                % NORMALIZACIÓN
                                [fNSvent,fVEvent,fEWvent,~,~,~,~,~] = F_normalizacionfrec(NSv,VEv,EWv, ...
                                    Nespec,band,onebit,dt,factap);

                                if Nventefec > 100
                                    fNSvent = fNSvent(:,1:100);
                                    fEWvent = fEWvent(:,1:100);
                                    fVEvent = fVEvent(:,1:100);
                                end

                                % CÁLCULO DE H/V
                                [HVmean,NVmean,EVmean,NventHV,vini,tiempoHVnuevo,numHV,HVvent] = F_HVruido(f,fNSvent, ...
                                    fEWvent,fVEvent,segvent(vv),porctrasl(tt),tiempoHV(nh),suav,ventaleatHV,NvBootstrap,ini,fin);

                                tiempoHVnuevo_str = num2str(round(tiempoHVnuevo*100)/100);
                                clavecomb = ['CD-HV',tiempoHVnuevo_str,'hr','-',nombcomb,'-Nw',num2str(NventHV(1)),'-NwBS',num2str(numHV)];

                                if contteta == 1
                                    ccd = ccd+1;
                                    HV.clavecomb{ccd} = clavecomb;
                                    HV.fechahms{ccd} = vecfechahms2;
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
                                end
                            end
                            NSv = [];
                            VEv = [];
                            EWv = [];
                        end
                    end
                end
            end
        end

        %% Figura
        % [leyenda] = figure_ee(ee,leyenda,HV,estac);
        % drawnow
        % % print(gcf,nombgrab0(1:end-4),'-dpng','-r600')
        % % close(h)

        % % Generación de archivo de texto para inversión
        % f1 = 0.001;
        % f2 = 1;
        % paso = 3;
        % fs = 6;
        % [HVesc,fsesc] = archivo_inversion(HV.HVmean_comb{1},HV.fcomb{1},f1,f2,paso,fs);
        % dlmwrite([rutahv,'HV-',estac,'.txt'],[fsesc,HVesc],'delimiter','\t','precision','%14.8f')

        % Guardar en un archivo .mat estructura "HV"
        funsave(nombgrab0,HV)     % Esta función es para poder parametrizar el código. En la línea 74, usar 'parfor'
    end
end
