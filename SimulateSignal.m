Fs = 100;
t = 0:1/Fs:30-(1/Fs);
freq1 = 5;
freq2 = 5;
x = sin(2*pi*freq1*t)' + sin(2*pi*freq2*t)';
figure;plot(t,x,'r')

% add noise

noise = normrnd(0,1,length(x),1);
x_noise = x + noise;

% hold on;plot(t,x_noise,'k')

%% Cut to segments

SegmentLength = 5; % seconds
NumSegments = floor(length(x_noise)/(SegmentLength * Fs));

for scount = 1:NumSegments
    x_segment(scount,:) = x_noise(((scount-1)*SegmentLength*Fs + 1):((scount)*SegmentLength*Fs));
end
x_noise = x_segment';

%% set multi-taper power spectrum parameters

param.tapers = [3 5];% [5 9];
param.Fs = 100; % Hz
param.fpass = [0 50];
param.pad = 0;
param.err = [2 0.05];
param.trialave = 1;

% for spectrogram
param.movingwin = [1 0.1];
param.method = 'spec';

%% call the multi-taper power spectrum function

[S_mt_ch, f_mt, t, Serr] = PowerSpectrum(x_noise,param);

%% display power spectrum

plot(f_mt,10*log10(S_mt_ch),'color',[0,0,0]);hold on
plot(f_mt,10*log10(Serr(1,:)'),'-','color',[0.8 0.2 0.2]);hold on
plot(f_mt,10*log10(Serr(2,:)),'-','color',[0.8 0.2 0.2]);hold on

% figure;errorbar(f_mt,10*log10(S_mt_ch),10*log10(S_mt_ch) - 10*log10(Serr(1,:)'),10*log10(Serr(2,:)') - 10*log10(S_mt_ch),'k')
