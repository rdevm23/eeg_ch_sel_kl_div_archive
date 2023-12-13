function [all_trials,all_labels,all_precue] = extraction_physionet(...
    all_trials,all_labels,all_precue,channels_selected)
n_channels = numel(channels_selected);
n_all_chs = 64;
n_cols = size(all_trials,1)/n_all_chs; % number of trails
n_sample = size(all_trials,2);

trials = reshape(all_trials,[n_all_chs,n_cols,n_sample]);
labels = reshape(all_labels,[n_all_chs,n_cols,1]);
precue = reshape(all_precue,[n_all_chs,n_cols,n_sample]);

all_trials = zeros(n_channels,n_cols,n_sample);
all_labels = zeros(n_channels,n_cols,1);
all_precue = zeros(n_channels,n_cols,n_sample);

for i = 1:n_channels
    all_trials(i,:,:) = trials(channels_selected(i),:,:);
    all_labels(i,:,:) = labels(channels_selected(i),:,:);
    all_precue(i,:,:) = precue(channels_selected(i),:,:);
end

all_trials = reshape(all_trials,[n_channels*n_cols,n_sample]);
all_labels = reshape(all_labels,[n_channels*n_cols,1]);
all_precue = reshape(all_precue,[n_channels*n_cols,n_sample]);
end