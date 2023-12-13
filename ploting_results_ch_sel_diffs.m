
clear
clc


SUB_INDP_AVG = load('RESULTS_PHYSIONET_SUB_INDP_AVG.mat');
SUB_INDP_AVG = SUB_INDP_AVG.RESULTS_PHYSIONET(64).channel_selected;

SUB_INDP = load('all_ranks_sub_independent.mat');

SUB_INDP = SUB_INDP.all_ranks.refs(2).ranks;

[~,SUB_INDP] = sort(SUB_INDP);
SUB_DEP = load('all_ranks_sub_dependent.mat');
SUB_DEP = SUB_DEP.all_ranks;

sub_dep = zeros(64,94);
for i = 1:94
    [~,sub_dep(:,i)] = sort(SUB_DEP(i).refs(2).ranks);
end

SUB_DEP = sub_dep;

clear i sub_dep

n_channels = 64;


diff_map = zeros(96,96,64);
all_ch_sel_series = [SUB_DEP, SUB_INDP_AVG, SUB_INDP];


for i = 1:96
    for j = 1:96
       diff_map(i,j,:) = FIND_THE_DIFF(n_channels,...
           all_ch_sel_series(:,i),all_ch_sel_series(:,j));
    end
end

%%
% Plot avg diffs
close all
diff_mean = reshape(mean(diff_map,1), [96,64] );
plot_subs = [10,30,50,70,90,95,96];
LineWidth = 2;
x = zeros(1,64);
figure
for i = 1: numel(plot_subs)
    if i <= numel(plot_subs) - 2
        disp_name = strcat("Sub ", string(plot_subs(i)));
        LineWidth = 1.5;
    elseif i == numel(plot_subs) - 1
        disp_name = strcat("Avg Rank");
        LineWidth = 2.5;
    else
        disp_name = strcat("Sub Indp");
        LineWidth = 2.5;
    end
    plot(diff_mean(i,:),'.-','LineWidth',LineWidth,'DisplayName',disp_name)
    hold on
    x = x + diff_mean(i,:);

end

diff_avg_sub_indp_vs_sub_indp = reshape(diff_map(96,95,:),[64,1]);


% x = x/(numel(plot_subs));
% x = x*100./(1:64);
% 
plot(diff_avg_sub_indp_vs_sub_indp,'.-k','LineWidth',LineWidth,'DisplayName',"Avg Rank Vs Sub Indp")

axis([0 64 0 12])

grid on
legend;
xticks(0 : 64)
% 
% ch_sel_20_diffs = 



%% Plot the channel Map


%% User Defined Functions

function [diff_ch_sel,percentage_diff] = FIND_THE_DIFF(n_channels,channel_selected1,channel_selected2)
diff_ch_sel = zeros(n_channels,1);
percentage_diff = zeros(n_channels,1);
for i = 1:n_channels
    
    wihtout_filt = channel_selected1(1:i);
    wiht_filt = channel_selected2(1:i);
    
    diff = i - numel( intersect( wihtout_filt, wiht_filt ) );
    diff_ch_sel(i) = diff;
    
    percentage_diff(i) = 100*diff/i;
end

end






