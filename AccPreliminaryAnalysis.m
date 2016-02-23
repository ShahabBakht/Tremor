%% read real data
datalocation = 'C:\Users\labuser\Documents\GENEActiv\Data\';
filename = 'Shahab_right wrist_026397_2016-02-23 08-26-15.csv';
[time, x, y, z] = OpenAccFile([datalocation filename]);
xnd = detrend((x-min(x))./(max(x)-min(x)),'linear');
ynd = detrend((y-min(y))./(max(y)-min(y)),'linear');
znd = detrend((z-min(z))./(max(z)-min(z)),'linear');
r = [xnd,ynd,znd];
[coeff,score,latent] = pca(r);
x_noise = score(:,1);

%% show raw data 
Fs = 100;
Epoch = 60 * Fs;
figure;plot(x_noise,'b');title('raw data - select the start and the end of each trial!');

%% select and cut the trials and conditions
NumTrials = 3;
NumConditions = 2;
[t_init,x_init] = ginput(NumTrials * NumConditions * 2);

figure('Position',[0 558 560 420]);
plot(x_noise,'k');hold on;
for epochcount = 1:(NumTrials * NumConditions)
    
    if mod(epochcount,2) == 0
        c = [0 0 1];
    else
        c = [1 0 0];
    end
    
    p = patch([t_init(epochcount*2-1),t_init(epochcount*2),t_init(epochcount*2),t_init(epochcount*2-1)],...
        [-0.5,-0.5,1,1],c);
    alpha(p,.1);
    
end
title('Raw Data - selected epochs');xlabel('time (10 ms)')


trcount1 = 0;
trcount2 = 0;
condcount = 0;

for epochcount = 1:(NumTrials * NumConditions)
    
    if mod(epochcount,2) == 0
        condcount = 2;
        trcount2 = trcount2 + 1;
        trcount = trcount2;
    else
        condcount = 1;
        trcount1 = trcount1 + 1;
        trcount = trcount1;
    end
    X{condcount,trcount} = x_noise(t_init(2*epochcount - 1):t_init(2*epochcount));
    X{condcount,trcount} = detrend(X{condcount,trcount},'linear');
%     plot(X{condcount,trcount});hold on;plot(detrend(X{condcount,trcount},'linear'));pause;close all
   
end

%% Cut to segments
% X_segment cell contains all the segments for each condition separately.

SegmentLength = 5; % second
for condcount = 1:size(X,1)
    X_segmenttemp = [];
    for trcount = 1:size(X,2);
        xtemp = X{condcount,trcount};
        L = length(xtemp);
        NumSegments = floor(L/(SegmentLength * Fs));
        for scount = 1:NumSegments
            x_segment(scount,:) = xtemp(((scount-1) * SegmentLength * Fs + 1):((scount) * SegmentLength * Fs)); 
        end
        X_segmenttemp = [X_segmenttemp;x_segment];
    end
    X_segment{condcount} = X_segmenttemp';
    
end

%% set multi-taper power spectrum parameters

param.tapers = [7,13];
param.Fs = 100; % Hz
param.fpass = [2 20];
param.pad = 0;
param.err = [2 0.05];
param.trialave = 1;

% for spectrogram
param.movingwin = [1 0.1];
param.method = 'spec';

% which condition?
% WhichCondition = 1; % 1 for rest 2 for posture

%% call the multi-taper power spectrum function

for WhichCondition = 1:2 % for both rest and posture
x_noise = X_segment{WhichCondition};
if WhichCondition == 1
    
    [S_mt_ch_rest, f_mt_rest, t_rest, Serr_rest] = PowerSpectrum(x_noise,param);
elseif WhichCondition == 2
    [S_mt_ch_posture, f_mt_posture, t_posture, Serr_posture] = PowerSpectrum(x_noise,param);
end

end

%% display power spectrum
figure('Position',[680 200 900 800]);
subplot(2,2,1);
plot(f_mt_rest,10*log10(S_mt_ch_rest),'color',[0,0,0],'LineWidth',2);hold on
plot(f_mt_rest,10*log10(Serr_rest(1,:)'),'-','color',[0.8 0.8 0.8]);hold on
plot(f_mt_rest,10*log10(Serr_rest(2,:)),'-','color',[0.8 0.8 0.8]);hold on
title('Rest Power Spectrum');xlabel('Frequency (Hz)')

subplot(2,2,2);
plot(f_mt_posture,10*log10(S_mt_ch_posture),'color',[1,0,0],'LineWidth',2);hold on
plot(f_mt_posture,10*log10(Serr_posture(1,:)'),'-','color',[1 0.8 .8]);hold on
plot(f_mt_posture,10*log10(Serr_posture(2,:)),'-','color',[1 0.8 .8]);hold on
title('Posture Power Spectrum');xlabel('Frequency (Hz)')

subplot(2,2,4);
plot(f_mt_rest,10*log10(S_mt_ch_rest),'color',[0,0,0],'LineWidth',2);hold on
plot(f_mt_rest,10*log10(Serr_rest(1,:)'),'-','color',[0.8 0.8 0.8]);hold on
plot(f_mt_rest,10*log10(Serr_rest(2,:)),'-','color',[0.8 0.8 0.8]);hold on
plot(f_mt_posture,10*log10(S_mt_ch_posture),'color',[1,0,0],'LineWidth',2);hold on
plot(f_mt_posture,10*log10(Serr_posture(1,:)'),'-','color',[1 0.8 .8]);hold on
plot(f_mt_posture,10*log10(Serr_posture(2,:)),'-','color',[1 0.8 .8]);hold on
title('Rest and Posture Overlapped Power Spectrum');xlabel('Frequency (Hz)') 

