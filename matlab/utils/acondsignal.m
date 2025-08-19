function [EW2,NS2,VE2,w1,w2] = acondsignal(EW,NS,VE,dtnuevo)

dtorig = dtnuevo;

fmax = 1/(2*dtnuevo);
w1 = 0.05;
w2 = fmax-0.1;
factap = 0.0;

% % Instrument correct
% VMS = G;
% CV = 1./(VPC/1000000);
% CMS = G.*CV;
% MSC = 1./(CMS);
% EW = rm_instrum_resp(EW,badvals,mpsEW,pols,zers,flo,fhi,ordl,ordh,MSC(3),digoutf,ovrsampl,idelay);
% NS = rm_instrum_resp(NS,badvals,mpsNS,pols,zers,flo,fhi,ordl,ordh,MSC(2),digoutf,ovrsampl,idelay);
% VE = rm_instrum_resp(VE,badvals,mpsVE,pols,zers,flo,fhi,ordl,ordh,MSC(1),digoutf,ovrsampl,idelay);

% % Corrección instrumental
% [facV,facN,facE] = factorequipoRACM(sensor);
% EW = EW*facE{1};
% NS = NS*facN{1};
% VE = VE*facV{1};

% Diezmado de la señal
mindat = length(EW);
durac = (mindat-1)*dtorig;
tnuevo = (0:dtnuevo:durac)';
if dtorig ~= dtnuevo
    torig = (0:dtorig:durac)';
    EW = interp1(torig,EW,tnuevo);
    NS = interp1(torig,NS,tnuevo);
    VE = interp1(torig,VE,tnuevo);
    mindat = length(EW);
end

% Localización de gaps -------------------
[grEW,grgapEW] = locgaps(EW,dtnuevo);
[grNS,grgapNS] = locgaps(NS,dtnuevo);
[grVE,grgapVE] = locgaps(VE,dtnuevo);
% ----------------------------------------

if isempty(grEW) || isempty(grNS) || isempty(grVE)
    EW2 = zeros(mindat,1);
    NS2 = zeros(mindat,1);
    VE2 = zeros(mindat,1);
else
    % if length(grEW) == 1 && length(grNS) == 1 && length(grVE) == 1 %#ok<ISCL>
        if length(grEW) > 1 || length(grNS) > 1 || length(grVE) > 1 %#ok<ISCL>
            fprintf(1,'\t%d%s\n',length(grEW)-1,' gaps')
        end

        % % Figura de revisión
        % figure(20)
        % tiledlayout(3,1)
        % tnuevo = (0:dtnuevo:(length(EW)-1)*dtnuevo)';
        % nexttile(1); plot(tnuevo,NS,'b'); hold on; grid on
        % nexttile(2); plot(tnuevo,EW,'b'); hold on; grid on
        % nexttile(3); plot(tnuevo,VE,'b'); hold on; grid on
        % if ~isempty(grgapEW)
        %     for gg = 1:length(grgapEW)
        %         nexttile(1); line([tnuevo(grgapNS{gg}(1)) tnuevo(grgapNS{gg}(end))],[0.01 0.01],'color','r')
        %         nexttile(2); line([tnuevo(grgapEW{gg}(1)) tnuevo(grgapEW{gg}(end))],[0.01 0.01],'color','r')
        %         nexttile(3); line([tnuevo(grgapVE{gg}(1)) tnuevo(grgapVE{gg}(end))],[0.01 0.01],'color','r')
        %     end
        % end

        % % Quita la tendencia de las señales completas
        % EW = detrend(EW);
        % NS = detrend(NS);
        % VE = detrend(VE);

        % % Resta la media de las señales completas
        % sumdatEW = 0;
        % sumdatNS = 0;
        % sumdatVE = 0;
        % NgrsigEW = 0;
        % NgrsigNS = 0;
        % NgrsigVE = 0;
        % for gr = 1:length(grEW)
        %     ii = grEW{gr}(1); ff = grEW{gr}(end);
        %     sumdatEW = sumdatEW+sum(EW(ii:ff));
        %     NgrsigEW = NgrsigEW+length(EW(ii:ff));
        % end
        % meandatEW = sumdatEW/NgrsigEW;
        % EW = EW-meandatEW;
        % for gr = 1:length(grNS)
        %     ii = grNS{gr}(1); ff = grNS{gr}(end);
        %     sumdatNS = sumdatNS+sum(NS(ii:ff));
        %     NgrsigNS = NgrsigNS+length(NS(ii:ff));
        % end
        % meandatNS = sumdatNS/NgrsigNS;
        % NS = NS-meandatNS;
        % for gr = 1:length(grVE)
        %     ii = grVE{gr}(1); ff = grVE{gr}(end);
        %     sumdatVE = sumdatVE+sum(VE(ii:ff));
        %     NgrsigVE = NgrsigVE+length(VE(ii:ff));
        % end
        % meandatVE = sumdatVE/NgrsigVE;
        % VE = VE-meandatVE;

        % Filtro de la señal
        if w1 > 0 && w2 > 0
            EW = filtsig(EW,dtnuevo,w1,w2,factap);
            NS = filtsig(NS,dtnuevo,w1,w2,factap);
            VE = filtsig(VE,dtnuevo,w1,w2,factap);
        end

        % segundosvent = 20;
        % Nsegundosvent = segundosvent/dtnuevo;
        factap2 = 0.0;
        EW2 = zeros(mindat,1);
        NS2 = zeros(mindat,1);
        VE2 = zeros(mindat,1);
        for gr = 1:length(grEW)
            ii = grEW{gr}(1); ff = grEW{gr}(end);
            % Corrección línea base
            EW2(ii:ff) = EW(ii:ff);
            % EW2(ii:ff) = lineabase(EW2(ii:ff),Nsegundosvent);
            EW2(ii:ff) = EW2(ii:ff).*tukeywin(length(EW2(ii:ff)),factap2);
        end
        for gr = 1:length(grNS)
            ii = grNS{gr}(1); ff = grNS{gr}(end);
            % Corrección línea base
            NS2(ii:ff) = NS(ii:ff);
            % NS2(ii:ff) = lineabase(NS2(ii:ff),Nsegundosvent);
            NS2(ii:ff) = NS2(ii:ff).*tukeywin(length(NS2(ii:ff)),factap2);
        end
        for gr = 1:length(grVE)
            ii = grVE{gr}(1); ff = grVE{gr}(end);
            % Corrección línea base
            VE2(ii:ff) = VE(ii:ff);
            % VE2(ii:ff) = lineabase(VE2(ii:ff),Nsegundosvent);
            VE2(ii:ff) = VE2(ii:ff).*tukeywin(length(VE2(ii:ff)),factap2);
        end

        % Longitud de los vectores par
        N = length(EW2);
        if rem(N,2) ~= 0
            EW2 = EW2(1:end-1);
            NS2 = NS2(1:end-1);
            VE2 = VE2(1:end-1);
        end

        % % Figura de revisión
        % figure(20)
        % t = (0:dtnuevo:(length(EW2)-1)*dtnuevo)';
        % nexttile(1)
        % plot(t,NS2,'m'); hold on; grid on
        % ylabel('NS (cm/s)')
        % % set(gca,'XTicklabel',[])
        % nexttile(2)
        % plot(t,EW2,'m'); hold on; grid on
        % ylabel('EW (cm/s)')
        % % set(gca,'XTicklabel',[])
        % nexttile(3)
        % plot(t,VE2,'m'); hold on; grid on
        % ylabel('VE (cm/s)')
        % set(gcf,'color','white')
        % xlabel('Tiempo (s)')
    % end
end
