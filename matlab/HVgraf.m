clear

cargar_rutas_locales
addpath('utils')
sep = obtener_separador_linux_window();

listest0 = dir(rutahv);
bal = [listest0.isdir]';
listest0 = {listest0.name}';
listest = listest0(bal);
bal = find(ismember(listest,[{'.'};{'..'}])==1);
listest(bal) = [];

buscar = listest;
% buscar = {'AL01'};

%%
figure(100)
hjet = colormap(jet);
close(100)

figure(100)
hhot = colormap(flipud(hot));
hhot = hhot(10:end,:);
close(100)

flim = {'BJVM' 1.5 2.5
    'ICVM' 0.2 0.4
    'THVM' 0.14 0.24
    'VRVM' 0.25 0.45
    'AL01' 0.3 0.7
    'SCT2' 0.5 1
    'CJ03' 0.3 1
    'LI33' 0.1 0.24
    'LV17' 0.3 0.66
    'MY19' 0.1 0.3
    'EEEE' 0.1 5};

[~,Nbuscar] = ismember(buscar,listest);
porc = length(hjet(:,1))/length(buscar);
suav = 0;   %0=no; 1=sí
Nsuav = 0; %fix(50001*0.0005);
fs = 12;
leyenda = [];
archivo = [];
clave = [];
cont = 0;
for ee = 1:length(buscar)
    estac = listest{Nbuscar(ee)};

    fprintf(1,'%d%s%d%s%s\n',ee,'/',length(buscar),' --> ',estac);
    if Nbuscar(ee) == 0; continue; end

    listreg = dir([rutahv,estac,sep,'*.mat']);
    listreg = {listreg.name}';

    % leyenda = [];
    kk = 0;
    leg = [];
    for k = 1:length(listreg)
        load([rutahv,estac,sep,listreg{k}]);
        HVtot = HV.HVtot_comb1;
        f = HV.f_comb1;
        Nvent = HV.Nvent{1};
        fecha = HV.paraadic.fechahms{1};
        fecha = strrep(fecha,'_','');

        if Nvent < 20
            fprintf(1,'%s%s\n','revisar Nvent<20',listreg{k});
        end
        if isnan(HV.HVtot_comb1)
            fprintf(1,'%s%s\n','revisar isnan(HV)',listreg{k});
        end

        % if Nvent >= 10
        kk = kk+1;
        [~,Nest] = ismember(estac,flim(:,1));
        if Nest == 0; [~,Nest] = ismember('EEEE',flim(:,1)); end
        Nf1 = find(f>=flim{Nest,2},1);
        Nf2 = find(f>=flim{Nest,3},1);
        if suav == 1
            % Nsuav = fix(length(find(f>=0.1,1):find(f>=0.2,1))/4);
            HVtot = fsuavi(HVtot,f,Nsuav,fs);
        end
        [Apico,Nmax] = max(HVtot(Nf1:Nf2));
        fpico = f(Nmax+Nf1-1);
        Tpico = 1/fpico;

        % figure(ee) %(100)
        % col = fix(porc*ee);
        % if col > length(hjet(:,1)); col = length(hjet(:,1)); end
        % if col < 1; col = 1; end
        % plot(f,HVtot,'linewidth',2); hold on; grid on %,'color',hjet(col,:)
        % str = ['HVSR from ASN ',estac];
        % title(str,'fontname','Times New Roman','fontSize',13);
        % xlabel('Periodo (s)','fontname','Times New Roman','fontsize',13)
        % ylabel('Amplitude','fontname','Times New Roman','fontsize',13)
        % xlim([0 10]) %[f(1) f(end)]
        % % ylim([0 10])
        % % set(gca,'xtick',0:2:10) %0.1,1,10
        % % leyenda = [leyenda;estac];
        % % legend(leyenda,'numcolumns',2)
        % leg = [leg;{[estac,'-',fecha,' Nw',num2str(Nvent)]}];
        % legend(leg,'interpreter','tex','Location','northeast'); %'southwest'
        % set(gca,'fontname','Times New Roman','fontSize',13)
        % set(gcf,'color','white')
        % % drawnow
        % % end

        % cont = cont+1;
        % conttxt = ['00',num2str(cont)];
        % conttxt = ['HV',conttxt(end-1:end)];
        % clave = HV.clavecomb(1);
        % % dlmwrite([rutahv(1:end-1),'txt\',conttxt,'.txt'],clave,'delimiter','');
        % dlmwrite([rutahv(1:end-1),'txt\',conttxt,'.txt'],['f (Hz)','        H/V amplitud'],'delimiter','');
        % dlmwrite([rutahv(1:end-1),'txt\',conttxt,'.txt'],[f(1:501) HVtot(1:501)],'-append','delimiter','\t','precision','%8.4f')

        % archivo = [archivo HVtot];
        % clave = [clave;{HV.clavecomb}];
    end
end
