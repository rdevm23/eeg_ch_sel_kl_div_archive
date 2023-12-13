%% Channel Selection Algorithm Using KL Divergence
% To be submitted in IEEE TBME
% Author - Raghav Dev @ IIT Delhi, rdevm23@gmail.com
% Copyright (C), Raghav Dev, IIT Delhi
% last modified on - 19th Oct, 2023
% Completely deterministic. Replicable 100%.

%% Parameters and filters


clear, clc

all_channels = 1:118;
n_channels = numel(all_channels);
filters_ON = 0;

dataset = extraction_bcic3_4a(all_channels);
dataset_filt = struct;
% Filtering
n_subs = 5;
fs = 1000;
if filters_ON == 1
for s = 1:n_subs
    
    signal_pre_proc = dataset(s).eeg;
    class = dataset(s).label;
    
    classify_obj = cls_classify_motorI(...
        signal_pre_proc,class,n_channels,fs);
    
    % Creating the filter
    if (s==1)
        classify_obj = classify_obj.create_filter();
        filter = classify_obj.filter;
    else
        classify_obj.filter = filter;
    end
    
    % Other Preprocessing
    classify_obj = classify_obj.filter_bank();
    
    dataset_filt(s).eeg = classify_obj.signal;
    dataset_filt(s).label = class;
    disp('filtering is done for one subject')
end
else
    dataset_filt = dataset;
end
    


%% Finding the Ranks

all_klds = find_the_dist_(n_channels,dataset_filt);

all_ranks = rankings(n_channels,all_klds);

%% User Defined Functions
% 1. all_ranks = rankings(n_channels,all_klds)
% 2. all_klds = find_the_dist_(n_channels,dataset)
% 3. norm_sigs = normlization(dataset)
% 4. [counts,centers] = find_the_hist(signal)
% 5. expect = expectation(dist)

function all_ranks = rankings(n_channels,all_klds)
all_ranks = struct;
for s = 1:5
    all_ranks(s).refs(1).ranks = zeros(n_channels,1);
    all_ranks(s).refs(2).ranks = zeros(n_channels,1);
    all_ranks(s).refs(3).ranks = zeros(n_channels,1);
    klds_c3 = all_klds(s).klds.c3;
    klds_cz = all_klds(s).klds.cz;
    klds_c4 = all_klds(s).klds.c4;
    
    for c = 1:n_channels
        all_ranks(s).refs(1).ranks(c,1) = expectation(klds_c3(c,:));
        all_ranks(s).refs(2).ranks(c,1) = expectation(klds_cz(c,:));
        all_ranks(s).refs(3).ranks(c,1) = expectation(klds_c4(c,:));
    end
    disp(s)
end

end


function all_klds = find_the_dist_(n_channels,dataset)
% dataset struct of size 1*n_subs with eeg and labeles as field
n_subs = size(dataset,2);
n_trials = int32(size(dataset(1).eeg,1)/n_channels);
n_samples = size(dataset(1).eeg,2);

norm_sigs = normlization(dataset);
all_klds = struct;
for i = 1: n_subs
     signals = norm_sigs(i).eeg_logged;
     signals = reshape(signals,[n_channels,n_trials,n_samples]);
     cz_sig = reshape(signals(54,:,:),[n_trials,n_samples]);
     c3_sig = reshape(signals(52,:,:),[n_trials,n_samples]);
     c4_sig = reshape(signals(56,:,:),[n_trials,n_samples]);
     
     
     all_klds(i).klds.c3 = zeros(n_channels,n_samples);
     all_klds(i).klds.cz = zeros(n_channels,n_samples);
     all_klds(i).klds.c4 = zeros(n_channels,n_samples);
     for j = 1:n_samples
         [c3_count,centers] = find_the_hist(c3_sig(:,j));
         [cz_count,~] = find_the_hist(cz_sig(:,j));
         [c4_count,~] = find_the_hist(c4_sig(:,j));
         for k = 1:n_channels
             ck_signals = reshape(signals(k,:,j),[n_trials,1]);
             [ck_count,~] = find_the_hist(ck_signals);
             kld_c3 = kldiv(centers,ck_count,c3_count,'js');
             kld_cz = kldiv(centers,ck_count,cz_count,'js');
             kld_c4 = kldiv(centers,ck_count,c4_count,'js');
             
             
             all_klds(i).klds.c3(k,j) = kld_c3;
             all_klds(i).klds.cz(k,j) = kld_cz;
             all_klds(i).klds.c4(k,j) = kld_c4;
         end
     end
     disp(i)
end

end


function norm_sigs = normlization(dataset)
% this witll log the data
n_subs = size(dataset,2);
norm_sigs = struct;
for i = 1: n_subs
     eeg = dataset(i).eeg;
     %make_it_one = (max(eeg,[],2)-min(eeg,[],2));
     
     eeg = (eeg - min(eeg,[],2))./(max(eeg,[],2)-min(eeg,[],2));
     eeg_logged = log(1 + eeg);
     eeg_logged = (eeg_logged-min(eeg_logged,[],2))...
         ./(max(eeg_logged,[],2)-min(eeg_logged,[],2));
     norm_sigs(i).eeg_logged = eeg_logged;
end
end




function [counts,centers] = find_the_hist(signal)
% signal = 1*n_trials
% histos = 1*n_trials

bin_edge = 0:0.1:1;
[counts,centers] = hist(signal,bin_edge);
counts = counts + 1; % 1 IS ADDED TO AVOID THE NaN AND inf
counts = counts/sum(counts);

end


function expect = expectation(dist)
n_bins = 10;
[counts,centers] = hist(dist,n_bins); % Erlier I had used hist() and it has no bins it was auto.
expect = sum(counts.*centers);
end




