clc
close all


sub_dp = load("RESULTS_PHYSIONET_SUB_DP.mat");
sub_indp = load("RESULTS_PHYSIONET_SUB_INDP.mat");
sub_indp_avg = load("RESULTS_PHYSIONET_SUB_INDP_AVG.mat");


sub_dp = sub_dp.RESULTS_PHYSIONET;
sub_indp = sub_indp.RESULTS_PHYSIONET;
sub_indp_avg = sub_indp_avg.RESULTS_PHYSIONET;


col = [".-r",".-b",".-k"];
LineWidth = 2;
DisplayName = ["Subject Dependent","Avg Rank","Subject Indep"];

x_lim_low = 50;
x_lim_high = 95;
fontzie = 12;


signal_sub_dp = zeros(64,1);
signal_sub_indp = zeros(64,1);
signal_sub_indp_avg = zeros(64,1);

for i = 3:64
    x = sub_dp(i).avg_results(1);
    signal_sub_dp(i) = x;
    signal_sub_indp(i) = sub_indp(i).avg_results(1);
    signal_sub_indp_avg(i) = sub_indp_avg(i).avg_results(1);
end

%%
figure(1)


plot(signal_sub_dp,col(1),'LineWidth',...
    LineWidth,'DisplayName',DisplayName(1))

hold on

plot(signal_sub_indp,col(2),'LineWidth',...
    LineWidth,'DisplayName',DisplayName(3))

hold on

plot(signal_sub_indp_avg,col(3),'LineWidth',...
    LineWidth,'DisplayName',DisplayName(2))

legend;

xlim([3 64]); ylim([x_lim_low x_lim_high]); 
grid on;
ylabel("Accuracy (%)",'FontSize',fontzie,'FontWeight','bold')
xlabel("Number of Channels",'FontSize',fontzie,'FontWeight','bold')




%% Channel Diff


figure(2)






















