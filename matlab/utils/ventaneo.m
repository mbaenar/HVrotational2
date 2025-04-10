function [Nventefec,M,iv,fv,wincleantot,wincleanEW,wincleanNS,wincleanVE, ...
    STALTAEW,STALTANS,STALTAVE] = ventaneo(porctrasl,ptosvent,EWrot,NSrot,VE,dt,tSTA, ...
    tLTA,Smax,Smin,Narch)

% VE = ESTR.VE;

Ntras = floor(porctrasl/100*ptosvent);
iv = {};
fv = {};
M = 0;
for p = 1:Narch
    Nn = length(VE{p});
    iv{p} = (1:ptosvent-Ntras:Nn).';
    fv{p} = iv{p}+ptosvent-1;
    elim = find(fv{p} > Nn);
    iv{p}(elim) = [];
    fv{p}(elim) = [];
    % rev = [iv{p} fv{p} fv{p}-iv{p}+1];
    M = M+length(iv{p});
end

% ELIMINA LAS VENTANAS MÁS ENERGÉTICAS DE LA SEÑAL EN SEGUNDOS
wincleantot = {};
Nventefec = 0;
for p = 1:Narch
    [wincleanEW{p},STALTAEW{p}] = picossig6(EWrot{p},dt,iv{p},fv{p},tSTA,tLTA,Smax,Smin);
    [wincleanNS{p},STALTANS{p}] = picossig6(NSrot{p},dt,iv{p},fv{p},tSTA,tLTA,Smax,Smin);
    [wincleanVE{p},STALTAVE{p}] = picossig6(VE{p},dt,iv{p},fv{p},tSTA,tLTA,Smax,Smin);
    wincleantot{p} = wincleanEW{p}.*wincleanNS{p}.*wincleanVE{p};
    Nventefec = Nventefec+sum(wincleantot{p});
end
