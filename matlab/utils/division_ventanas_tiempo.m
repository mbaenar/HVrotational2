function [EWv,NSv,VEv] = division_ventanas_tiempo(EWrot,NSrot,VE, ...
    ptosvent,Nventefec,wincleantot,iv,fv)

EWv = (zeros(ptosvent,Nventefec));
NSv = (zeros(ptosvent,Nventefec));
VEv = (zeros(ptosvent,Nventefec));
cont = 0;
for p = 1:length(VE)
    ind = find(wincleantot{p}==1);
    for kk = 1:length(ind)
        q = ind(kk);
        cont = cont+1;
        EWv(:,cont) = EWrot{p}(iv{p}(q):fv{p}(q));
        NSv(:,cont) = NSrot{p}(iv{p}(q):fv{p}(q));
        VEv(:,cont) = VE{p}(iv{p}(q):fv{p}(q));
    end
end
