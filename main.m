%% THIS IS TO DEVELOP A NOVEL CHANNEL SELECTION ALGORITHM FOR EEG

% This is for the BCIC IV 2a dataset can be found at
% http://bnci-horizon-2020.eu/database/data-sets 

% Part of the code at https://github.com/anthonyesp/channel_selection has
% been reused and some has been modified and used. The work related to this
% code will be cited and authors of the code does not claim the IP of the
% reused or modified code. 

% Author - Raghav Dev, rdevm23@gmail.com
% Copyright(C) 2023, All Rights Reserved


% Date - 7th Aug 2023
% Version - 1.0
% Last Modified on - 7th Aug 2023


% This script shall perform the training and testing of the selected
% channels for the accuracy of MI task classification. Challe selection
% algo and it's testing and verification will be done in seperate scripts.

close all;
clear;
%clc

%% Preparing the dataset and train test split


channels_selected = 1:2:22; % this suppose to come from chnnel selection algo

class_1 = 1;
class_2 = 2;

path = pwd;
session = ['T','E'];
trials = 1:48;
tmin = 3;
tmax = 5;

n_channels = numel(channels_selected);
n_CSP_comp = 4;
n_subs = 9; 
fs = 250;

signal_filtered = zeros(numel(trials)*3*n_subs*2,n_CSP_comp*4); % n_trials*6(n_session)/2(2 out of total 4 classes)
lables_pre_proc = zeros(numel(trials)*3*n_subs*2,1);

idx_data = 1;

for s = 1:n_subs
    for e = 1:2
        sub_name = strcat(path,'\datasets\bcic4_2a\',...
            'A0',string(s),session(e),'.mat');
        
        % correcting the runs for A04T
        if (s == 4)&&(e == 1)
            runs = 2:7;
        else
            runs = 4:9;
        end
        
        [signal_pre_proc, classes, ~] = extraction(...
            sub_name,runs, channels_selected, trials, tmin, tmax);
        class   = classes(classes==class_1|classes==class_2);
        signal_pre_proc = signal_pre_proc(classes==class_1|classes==class_2,:);
        
        classify_obj = cls_classify_motorI(signal_pre_proc,class,n_channels,fs); % Initializing the object
        
        % Creating the filter
        if (s==1)&&(e==1)
            classify_obj = classify_obj.create_filter();
            filter = classify_obj.filter;
        else
            classify_obj.filter = filter;
        end 
        
        
        % Filtering
        classify_obj = classify_obj.filter_bank();
        
        % CSP Train
        classify_obj = classify_obj.csp_mats(n_CSP_comp);
        
        % CSP Apply
        
        classify_obj = classify_obj.csp_apply();
        
        
        
        signal_filtered(idx_data:idx_data + numel(trials)*3 - 1,:) = ...
            classify_obj.csp_signal;
        lables_pre_proc(idx_data:idx_data + numel(trials)*3 - 1,1) = ...
            classify_obj.csp_lables;
        
        idx_data = idx_data + numel(trials)*3;
        
        message = strcat("Data for the subject ",string(s),' is done');
        disp(message)
    end
end

clearvars -except signal_filtered lables_pre_proc channels_selected


%% SVM

judge_the_method = classifires_pool(signal_filtered,lables_pre_proc);


judge_the_method = judge_the_method.test_train_split();
judge_the_method = judge_the_method.svm_train();
judge_the_method = judge_the_method.svm_pred();

%% k-NN

judge_the_method = judge_the_method.one_nn_fun();
judge_the_method = judge_the_method.five_nn_fun();


%% Plots

% To See the effect of filters
% figure(1)
% plot(signal(1,:))
% hold on
% plot(classify_obj.signal(1,:))
% 










