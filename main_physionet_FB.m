%% Channel Selection for Physionet Dataset





close all;
clear;
% clc


%% 



% channels_selected = randi(64,[64 1]);%% this suppose to come from chnnel selection algo
channels_selected = 1:64;

channels_selected = [10 9 8 2 1 16 57 22 56 28 29 12 13 19 18 20 62 59 63 60];

class_1 = 1;
class_2 = 2;


n_channels = numel(channels_selected);
disp(n_channels)
n_CSP_comp = 2; % Tune it

path = pwd;

all_labels = load(strcat(path,"\datasets\physionet\physionet_all_labels.mat"));
all_trials = load(strcat(path,"\datasets\physionet\physionet_all_trials.mat"));
all_precues = load(strcat(path,"\datasets\physionet\physionet_all_precue.mat"));
all_labels = all_labels.all_labels;
all_trials = all_trials.all_trials;
all_precues = all_precues.all_precue;
disp("Data is Loaded")

%% Signals of Chs
[all_trials,all_labels,all_precues] = extraction_physionet(...
    all_trials,all_labels,all_precues,channels_selected);

disp("data for asked channels is ready ")

fs = 160;

signal = all_trials;% - all_precue;

classify_obj = cls_classify_with_filterbanks(signal,all_labels,n_channels,fs); % Initializing the object
disp("Object is Created")

% Creating the filter
classify_obj = classify_obj.filtering();
disp("Filtering has been done")

classify_obj = classify_obj.csp_filtering(...
    channels_selected,n_CSP_comp);


k = 5 ; % MIBIF Components
classify_obj = classify_obj.feature_selection(k);

clearvars -except channels_selected classify_obj

%% Signal Extraction
signal_filtered = classify_obj.csp_signal;
lables_pre_proc = classify_obj.csp_labels;
disp("Features are ready for classification")

% signal_filtered = classify_obj.mibif_signal;
% lables_pre_proc = classify_obj.csp_labels;


%% SVM

judge_the_method = classifires_pool(signal_filtered,lables_pre_proc);


judge_the_method = judge_the_method.test_train_split();
judge_the_method = judge_the_method.svm_train();
judge_the_method = judge_the_method.svm_pred();

%% k-NN

judge_the_method = judge_the_method.one_nn_fun();
judge_the_method = judge_the_method.five_nn_fun();








