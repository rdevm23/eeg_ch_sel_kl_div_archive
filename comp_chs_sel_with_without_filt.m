clear
clc
close all

without_filt = load('allranks_without_filter.mat');
with_filt = load('allranks_with_filters.mat');


without_filt_sub_ind = load('allranks_without_filter_sub_ind.mat');
with_filt_sub_ind = load('allranks_with_filter_sub_ind.mat');


n_channels = 118;
% s = 4;
figure(1)
LineWidth = 1.5;
fontzie = 12;
sum_diff_avg_per =  zeros(118,1);
for s = 1:7 % 6th and 7th are for subject indp
    ref_chs = [52;54;56];
    
    if s <= 5
        ranks_of_sub = without_filt.all_ranks(s).refs(2).ranks; % without filters
        ranks_of_sub_filt = with_filt.all_ranks(s).refs(2).ranks;
        [out1,idx1] = sort(ranks_of_sub,'ascend');
        channel_selected1 = idx1(1:n_channels);

        [out2,idx2] = sort(ranks_of_sub_filt,'ascend');
        channel_selected2 = idx2(1:n_channels);
    
        disp_name = strcat("Sub ",string(s));
        LineWidth = 1;
    elseif s == 7
        ranks_of_sub = without_filt_sub_ind.all_ranks.refs(2).ranks; % without filters
        ranks_of_sub_filt = with_filt_sub_ind.all_ranks.refs(2).ranks;
        [out1,idx1] = sort(ranks_of_sub,'ascend');
        channel_selected1 = idx1(1:n_channels);
        
        [out2,idx2] = sort(ranks_of_sub_filt,'ascend');
        channel_selected2 = idx2(1:n_channels);
        disp_name = "Sub Indp";
        LineWidth = 2.5;
    elseif s == 6
        
        
        ranks_of_sub = AVG_RANKS_SUB_INDP(without_filt);
        ranks_of_sub_filt = AVG_RANKS_SUB_INDP(with_filt);
        [out1,idx1] = sort(ranks_of_sub,'ascend');
        channel_selected1 = idx1(1:n_channels);
        
        [out2,idx2] = sort(ranks_of_sub_filt,'ascend');
        channel_selected2 = idx2(1:n_channels);
        
        disp_name = "Avg Rank";
        LineWidth = 2.5;
    end
    
    
    
    % Ploting the difference between both]
    
    [diff_ch_sel,percentage_diff] = FIND_THE_DIFF(n_channels,channel_selected1,channel_selected2);
    hold on
    
    plot(diff_ch_sel,'LineWidth',LineWidth,'DisplayName',disp_name)
    sum_diff_avg_per = sum_diff_avg_per + percentage_diff;
end
hold on

LineWidth = 2;

plot(sum_diff_avg_per/7,'k','LineWidth',LineWidth,...
    'DisplayName','Avg Percentage')


xlim([0 120]); ylim([0 35]); grid on;
ylabel('Different Channels','FontSize',fontzie,'FontWeight','bold')
xlabel('Number of Selected Channels','FontSize',fontzie,'FontWeight','bold')
legend;%('Absolute','Percentage')


%% User defined functions
function [diff_ch_sel,percentage_diff] = FIND_THE_DIFF(n_channels,channel_selected1,channel_selected2)
diff_ch_sel = zeros(118,1);
percentage_diff = zeros(118,1);
for i = 1:n_channels
    
    wihtout_filt = channel_selected1(1:i);
    wiht_filt = channel_selected2(1:i);
    
    diff = i - numel( intersect( wihtout_filt, wiht_filt ) );
    diff_ch_sel(i) = diff;
    
    percentage_diff(i) = 100*diff/i;
end

end






function ranks_of_sub = AVG_RANKS_SUB_INDP(X)
ranks_of_sub = zeros(118,1);
for s = 1:5
    ranks = X.all_ranks(s).refs(2).ranks;
    ranks_of_sub = ranks_of_sub + ranks;
end
ranks_of_sub = ranks_of_sub/5;
end












