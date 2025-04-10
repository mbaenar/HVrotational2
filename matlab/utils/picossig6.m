% Elimina picos en la se�al
function [winclean,STALTA] = picossig6(SIG,dt,vi,vf,tSTA,tLTA,Smax,Smin)
% SIG = ESTR.EW{p};
% dt = 0.01;
% Smax = 3;
% vi = iv{p};
% vf = fv{p};

SIGabs = abs(SIG);
% SIGabs = abs(hilbert(SIG));
M = length(vi);
N = length(SIG);

winclean = ones(M,1);

% M�ximos y medias por ventana
LTAmax = zeros(M,1);
LTAmean = zeros(M,1);
for i = 1:M
    SIGp = SIGabs(vi(i):vf(i));
    LTAmax(i,1) = max(SIGp);
    LTAmean(i,1) = mean(SIGp);
end
LTAmaxmax = max(SIGabs);

% Elimina picos superiores al 99.5% del pico m�ximo de la se�al
if Smax > 0
    for i = 1:M
        if LTAmax(i) > 0.995*LTAmaxmax
            winclean(i) = 0;
        end
    end
    LTAmeanmax = max(LTAmean(and(LTAmean>0,winclean==1)));
    if isempty(LTAmeanmax)
        winclean(winclean==1) = 0;
    end
    % Elimina picos superiores al 95% del promedio m�ximo de la se�al
    for i = 1:M
        if winclean(i) == 1
            if LTAmean(i) > 0.95*LTAmeanmax
                winclean(i) = 0;
            end
        end
    end

    % Calcula STA y LTA en toda la se�al
    STA = tSTA/dt;
    LTA = tLTA/dt;
    STAmovmean = movmean(SIGabs,STA,'omitnan'); %,'Endpoints','discard'
    LTAmovmean = movmean(SIGabs,LTA,'omitnan'); %,'Endpoints','discard'
    % STAmovmean = [movmean(SIGabs(1:STA-1),STA-1,'omitnan');movmean(SIGabs,STA,'omitnan','Endpoints','discard')];
    % LTAmovmean = [movmean(SIGabs(1:LTA-1),LTA-1,'omitnan');movmean(SIGabs,LTA,'omitnan','Endpoints','discard')];
    STALTA = STAmovmean./LTAmovmean;

    % Evaluaci�n STA/LTAmean no sea NaN
    for i = 1:M
        if winclean(i) == 1
            if sum(isnan(STALTA(vi(i):vf(i)))) > 0
                winclean(i) = 0;
            end
        end
    end

    % Evaluaci�n STA/LTAmean > Smax
    for i = 1:M
        if winclean(i) == 1
            if max(STALTA(vi(i):vf(i))) >= Smax || max(STALTA(vi(i):vf(i))) <= Smin
                winclean(i) = 0;
            end
        end
    end

    % figure
    % t = (0:dt:(N-1)*dt).';
    % subplot(2,1,1)
    % plot(t,STALTA)
    % line([t(1) t(end)],[Smax Smax],'color','g')
    %
    % subplot(2,1,2)
    % plot(t,SIG,'b'); hold on
    % for i = 1:M
    %     if winclean(i) == 1
    %         tp = t(vi(i):vf(i));
    %         SIGp = SIG(vi(i):vf(i));
    %         plot(tp,SIGp,'r'); hold on
    %     end
    % end
    % plot(t,STAmovmean,'k',t,LTAmovmean,'y','linewidth',1.5); hold on
    % 1;

elseif Smax == 0
    % Calcula STA y LTA en toda la se�al
    STA = tSTA/dt;
    LTA = tLTA/dt;
    STAmovmean = movmean(SIGabs,STA,'omitnan'); %,'Endpoints','discard'
    LTAmovmean = movmean(SIGabs,LTA,'omitnan'); %,'Endpoints','discard'
    STALTA = STAmovmean./LTAmovmean;

    % Evaluaci�n STA/LTAmean no sea NaN
    for i = 1:M
        if winclean(i) == 1
            if sum(isnan(STALTA(vi(i):vf(i)))) > 0
                winclean(i) = 0;
            end
        end
    end

    % Evaluaci�n STA/LTAmean > Smax
    for i = 1:M
        if winclean(i) == 1
            if max(STALTA(vi(i):vf(i))) <= Smin
                winclean(i) = 0;
            end
            if mode(STALTA(vi(i):vf(i))) == 0
                winclean(i) = 0;
            end
        end
    end
end