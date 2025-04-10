function plot_figura300(EWrot,NSrot,VE,Ndias,dt,wincleantot,iv,fv,Smax,STALTANS,STALTAEW,STALTAVE)

for p = 1:Ndias
    figure(300);
    set(gcf,'Position',get(0,'Screensize'));
    fig = tiledlayout(3,2,'TileSpacing','tight','Padding','tight');

    t = (0:dt:(length(EWrot{p})-1)*dt).';

    nexttile(1)
    plot(t,STALTANS{p},'k'); hold on; grid on
    line([t(1) t(end)],[Smax Smax],'color','r','linestyle','--','linewidth',2)
    set(gca,'YTick',0:1:3)
    % set(gca,'XTickLabel',[])
    ylabel('NS','fontname','Times New Roman','fontSize',14)
    xlim([t(1) t(end)])
    ylim([0 11])
    set(gca,'fontname','Times New Roman','fontSize',14);

    nexttile(3)
    plot(t,STALTAEW{p},'k'); hold on; grid on
    line([t(1) t(end)],[Smax Smax],'color','r','linestyle','--','linewidth',2)
    set(gca,'YTick',0:1:3)
    % set(gca,'XTickLabel',[])
    ylabel('EW','fontname','Times New Roman','fontSize',14)
    xlim([t(1) t(end)])
    ylim([0 11])
    set(gca,'fontname','Times New Roman','fontSize',14);

    nexttile(5)
    plot(t,STALTAVE{p},'k'); hold on; grid on
    line([t(1) t(end)],[Smax Smax],'color','r','linestyle','--','linewidth',2)
    set(gca,'YTick',0:1:3)
    ylabel('VE','fontname','Times New Roman','fontSize',14)
    xlabel('Time (s)','fontname','Times New Roman','fontSize',14)
    xlim([t(1) t(end)])
    ylim([0 11])
    set(gca,'fontname','Times New Roman','fontSize',14);
    h1 = plot(0,0,'k');
    h2 = plot(0,0,'--r','linewidth',2);
    % lg = legend([h1 h2],'STA/LTA',['(STA/LTA)max = ',num2str(Smax)]);
    % set(lg,'location','south outside','fontname','Times New Roman','fontSize',14)

    %--------------------------------------------------
    NSm = NSrot{p};
    EWm = EWrot{p};
    VEm = VE{p};
    % ml = max([max(abs(NSm)) max(abs(EWm)) max(abs(VEm))]);
    ml = 1;
    limy = max([mean(abs(NSm)) mean(abs(EWm)) mean(abs(VEm))])*10;

    nexttile(2)
    plot(t,NSm/ml,'k'); hold on; grid on
    ylabel('NS','fontname','Times New Roman','fontSize',14)
    xlim([t(1) t(end)])
    ylim([-limy limy]) %[-1 1]
    % set(gca,'YTick',[-0.02,0,0.02])
    % set(gca,'XTickLabel',[])
    set(gca,'fontname','Times New Roman','fontSize',14)

    nexttile(4)
    plot(t,EWm/ml,'k'); hold on; grid on
    ylabel('EW','fontname','Times New Roman','fontSize',14)
    xlim([t(1) t(end)])
    ylim([-limy limy]) %[-1 1]
    % set(gca,'YTick',[-0.02,0,0.02])
    % set(gca,'XTickLabel',[])
    set(gca,'fontname','Times New Roman','fontSize',14)

    nexttile(6)
    plot(t,VEm/ml,'k'); hold on; grid on
    ylabel('VE','fontname','Times New Roman','fontSize',14)
    xlabel('Time (s)','fontname','Times New Roman','fontSize',14)
    xlim([t(1) t(end)])
    ylim([-limy limy]) %[-1 1]
    % set(gca,'YTick',[-0.02,0,0.02])
    set(gca,'fontname','Times New Roman','fontSize',14)

    ind = find(wincleantot{p}==1);
    for kk = 1:length(ind)
        q = ind(kk);
        nexttile(2)
        fill([t(iv{p}(q)),t(fv{p}(q)),t(fv{p}(q)),t(iv{p}(q)),t(iv{p}(q))], ...
            [-1,-1,1,1,-1]*limy,'b','edgecolor','b','facealpha',0.5) ; hold on

        nexttile(4)
        fill([t(iv{p}(q)),t(fv{p}(q)),t(fv{p}(q)),t(iv{p}(q)),t(iv{p}(q))], ...
            [-1,-1,1,1,-1]*limy,'b','edgecolor','b','facealpha',0.5) ; hold on

        nexttile(6)
        fill([t(iv{p}(q)),t(fv{p}(q)),t(fv{p}(q)),t(iv{p}(q)),t(iv{p}(q))], ...
            [-1,-1,1,1,-1]*limy,'b','edgecolor','b','facealpha',0.5) ; hold on

        set(gcf,'color','white')
    end
    
    % maybe display sum(wincleantot{p})
    pause()
end
