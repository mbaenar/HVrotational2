function [EWv, NSv, VEv, fechahmsvent] = division_ventanas_tiempo(EWrot,NSrot,VE,vecfechahms,ptosvent,Nventefec,Narch,wincleantot,iv,fv)

EWv = (zeros(ptosvent,Nventefec));
NSv = (zeros(ptosvent,Nventefec));
VEv = (zeros(ptosvent,Nventefec));
fechahmsvent = cell(Nventefec,1);
cont = 0;
for p = 1:Narch
    ind = find(wincleantot{p}==1);
    for kk = 1:length(ind)
        q = ind(kk);
        cont = cont+1;
        EWv(:,cont) = EWrot{p}(iv{p}(q):fv{p}(q));
        NSv(:,cont) = NSrot{p}(iv{p}(q):fv{p}(q));
        VEv(:,cont) = VE{p}(iv{p}(q):fv{p}(q));
        fechahmsvent(cont,1) = {[vecfechahms{p},'_',num2str(q)]};
    end
end
