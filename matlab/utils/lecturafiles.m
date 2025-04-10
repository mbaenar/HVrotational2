function [reg100,direc100,mps100,hmsnum100,sensor100] = lecturafiles(filesi,mpsselec,mpsselec2)

sep = obtener_separador_linux_window();

reg = [];
dir0 = [];
mps = [];
hmsnum = [];
sensor = [];
for j = 1:length(filesi)
    filesij = filesi{j};

    [~,~,extens] = fileparts(filesij);
    if ~ismember(extens,{'.sac';'.gcf';'.msd'})
        try
            ReadMSEEDFast(filesij);
            extens = '.msd';
        catch
            try
                bal = rdmseed(filesij);
                extens = '.msd';
            catch
                try
                    rdsac(filesij);
                    extens = '.sac';
                catch
                    bal = readgcffile2(filesij);
                    if isscalar(bal)
                        extens = '';
                    else
                        extens = '.gcf';
                    end
                end
            end
        end
    end
    if strcmp(extens,''); continue; end

    regj = [];
    % dirj = [];
    mpsj = [];
    hmsnumj = [];
    sensorj = [];
    if strcmp(extens,'.msd')
        try
            datos = ReadMSEEDFast(filesij);
            regj = datos.data;
            dirj0 = datos.channel;
            mpsj = datos.sampleRate;
            hmsnumj = datenum([datos.dateTime.year datos.dateTime.month datos.dateTime.day ...
                datos.dateTime.hour datos.dateTime.minute datos.dateTime.second]);
            sensorj = datos.station;

            ind = strfind(filesij,sep);
            rev(1) = {filesij(ind(end-1)+1:ind(end)-1)};
            rev(2) = {filesij(ind(end)+1:end-4)};
            rev(3) = {dirj0};
            if sum(ismember(rev,{'EHE';'HE';'E';'001';'006';'3E';'SHE';'ENE';'HNE'})) >= 1
                dirj0 = 'E';
            elseif sum(ismember(rev,{'EHN';'HN';'N';'002';'005';'2N';'SHN';'ENN';'HNN'})) >= 1
                dirj0 = 'N';
            elseif sum(ismember(rev,{'EHZ';'HZ';'Z';'003';'004';'1Z';'SHZ';'ENZ';'HNZ'})) >= 1
                dirj0 = 'Z';
            else
                continue
            end
        catch
            try
                datos = rdmseed(filesij);
                longregj = 0;
                for dd = 1:length(datos); longregj = longregj+length(datos(dd).d); end
                regj = zeros(longregj,1);
                dirj0 = datos(1).ChannelIdentifier;
                fin = 0;
                for dd = 1:length(datos)
                    long = length(datos(dd).d);
                    ini = fin+1;
                    fin = ini+long-1;
                    regj(ini:fin) = datos(dd).d;
                end
                mpsj = datos(1).SampleRate;
                hmsnumj = datos(1).RecordStartTimeMATLAB;
                sensorj = datos(1).StationIdentifierCode;

                ind = strfind(filesij,sep);
                rev(1) = {filesij(ind(end-1)+1:ind(end)-1)};
                rev(2) = {filesij(ind(end)+1:end-4)};
                rev(3) = {dirj0};
                if sum(ismember(rev,{'EHE';'HE';'E';'001';'006';'3E';'SHE';'ENE';'HNE'})) >= 1
                    dirj0 = 'E';
                elseif sum(ismember(rev,{'EHN';'HN';'N';'002';'005';'2N';'SHN';'ENN';'HNN'})) >= 1
                    dirj0 = 'N';
                elseif sum(ismember(rev,{'EHZ';'HZ';'Z';'003';'004';'1Z';'SHZ';'ENZ';'HNZ'})) >= 1
                    dirj0 = 'Z';
                else
                    continue
                end
            catch
                fprintf(1,'\t%s\n',['no se puede leer ',filesij]);
            end
        end

    elseif strcmp(extens,'.gcf')
        try
            [regj,sensorj,mpsj,hmsnumj] = readgcffile2(filesij);
            
            % ind = strfind(filesij,sep);
            % rev(1) = {filesij(ind(end-1)+1:ind(end)-1)};
            % rev(2) = {filesij(ind(end)+1:end-4)};
            % rev(3) = {sensorj};
            % if sum(contains(rev,{'e2';'e4';'E2';'E4'})) >= 1
            %     dirj0 = 'E';
            % elseif sum(contains(rev,{'n2';'n4';'N2';'N4'})) >= 1
            %     dirj0 = 'N';
            % elseif sum(contains(rev,{'z2';'z4';'Z2';'Z4'})) >= 1
            %     dirj0 = 'Z';
            % else
            %     continue
            % end
            dirj0 = sensorj;
        catch
            fprintf(1,'\t%s\n',['no se puede leer ',filesij]);
        end

    elseif strcmp(extens,'.sac')
        try
            [regj,hmsnumj,datos] = rdsac(filesij);
            regj = double(regj);
            dirj0 = datos.KCMPNM;
            mpsj = round(datos.DELTA*100)/0.01;
            sensorj = datos.KSTNM;
        catch
            fprintf(1,'\t%s\n',['no se puede leer ',filesij]);
        end
    end
    if isempty(regj); continue; end

    dirj0 = upper(dirj0);
    dirj0 = strrep(dirj0,'V','Z');
    % switch dirj0
    %     case {'HE';'EHE';'e';'E';'e2';'e4';'E2';'E4';'e0';'3E';'SHE';'ENE';'HNE';'BHE'}
    %         dirj = 'E';
    %     case {'HN';'EHN';'n';'N';'n2';'n4';'N2';'N4';'n0';'2N';'SHN';'ENN';'HNN';'BHN'}
    %         dirj = 'N';
    %     case {'HZ';'EHZ';'v';'z';'V';'Z';'z2';'z4';'Z2';'Z4';'z0';'1Z';'SHZ';'ENZ';'HNZ';'BHZ'}
    %         dirj = 'Z';
    % end
    % if isempty(dirj); dirj = dirj0; end

    reg = [reg;{regj}];
    dir0 = [dir0;dirj0];
    mps = [mps;mpsj];
    hmsnum = [hmsnum;hmsnumj];
    sensor = [sensor;{sensorj}];
end
ind100 = find(mps==mpsselec);
if isempty(ind100)
    ind100 = find(mps==mpsselec2);
end

if isempty(ind100)
    reg100 = [];
    direc100 = [];
    mps100 = [];
    hmsnum100 = [];
    sensor100 = [];
    return
else
    mps100 = mps(ind100(1));
    reg100 = reg(ind100);
    dir0100 = dir0(ind100,:);
    hmsnum100 = hmsnum(ind100);
    sensor100 = sensor(ind100);

    % mps200 = mps(ind200);
    % reg200 = reg(ind200);
    % dir0200 = dir0(ind200,:);
    % hmsnum200 = hmsnum(ind200);
    % sensor200 = sensor(ind200);
end

dir0 = dir0100;
direc100 = [];
pat = ["E","N","Z"];
if length(ind100) == 3
    if ~isempty(dir0)
        resta = dir0(1,:)-dir0;
        inddir = find(sum(resta)~=0);
        if ~isempty(inddir) && length(inddir) == 1
            dir2 = string(dir0(:,inddir)).';
            TF = contains(dir2,pat,'IgnoreCase',true);
            if sum(TF) == 3
                direc100 = dir2;
            end
        elseif ~isempty(inddir) && length(inddir) == 2
            dir2 = string(dir0(:,inddir)).';
            dir2 = strrep(dir2,'1',''); dir2 = strrep(dir2,'2',''); dir2 = strrep(dir2,'3','');
            TF = contains(dir2,pat,'IgnoreCase',true);
            if sum(TF) == 3
                direc100 = dir2;
            end
        end
    end
end
