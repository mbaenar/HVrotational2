clear

cargar_rutas_locales
addpath('utils')

listest0 = dir(fullfile(rutahv));
bal = [listest0.isdir]';
listest0 = {listest0.name}';
listest = listest0(bal);
bal = find(ismember(listest,[{'.'};{'..'}])==1);
listest(bal) = [];

fid = fopen(rutaestac);
textscan(fid,'%s',3);
estacRED = textscan(fid,'%s %f %f %*[^\n]');
fclose(fid);
vecest = estacRED{1};
latest = estacRED{3};
lonest = estacRED{2};

buscar = listest;
% buscar = {'TOME'};

listabal = cell2mat(listest);
[~,Nbuscar] = ismember(buscar,listabal);
Nest = length(buscar);

figure(100)
hjet = colormap(jet);
close(100)

figure(100)
hhot = colormap(flipud(hot));
hhot = hhot(10:end,:);
close(100)

f0lista = [];
Ntetalista = [];
Ntetalista2 = [];
gamamaxlista = [];
gamaminlista = [];
leyenda = [];
suav = 0;   %0=no; 1=sí
fs = 12;
porc = length(hjet(:,1))/length(buscar);
for k = 1:length(buscar)
    estac = listest{Nbuscar(k)};
    fprintf(1,'%d%s%d%s%s\n',k,'/',length(buscar),' --> ',estac);

    listreg = dir(fullfile(rutahv,estac,'*.mat'));
    listreg = {listreg.name}';
    listreg = strrep(listreg,'.mat','');

    load(fullfile(rutahv,estac,listreg{1}));
    tetavec = HV.tetarot;
    HVtot = HV.HVtot_comb1;
    HVdir = HV.HVdir_comb1;
    f = HV.f_comb1;

    ind90 = (length(tetavec)+1)/2;
    if suav == 1
        Nsuav = fix(length(find(f>=0.1,1):find(f>=0.2,1))/4);
        for i = 1:length(HVdir(:,1))
            HVdir(i,:) = fsuavi(HVdir(i,:).',f,Nsuav,fs);
        end
        HVtot = fsuavi(HVtot,f,Nsuav,fs);
    end
    HVdircont = HVdir([ind90:end,2:ind90],:);

    % figure(200)
    % col = fix(porc*k);
    % if col > length(hjet(:,1)); col = length(hjet(:,1)); end
    % if col < 1; col = 1; end
    % loglog(f,HVtot,'color',hjet(col,:)); hold on; grid on
    % xlabel('Frequency, $f$ (Hz)','fontname','Times New Roman','fontsize',14,'interpreter','latex')
    % ylabel('$H/V$ amplitude','fontname','Times New Roman','fontsize',14,'interpreter','latex')
    % leyenda = [leyenda;estac];
    % legend(leyenda,'numcolumns',2)
    % set(gcf,'color','white')
    % set(gca,'fontname','Times New Roman','fontSize',14)
    % xlim([0.1,50])

    flim1 = f(1); %20
    flim2 = f(end);
    Nflim1 = find(f>=flim1,1,'first');
    Nflim2 = find(f>=flim2,1,'first');
    [~,Nfmax0] = max(HVtot(Nflim1:Nflim2));

    % Nfmax0 = 18;
    % Nflim1 = 1;

    Nfmax = Nfmax0+Nflim1-1;
    flim3 = f(Nfmax)-0.0; %0.17
    flim4 = f(Nfmax)+0.0; %0.22
    Nf1 = find(f>=flim3,1); %
    Nf2 = find(f>=flim4,1); %
    flim1graf = f(1);  % para graficar
    flim2graf = f(end);  % para graficar
    paso = 1;
    Ntickmax = 6;

    f0lista = [f0lista;f(Nfmax)];
    colfill = 'k';

    Nflim1graf = find(f>=flim1graf,1,'first');
    Nflim2graf = find(f>=flim2graf,1,'first');

    if f(Nf1) < flim1; Nf1 = Nflim1; end
    if f(Nf2) > flim2; Nf2 = Nflim2; end
    gamanumerador = abs((HVdir(:,Nf1:Nf2))-(HVdircont(:,Nf1:Nf2)));
    gamadenominador = zeros(length(tetavec),Nf2-Nf1+1);
    cont = 0;
    for kk = Nf1:Nf2
        cont = cont+1;
        for gg = 1:length(tetavec)
            bal = min([HVdir(gg,kk),HVdircont(gg,kk)]);
            gamadenominador(gg,cont) = bal;
        end
    end
    gamamean = mean(gamanumerador./gamadenominador,2);
    gamamode = mode(gamanumerador./gamadenominador,2);
    gama = gamamean;

    [gamamax0,Ntetamax0] = maximos(gama,2);
    if length(Ntetamax0) == 1
        Ntetamax0 = [Ntetamax0;length(tetavec)];
        gamamax0 = [gamamax0;gama(end)];
    end
    [~,Norden] = sort(gamamax0);
    Norden = Norden(end-1:end);
    gamamax = gama(Ntetamax0(Norden));
    gamamaxlista = [gamamaxlista;gamamax(end)];
%     [~,bal] = max(HVdircont(Ntetamax0(Norden),Nf1:Nf2));
%     Nteta = Ntetamax0(Norden(bal));
    [~,bal1] = max(HVdircont(:,Nf1:Nf2));
    [~,bal2] = max(max(HVdircont(:,Nf1:Nf2)));
    Nteta = bal1(bal2);
    
    [gamamin0,Ntetamin0] = minimos(gama,2);
    if length(Ntetamin0) == 1
        Ntetamin0 = [1;Ntetamin0];
        gamamin0 = [gama(1);gamamin0];
    end
    [~,Norden2] = sort(gamamin0);
    Norden2 = Norden2(1:2);
    gamamin = gama(Ntetamin0(Norden2));
    if abs(tetavec(Ntetamin0(Norden2(1)))-tetavec(Ntetamin0(Norden2(2)))) < 85
        Norden2(2) = [];
        gamamin(2) = [];
        Ntetamin0 = [1;Ntetamin0];
        gamamin0 = [gama(1);gamamin0];
    end
    [~,Norden2] = sort(gamamin0);
    Norden2 = Norden2(1:2);
    gamamin = gama(Ntetamin0(Norden2));
    gamaminlista = [gamaminlista;gamamin(1)];
    Nteta2 = min(Ntetamin0(Norden2));

    Ntetalista = [Ntetalista;Nteta];
    Ntetalista2 = [Ntetalista2;Nteta2];

    %% Figuras
    figure(k+200)
    tiledlayout(2,2);
    set(gcf,'position',get(0,'Screensize'))
    % if k == 1
    %     h = tiledlayout(2,3);%
    % end

    nexttile
    HVSRdib = HVdircont;
    contourf(f(Nflim1graf:Nflim2graf),tetavec,HVSRdib(:,Nflim1graf:Nflim2graf),'linecolor','none'); shading interp
    line([flim1graf flim2graf],[90 90],'color','k')
    view([0 0 1])
    % xlim([0.01 f(end)])
    xlim([flim1graf flim2graf])
    ylim([0 180])
    title(estac,'fontname','Times New Roman','fontSize',14,'interpreter','latex')
    xlabel('Frequency, $f$ (Hz)','fontname','Times New Roman','fontsize',14,'interpreter','latex')
    ylabel('Rotation angle, $\varphi$ (deg)','fontname','Times New Roman','fontsize',14,'interpreter','latex')
    set(gca,'xscale','log')
    set(gca,'ytick',0:30:180)
    set(gca,'fontname','Times New Roman','fontsize',14)
    set(gcf,'color','white')
    grid on
    colormap(jet)
    cb = colorbar;
    clim([0 (max(max(HVSRdib(:,Nflim1graf:Nflim2graf))))])
    cb.Label.String = '$H/V$ amplitude';
    set(cb,'fontname','Times New Roman','fontSize',14)
    set(cb.Label,'interpreter','latex')
    % text(30,-37,[{'$H^\prime/V(\varphi,f)$'};{'amplitude'}],'fontname','Times New Roman', ...
    %     'fontsize',14,'interpreter','latex','verticalalignment','bottom')

    nexttile
    % for iii = 1:length(tetavec)
    %     Nteta = iii;
    semilogx(f(Nflim1graf:Nflim2graf),HVtot(Nflim1graf:Nflim2graf),'k','linewidth',1); hold on
    semilogx(f(Nflim1graf:Nflim2graf),HVdircont(Nteta,Nflim1graf:Nflim2graf),'r','linewidth',1); hold on
    semilogx(f(Nflim1graf:Nflim2graf),HVdir(Nteta,Nflim1graf:Nflim2graf),'--b','linewidth',1); hold on
    limy = max(HVtot(Nflim1graf:Nflim2graf));
    fill(f([Nf1,Nf2,Nf2,Nf1,Nf1]),[0,0,limy,limy,0],colfill,'facealpha',0.2); hold on
    xlim([flim1graf flim2graf])
    % ylim([0 20]) %[0 limy+3]
    % title([num2str(tetavec(Nteta)),' deg'],'fontname','Times New Roman','fontSize',11)
    xlabel('Frequency, $f$ (Hz)','fontname','Times New Roman','fontsize',14,'interpreter','latex')
    ylabel('$H/V$ amplitude','fontname','Times New Roman','fontsize',14,'interpreter','latex')
    texto = [{['f = ',num2str((round(f(Nfmax)*100)/100)),' Hz']}, ...
        {['γ = ',num2str((round(gamamax(end)*10000)/10000)*100),'%']}];
    text(f(Nfmax),1,texto,'fontname','Times New Roman','fontsize',14)
    %     if k == 1 || k == 2
    % text(0.2,1.5,['\gamma = ',num2str((round(gamamax(end)*10000)/10000)*100),'%'],'fontname','Times New Roman','fontsize',14)
    %     end
    set(gca,'xscale','log')
    set(gca,'fontname','Times New Roman','fontsize',14)
    set(gcf,'color','white')
    grid on
    tetamod = tetavec(Nteta)+90;
    if tetamod > 180;tetamod = tetamod-180; end
    % leg = legend('$H/V$ total',['$H^\prime/V(\varphi,f), \varphi=',num2str(tetavec(Nteta)),'^o$'],['$H^\prime/V(\varphi,f), \varphi=',num2str(tetamod),'^o$'],[num2str(flim3),' Hz$\leq f\leq$',num2str(flim4),' Hz']);
    leg = legend('$H/V$ total',['$H^\prime/V(\varphi,f), \varphi=',num2str(tetavec(Nteta)),'^o$'],['$H^\prime/V(\varphi,f), \varphi=',num2str(tetamod),'^o$']);
    set(leg,'fontname','Times New Roman','fontSize',13,'interpreter','latex')

    saveas(gcf,[rutahv,estac,'.png'])
    % print(gcf,[rutahv,estac],'-dpng','-r300')

    listafrec(k,:) = [str2num(estac(3:end)) f(Nfmax)];
end
% figure(200)
% saveas(gcf,[rutahv,'HV.png'])

tetastr = num2str(tetavec(Ntetalista).');

T0lista = 1./f0lista;
maxT0lista = max(T0lista);
minT0lista = min(T0lista);

%% Mapa con resultados de cada estación
lx = abs(min(lonest)-max(lonest))*0.3;
ly = abs(min(lonest)-max(lonest))*0.3;
MapLatLimit = [min(latest)-ly max(latest)+ly];
MapLonLimit = [min(lonest)-lx max(lonest)+lx];

figure(500)
geolimits(MapLatLimit,MapLonLimit)
geobasemap satellite
tamanofuente = 18;
porc = length(hjet(:,1))/maxT0lista;
for k = 1:length(buscar)
    % filacolor = fix(porc*T0lista(k));
    % if filacolor > length(hjet(:,1)); filacolor = length(hjet(:,1)); end
    % if filacolor < 1; filacolor = 1; end
    
    estac = listest{Nbuscar(k)};
    [~,bal] = ismember(estac,vecest);
    lat(k,1) = latest(bal);
    lon(k,1) = lonest(bal);

    col = 'white';
    escmax = (gamamaxlista(k)/2)/3000;
    plot_arrow_geoplot([lat(k),lon(k)],[lat(k)-sind(tetavec(Ntetalista(k)))*escmax,lon(k)-cosd(tetavec(Ntetalista(k)))*escmax],'color',col,'LineWidth',3); hold on
    plot_arrow_geoplot([lat(k),lon(k)],[lat(k)+sind(tetavec(Ntetalista(k)))*escmax,lon(k)+cosd(tetavec(Ntetalista(k)))*escmax],'color',col,'LineWidth',3); hold on
    plot_arrow_geoplot([lat(k),lon(k)],[lat(k)-sind(tetavec(Ntetalista(k)))*escmax,lon(k)-cosd(tetavec(Ntetalista(k)))*escmax],'color','r','LineWidth',1.5); hold on
    plot_arrow_geoplot([lat(k),lon(k)],[lat(k)+sind(tetavec(Ntetalista(k)))*escmax,lon(k)+cosd(tetavec(Ntetalista(k)))*escmax],'color','r','LineWidth',1.5); hold on

    % geoplot([lat(k),lat(k)-sind(tetavec(Ntetalista(k)))*escmax],[lon(k),lon(k)-cosd(tetavec(Ntetalista(k)))*escmax],col,'LineWidth',3); hold on
    % geoplot([lat(k),lat(k)+sind(tetavec(Ntetalista(k)))*escmax],[lon(k),lon(k)+cosd(tetavec(Ntetalista(k)))*escmax],col,'LineWidth',3); hold on

    text(lat(k),lon(k)+0.00002,estac,'color','white','fontname','Times New Roman','fontSize',14); hold on
end
geoplot(lat,lon,'.','markersize',20,'linewidth',2,'MarkerEdgeColor','white','markerfacecolor','none'); hold on;  % col(prof(jj),:)
geolimits(MapLatLimit,MapLonLimit)
Tmin = num2str(round(1/flim4*10)/10);
Tmax = num2str(round(1/flim3*10)/10);
title(['$\gamma_{max}$ (',Tmin,' s $\leq T_s \leq$ ',Tmax,' s)'],'fontname','Times New Roman','fontSize',tamanofuente,'interpreter','latex')
% set(gcf,'Position',get(0,'Screensize'))
set(gcf,'Position',[1.8,49.8,766.4,732.8])
set(gcf,'color','white')
set(gca,'fontname','Times New Roman','fontSize',tamanofuente)

% saveas(gcf,[rutahv,'mapaHVdir.png'])
