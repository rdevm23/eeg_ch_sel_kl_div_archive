
clc
% clear




path = pwd;
fold = "KLDIV_BASED_CH_SEL_TBME_BCIC3_4a_CODES";

filename_1 = "RESULTS_ALL_SUBJECT_WITH_ALL_CHS_OF_ALL_SUBS.mat";
filename_2 = "RESULTS_ALL_SUBJECT_WITH_SUB_INDP.mat";


res_sub_indp = load(strcat(path,"\",fold,"\",filename_2));
res_sub_dp = load(strcat(path,"\",fold,"\",filename_1));
res_sub_indp = res_sub_indp.RESULTS_BCIC3_4A;
res_sub_dp = res_sub_dp.RESULTS_BCIC3_4A;


ch_samp = [3,15,20,40,60,80,118];

result_tab_indp = cell(10,numel(ch_samp));

for i = 1:5
    for j = 1:numel(ch_samp)
        result_tab_indp{i,j} = res_sub_indp(ch_samp(j),2).trn_accuracy{};
    end
end











