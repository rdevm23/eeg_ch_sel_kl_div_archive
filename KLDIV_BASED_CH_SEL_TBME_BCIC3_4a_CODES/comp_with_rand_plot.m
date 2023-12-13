

% clear
% 
% 
% selected_channels_rand = zeros(118,10);
% for i = 1:10
%     rng(i*5647*i^2)
%     selected_channels_rand(:,i) = randperm(118,118);
% end
% 


clc
clear 
close all
figure(1)

linewidth = 2;

load('RESULTS_COMP_RAND_BCIC3.mat')
x_all = zeros(116,10);

rand_all_avg_sub = zeros(5,3);

for i = 1:10
    
    hold on
    for j = 3:118
        x_all(j,i) = RESULTS_BCIC3_4A(j,i).avg_results(1);
    end
    plot(x_all(:,i),'DisplayName',string(i),'LineWidth',linewidth)
end


load('RESULTS_COMP_RAND_BCIC3.mat')
rand_all_avg_sub = struct;

for c = 3:118
    acc = zeros(5,3);
    for r = 1:10
        acc = acc + RESULTS_BCIC3_4A(c,r).accuracy_results;
    end
    acc = acc/10;
    rand_all_avg_sub(c,1).acc = acc;
    rand_all_avg_sub(c,1).avg = mean(acc);
    x_all_2(c) = rand_all_avg_sub(c,1).avg(1);
end

%%
rand_res = (load('RESULTS_COMP_RAND_BCIC3.mat'));
best_rand = 2;

sub_indp = load('RESULTS_ALL_SUBJECT_WITH_SUB_INDP.mat');

rand_avg = mean(x_all,2);
x = max(x_all')';
x = x_all(:,2);
y_sub_indp = zeros(116,1);
for i = 3:118

    y_sub_indp(i) = sub_indp.RESULTS_BCIC3_4A(i,2).avg_results(1);
    
end

plot(y_sub_indp,'k','DisplayName',"Sub Indp",'LineWidth',linewidth)
hold off
legend
grid on


x(1:2) = [];
y_sub_indp(1:2) = [];
rand_avg(1:2) = [];
figure(2)
plot(y_sub_indp,'k','DisplayName',"Sub Indp",'LineWidth',linewidth)
hold on
% plot(x,'DisplayName',"Rand Max",'LineWidth',linewidth)
plot(rand_avg,'DisplayName',"Rand Avg",'LineWidth',linewidth)

plot(x_all_2(3:118),'DisplayName',"Rand Avg 1",'LineWidth',linewidth)


legend
grid on


%% Fishers

fishers = load('RESULTS_COMP_FISHER_1_BCIC3.mat');
fishers = fishers.RESULTS_BCIC3_4A;


y_fishers = zeros(116,1);
for i = 3:118

    y_fishers(i) = fishers(i).avg_results(1);
    
end

y_fishers(1:2) = [];
plot(y_fishers,'DisplayName',"FS",'LineWidth',linewidth)



%% CSP 



csp_rank = load('RESULTS_COMP_CSP_RANK.mat');
csp_rank = csp_rank.RESULTS_BCIC3_4A;



y_csp = zeros(116,1);
for i = 3:118

    y_csp(i) = csp_rank(i).avg_results(1);
    
end

y_csp(1:2) = [];
plot(y_csp,'DisplayName',"CSP Rank",'LineWidth',linewidth)

%% NMI

nmi_res = load('ISBI_RESULTS_3.mat');

nmi_res = nmi_res.RESULTS_BCIC3_4A;




y_nmi = zeros(116,1);
for i = 3:118

    y_nmi(i) = nmi_res(i,1).avg_results(1);
    
end

y_nmi(1:2) = [];
plot(y_nmi,'DisplayName',"NMI",'LineWidth',linewidth)



%% accuracy per channels

n_chs = 3:118;
n_chs = n_chs';


ranks_acc_per_ch = y_sub_indp./n_chs;

five_per_max = (y_sub_indp(116))*(1- 1/20);


% [aa,aaa] = sort(ranks_acc_per_ch,'descend');



%%









