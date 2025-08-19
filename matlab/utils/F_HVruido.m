function [HVmean,NVmean,EVmean,NventHV,vini,tiempoHVnuevo,numHV,HVvent] = F_HVruido(f,fNSvent, ...
    fEWvent,fVEvent,segvent,porctrasl,tiempoHV,suav,ventaleatHV,NvBootstrap,ini,fin)

% Datos iniciales
[~,Nv] = size(fNSvent);
Nsuav = 0; %fix(N*0.001);
fs = 12; %50;

trasl = segvent*(porctrasl/100);
pasovent = floor((tiempoHV*60-segvent)/(segvent-trasl))+1;
if pasovent >= Nv
    vi = ones(1,NvBootstrap)*1;
    vf = ones(1,NvBootstrap)*Nv;
    tiempoHVnuevo = (segvent+(Nv-1)*(segvent-trasl))/3600;
else
    if ventaleatHV == 1
        % rng(2)
        vi = ceil((Nv-pasovent)*rand(1,NvBootstrap));
    else
        vi = 1:pasovent:Nv-pasovent;
        if NvBootstrap == 1
            vi = vi(1);
        end
    end
    vf = vi+pasovent-1;
    tiempoHVnuevo = (segvent+(pasovent-1)*(segvent-trasl))/3600;
end
rev1 = sum(vf>Nv);
rev2 = sum((vf-vi+1)<pasovent*0.70);
% if rev1 > 0 || rev2 > 0; disp('Revisar ventanas'); return; end

numHV = length(vi);
NventHV = vf-vi+1;
vini = vi(1);
fNSvent2 = abs(fNSvent(ini:fin,:)).^2;
fEWvent2 = abs(fEWvent(ini:fin,:)).^2;
fVEvent2 = abs(fVEvent(ini:fin,:)).^2;
fHHvent2 = abs(sqrt((fNSvent(ini:fin,:).^2+fEWvent(ini:fin,:).^2)/2)).^2;

% HV con Campos Difusos
% ---------------------
N = fin-ini+1;
HVvent = (zeros(N,numHV));
NVvent = (zeros(N,numHV));
EVvent = (zeros(N,numHV));
for i = 1:numHV
    vec = vi(i):vf(i);
    dNS = fNSvent2(:,vec);
    dEW = fEWvent2(:,vec);
    dVE = fVEvent2(:,vec);
    HVvent(:,i) = ((mean(dNS,2)+mean(dEW,2))./mean(dVE,2)).^0.5;
    NVvent(:,i) = (mean(dNS,2)./mean(dVE,2)).^0.5;
    EVvent(:,i) = (mean(dEW,2)./mean(dVE,2)).^0.5;
    
    % dHHsigma = (mean(((dNS+dEW)-repmat(mean(dNS,2)+mean(dEW,2),1,NventHV(1))).^2,2)).^0.5;
    % dHHsigma = (mean((dNS-repmat(mean(dNS,2),1,NventHV(1))).^2,2)).^0.5;
    % dVEsigma = (mean((dVE-repmat(mean(dVE,2),1,NventHV(1))).^2,2)).^0.5;
end
if suav == 1
    HVvent = fsuavi(HVvent,f,Nsuav,fs);
    NVvent = fsuavi(NVvent,f,Nsuav,fs);
    EVvent = fsuavi(EVvent,f,Nsuav,fs);
end

% ESTADÍSTICA --------------------
if numHV == 1
    HVmean = HVvent;
    NVmean = NVvent;
    EVmean = EVvent;
else
    HVmean = mean(HVvent,2);
    NVmean = mean(NVvent,2);
    EVmean = mean(EVvent,2);
end

% HVventNK = zeros(N,Nv);
% for i = 1:numHV
%     vec = vi(i):vf(i);
%     HVventNK = ((fNSvent2(:,vec)+fEWvent2(:,vec))./fVEvent2(:,vec)).^0.5;
% end
% for i = 1:Nv
%     HVventNK(:,i) = smooth(HVventNK(:,i),length(f)*0.1);
% end
% 
% HVmeanNK = mean(HVventNK,2);
% HVstdNK = std(HVventNK.');
% HVstdNK = suavfrec(HVstdNK,f,6);
