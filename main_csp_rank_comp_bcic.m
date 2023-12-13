
clc
clear





n_subs = 5;
fs = 1000;

channel_selected = 1:118;
n_channels = numel(channel_selected);
dataset = extraction_bcic3_4a(channel_selected);


n_trials = 280;
n_samples = 3500;
features = [];%zeros(n_channels*n_subs*n_trials,n_samples);
labels = [];

for i = 1:n_subs
    
    features = [features;dataset(i).eeg];
    labels = [labels;dataset(i).label];
    disp(i)
end


%%

csp_ranks_obj = csp_ranks_for_ch_sel_bcic(features,labels,n_channels,fs);


csp_ranks_obj = csp_ranks_obj.csp_mats();


U1 = csp_ranks_obj.csp_W1;
U2 = csp_ranks_obj.csp_W2;
A1 = csp_ranks_obj.csp_A1;
A2 = csp_ranks_obj.csp_A2;


all_csp_ranks = [U1,U2];

all_csp_ranks = all_csp_ranks.^2;

all_ranks = sum(all_csp_ranks,2);









