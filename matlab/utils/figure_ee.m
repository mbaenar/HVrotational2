function [leyenda] = figure_ee(ee,leyenda,HV,estac)

figure(ee)
N = length(HV.clavecomb);
for ic = 1:N
    f = HV.fcomb{ic};
    % finterp = (f(1):0.001:f(end)).';
    % HVmeaninterp = interp1(f,HV.HVmean_comb{ic},finterp,'makima');
    
    Nsuav = (find(f>=0.2,1,'first')-find(f>=0.1,1,'first'))/2;
    % HVmeansmooth1 = smooth(HV.HVmean_comb{ic},Nsuav);
    % HVmeansmooth2 = fsuavi(HV.HVmean_comb{ic},f,Nsuav,0);

    loglog(f,HV.HVmean_comb{ic},'linewidth',2); hold on; grid on
    % plot(finterp,HVmeaninterp,'linewidth',0.5); hold on %,'color',col(ic,:) hold on; grid on
    % plot(f,HVmeansmooth1,'linewidth',0.5); hold on %,'color',col(ic,:) hold on; grid on
    % plot(f,HVmeansmooth2,'linewidth',0.5); hold on %,'color',col(ic,:) hold on; grid on
    % semilogx(f,HV.NVmean_comb{ic},'linewidth',1.5); hold on; grid on
    % semilogx(f,HV.EVmean_comb{ic},'linewidth',1.5); hold on; grid on

    leyenda = [leyenda;{[estac,'-',HV.clavecomb{ic}]}];
end
leg = legend(leyenda);
title(['HVSR ',estac],'fontname','Liberation Serif','fontSize',12,'interpreter','none')
set(gca,'fontname','Liberation Serif','fontSize',12)
set(gcf,'color','white')
xlabel('Frecuencia (Hz)','fontname','Liberation Serif','fontSize',12)
ylabel('Amplitud H/V','fontname','Liberation Serif','fontSize',12)
maxyplot = get(gca,'ytick');
xlim([0 10]); %[min(f) max(f)] [0.01 10]
% set(gca,'xtick',[0,1:1:10]) %[0.1,1:1:10]
