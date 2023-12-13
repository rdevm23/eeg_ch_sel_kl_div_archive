%% Channel Selection on the BCIC3 IVa Dataset

% find_the_dist.m is the algo to rank the channels

% This code shall find the channel selection and decoding accurcy for
% subject specific selection of channels (subject dependent).


clearvars -except chs_with_min_shunt chs_with_max_shunt
close all

%%

class_1 = 1;
class_2 = 2;
n_CSP_comp = 2;
n_subs = 5;
fs = 1000;
s = 4;
ref_chs = [52;54;56];

RESULTS_BCIC3_4A = struct;

for filt = 1:2
    if filt == 1
        load('allranks.mat')
    else
        load('allranks_with_filters.mat')
    end
    
    parfor n_chs = 3:118
        
        n_channels = n_chs;
        accuracy_results = zeros(n_subs,3);
        trn_accuracy = cell(n_subs,3);
                
        for s = 1:n_subs
            % Channel Selection
            ranks_of_sub = all_ranks(s).refs(2).ranks;
            [out,idx] = sort(ranks_of_sub,'ascend');
            idx(idx==52) = []; idx(idx==54) = []; idx(idx==56) = [];
            channel_selected = [ref_chs ;idx(1:n_channels-3)];
            
            % channel_selected = idx(1:n_channels);
            
            dataset = extraction_bcic3_4a(channel_selected);
            
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
            classify_obj = classify_obj.csp_mats(n_CSP_comp);
            classify_obj = classify_obj.csp_apply();
            
            % Classification and Results
            
            signal_filtered = classify_obj.csp_signal;
            lables_pre_proc = classify_obj.csp_lables;
            
            judge_the_method = classifires_pool_with_cv(real(signal_filtered),lables_pre_proc);
            judge_the_method = judge_the_method.test_train_split();
            
            judge_the_method = judge_the_method.svm_train();
            judge_the_method = judge_the_method.svm_pred();
            
            % k-NN
            
            judge_the_method = judge_the_method.one_nn_fun();
            judge_the_method = judge_the_method.five_nn_fun();
            
            accuracy_results(s,1) = judge_the_method.accuracy_svm;
            accuracy_results(s,2) = judge_the_method.accuracy_1_nn;
            accuracy_results(s,3) = judge_the_method.accuracy_5_nn;
            
            trn_accuracy{s,1} = judge_the_method.trn_acc_svm_model;
            trn_accuracy{s,2} = judge_the_method.trn_acc_1nn_model;
            trn_accuracy{s,3} = judge_the_method.trn_acc_5nn_model;
        end
        
        A1 = n_chs;
        formatSpec = 'Decoding for %4d number of channels for all the subjects are done\n';
        fprintf(formatSpec,A1)
        
        avg_accuracy = mean(accuracy_results,1);
        % accuracy_results
        % avg_accuracy
        % trn_accuracy
        RESULTS_BCIC3_4A(n_chs,filt).accuracy_results = accuracy_results;
        RESULTS_BCIC3_4A(n_chs,filt).avg_results = avg_accuracy;
        RESULTS_BCIC3_4A(n_chs,filt).channel_selected = channel_selected;
        
        RESULTS_BCIC3_4A(n_chs,filt).trn_accuracy = trn_accuracy;
        
    end
end

