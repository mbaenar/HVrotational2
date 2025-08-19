function SIG_fil = filtsig(SIG,dt,w1,w2,factap)
% SIG = VE;
N = length(SIG);
fmax = 1/(2*dt);
if N*factap < 2; factap = 2/N; end

% Taper a la se�al
taperini = factap*100; %0.1 5
taperfin = factap*100; %0.1 5
SIG_tap_int = taper_fun(SIG,taperfin,0,1);
SIG_tap = taper_fun(SIG_tap_int,taperini,1,0);

% % Revisar este Taper a la se�al
% SIG_tap = SIG.*tukeywin(N,factap);

% Dise�o del filtro Butterworth
norden = 6;
% [b,a] = butter(norden,[w1 w2]./fmax);
[z,p,k] = butter(norden,[w1 w2]./fmax,'bandpass');  % Butterworth filter
[sos,g] = zp2sos(z,p,k);
% fvtool(b,a); hold on
% fvtool(sos);

% Padding (cf. Boore, 2005)
Tpad = 1.5*norden/w1;
Tpad = ceil(Tpad/2)*2;
Npad = round(Tpad./dt);
Ntot_pad = N+Npad;
pad = round(Npad/2);

% Adici�n de "pad"s en los extremos de la se�al
SIG_pad = [zeros(pad,1);SIG_tap;zeros(pad,1)];

% Aplicaci�n del filtro
% SIG_fil1 = filtfilt(b,a,SIG_pad);
SIG_fil1 = filtfilt(sos,g,SIG_pad);

% Eliminaci�n "pad"s en los extremos de la se�al
SIG_fil = SIG_fil1(pad+1:N+pad);

% % Longitud de los vectores par
% N = length(SIG_fil);
% if rem(N,2) ~= 0
%     SIG_fil = SIG_fil(1:end-1);
% end

% % Taper ���NUEVO, REVISAR!!!
% tap = tukeywin(length(SIG_fil),factap);
% SIG_fil = SIG_fil.*tap;
