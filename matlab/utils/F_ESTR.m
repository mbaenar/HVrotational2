function [ESTR,ii] = F_ESTR(rutaarch,estac,diahoras,w1new,w2new,fmthora)

sep = obtener_separador_linux_window();

% Formato de hora
if strcmp(fmthora,'MXN')
    hrini = 7;
    hrfin = 24;
elseif strcmp(fmthora,'GMT')
    hrini = 5;
    hrfin = 11;
end

ESTR = [];
ii = 0;
for p = 1:length(diahoras) %NdiasHV
    R = load([rutaarch,estac,sep,diahoras{p},'.mat']);

    minmas = 0;
    if p == 1 && length(diahoras) > 1
        minmas = 10;
    end
    Nminmas = minmas*60/R.REG.dt+1;

    EW = R.REG.EW(Nminmas:end);
    NS = R.REG.NS(Nminmas:end);
    VE = R.REG.VE(Nminmas:end);
    ESTR.w1 = R.REG.w1;
    ESTR.w2 = R.REG.w2;

    % ¡¡¡REVISAR!!! Para registros de 24 horas
    long24hr = 23.5*60*60/R.REG.dt;
    if length(EW) >= long24hr
        Nhrini = hrini*60*60/R.REG.dt;
        Nhrfin = hrfin*60*60/R.REG.dt;
        if horario(hh) == 1
            if strcmp(fmthora,'MXN')
                EW = EW(Nhrini:Nhrfin);
                NS = NS(Nhrini:Nhrfin);
                VE = VE(Nhrini:Nhrfin);
            end
            if strcmp(fmthora,'GMT')
                EW(Nhrini:Nhrfin) = 0;
                NS(Nhrini:Nhrfin) = 0;
                VE(Nhrini:Nhrfin) = 0;
            end
        elseif horario(hh) == 2
            if strcmp(fmthora,'MXN')
                EW = EW(1:Nhrini);
                NS = NS(1:Nhrini);
                VE = VE(1:Nhrini);
            end
            if strcmp(fmthora,'GMT')
                EW = EW(Nhrini:Nhrfin);
                NS = NS(Nhrini:Nhrfin);
                VE = VE(Nhrini:Nhrfin);
            end
        end
    end
    
    if sum(EW) ~= 0 || sum(NS) ~= 0 || sum(VE) ~= 0
        ii = ii+1;
        ESTR.EW{ii,1} = double(EW);
        ESTR.NS{ii,1} = double(NS);
        ESTR.VE{ii,1} = double(VE);
        ESTR.vecfechahms{ii,1} = diahoras{p};
        if ii == 1
            ESTR.dt = R.REG.dt;
            ESTR.unidad = R.REG.unidad;
        end

        % Nuevo filtro entre w1 y w2
        if w1new > 0 || w2new > 0
            if w1new ~= 0; ESTR.w1 = w1new; end
            if w2new ~= 0; ESTR.w2 = w2new; end
            ESTR.EW{ii} = filtsig(ESTR.EW{ii},ESTR.dt,ESTR.w1,ESTR.w2,factap);
            ESTR.NS{ii} = filtsig(ESTR.NS{ii},ESTR.dt,ESTR.w1,ESTR.w2,factap);
            ESTR.VE{ii} = filtsig(ESTR.VE{ii},ESTR.dt,ESTR.w1,ESTR.w2,factap);
        end
    end
end
