function dataset = extraction_phisionet(channel_selected,flag_precue)

% Output
%       - dataset: it will be array of structs with number of subjects as
%       size of the parent struct.
%           Each struct of the dataset(i) will contain two field - eeg, and
%           label. 
%           - eeg: will be of size (n_channels*n_trials,n_samples) and
%           - labels: will be of (n_channels*n_trials,1)
% 
%    

n_channels = numel(channel_selected);



path = pwd;

all_labels = load(strcat(path,"\datasets\physionet\physionet_all_labels.mat"));
all_trials = load(strcat(path,"\datasets\physionet\physionet_all_trials.mat"));
all_precues = load(strcat(path,"\datasets\physionet\physionet_all_precue.mat"));
sub_excluded = unique(readmatrix(strcat(path,"\datasets\physionet\subs_excluded.txt")));

all_labels = all_labels.all_labels;
all_trials = all_trials.all_trials;
all_precues = all_precues.all_precue;

n_chs = 64;
n_runs = 3;
n_events = 15;
% n_subjects = 109 - numel(sub_excluded);
n_samples = size(all_trials,2);


dataset = struct;
count_subj = 1;

% To discard 104th subject two runs
%       89 (103-14) subjects' data are there before it
%       start = 89*64(chs)*3(runs)*15(events) + 1 = 256321
%       end = 1920 (15*2*64) + 256321 - 1 = 258240
discard_str_idx = n_chs*89*n_runs*n_events + 1;
discard_end_idx = discard_str_idx + n_chs*2*n_events - 1;
all_labels(discard_str_idx:discard_end_idx) = [];
all_trials(discard_str_idx:discard_end_idx,:) = [];
all_precues(discard_str_idx:discard_end_idx,:) = [];

%%
for s = 1:109
    if sum(s == sub_excluded) > 0
        continue
    end
    
    % num of rows per subject = 64*15*3
    n_samp_sub =  n_chs*n_runs*n_events; %2880
    
    strt_idx = (count_subj - 1)*n_samp_sub + 1;
    end_idx = count_subj*n_samp_sub;
    
    if flag_precue == 1
        signal = all_trials(strt_idx:end_idx,:) - ...
            all_precues (strt_idx:end_idx,:);
    else
        signal = all_trials(strt_idx:end_idx,:);
    end
    
    signal = reshape(signal, [n_chs,n_runs*n_events,n_samples] );
    
    signal = signal(channel_selected,:,:);
    
    signal = reshape(signal,[n_channels*n_runs*n_events,n_samples]);

    labels = all_labels(strt_idx:end_idx);
    
    labels = reshape(labels, [n_chs,n_runs*n_events,1] );
    
    labels = labels(channel_selected,:,:);
    
    labels = reshape(labels,[n_channels*n_runs*n_events,1]);

    
    
    dataset(count_subj).eeg = signal;
    dataset(count_subj).label = labels;
    % disp(count_subj)
    count_subj = count_subj + 1;
end
end














