
clear
clc


SUB_INDP_AVG = load('RESULTS_ALL_SUBJECT_WITH_ALL_CHS_OF_ALL_SUBS.mat');
SUB_INDP_AVG = SUB_INDP_AVG.RESULTS_BCIC3_4A;

sub_indp_avg = SUB_INDP_AVG(118,2,6).channel_selected;
sub_dep = zeros(118,5);
for i = 1:5
    sub_dep(:,i) = SUB_INDP_AVG(118,2,i).channel_selected;
end
SUB_INDP_AVG = sub_indp_avg;

SUB_INDP = load('RESULTS_ALL_SUBJECT_WITH_SUB_INDP.mat');

SUB_INDP = SUB_INDP.RESULTS_BCIC3_4A(118,2).channel_selected;


clear i sub_indp_avg
n_channels = 118;


diff_map = zeros(7,7,118);
all_ch_sel_series = [sub_dep, SUB_INDP_AVG, SUB_INDP];


for i = 1:7
    for j = 1:7
       diff_map(i,j,:) = FIND_THE_DIFF(n_channels,...
           all_ch_sel_series(:,i),all_ch_sel_series(:,j));
    end
end

%%
% Plot diffs
close all
diff_mean = reshape(mean(diff_map,1), [7,118] );
plot_subs = [1,2,3,4,5,6,7];
LineWidth = 2;
x = zeros(1,118);
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
    plot(diff_mean(i,(2:2:118)),'.-','LineWidth',LineWidth,'DisplayName',disp_name)
    hold on
    x = x + diff_mean(i,:);

end

diff_avg_sub_indp_vs_sub_indp = reshape(diff_map(7,6,:),[118,1]);


% x = x/(numel(plot_subs));
% x = x*100./(1:64);
% 
plot(diff_avg_sub_indp_vs_sub_indp(2:2:118),'.-k','LineWidth',LineWidth,'DisplayName',"Avg Rank Vs Sub Indp")
grid on
legend;
xticks(0 : 59)

tick2text(gca,'xformat', @(x) sprintf('%2u', x*2))

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






