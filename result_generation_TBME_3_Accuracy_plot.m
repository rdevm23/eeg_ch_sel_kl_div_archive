clear
clc
close all




sub_indp = load("C:\Raghav\git_repos\ch_selection_TBME\channel_selection-main\MATS_FILES_RESULTS_TBME\RESULTS_ALL_SUBJECT_WITH_SUB_INDP.mat");
sub_dp = load("C:\Raghav\git_repos\ch_selection_TBME\channel_selection-main\MATS_FILES_RESULTS_TBME\RESULTS_ALL_SUBJECT_WITH_ALL_CHS_OF_ALL_SUBS.mat");

col = ["m","g","c","y","b","r","k"];
line_width = [1,1.5,2,2.5];
DisplayName = ["Sub 1","Sub 2","Sub 3","Sub 4","Sub 5","Avg Ranks","Sub Indp"];

x_lims_low = [55,75,50,60,75,70];
x_lims_high = [100,100,85,105,105,95];
fontzie = 12;

signal = zeros(1,118);
for filt = 1:2
    figure(filt)
    for s = 1:6 % 6th is for avg accuracy over subjects
        subplot(2,3,s)
        hold on
        for idx_sub_dp = 1:7 % 6th if for avg rank
            for ch = 3:118
                if idx_sub_dp ~= 7
                    disp("Sub Dep");
                    if s ~= 6
                        signal(ch) = sub_dp.RESULTS_BCIC3_4A(ch,filt,idx_sub_dp).accuracy_results(s,1);
                    else
                        signal(ch) = sub_dp.RESULTS_BCIC3_4A(ch,filt,idx_sub_dp).avg_results(1);
                    end
                else
                    if s ~= 6
                        signal(ch) = sub_indp.RESULTS_BCIC3_4A(ch,filt).accuracy_results(s,1);
                    else
                        signal(ch) = sub_indp.RESULTS_BCIC3_4A(ch,filt).avg_results(1);
                    end
                    disp("Sub Indep");
                end
            end
            signal(1:2) = [];
            if (idx_sub_dp == s) && (idx_sub_dp <= 5)
                LineWidth = line_width(2);
            elseif idx_sub_dp == 7
                LineWidth = line_width(3);
            elseif idx_sub_dp == 6
                LineWidth = line_width(3);
            else
                LineWidth = line_width(1);
            end
            
            
            plot(signal(1:1:116),col(idx_sub_dp),'LineWidth',...
                LineWidth,'DisplayName',DisplayName(idx_sub_dp))
            xlim([2 120]); ylim([x_lims_low(s) x_lims_high(s)]); grid on;
            ylabel("Accuracy (%)",'FontSize',fontzie,'FontWeight','bold')
            xlabel("Number of Channels",'FontSize',fontzie,'FontWeight','bold')
            if s <= 5
                title(strcat("Subject ", string(s)));
            else
                title("Average Accuracy Over Subjects");
            end
            
        end
        hold off
    end
    legend;
end




%% Filter Vs Without Filter


figure(3)


col = ["r","k"];
line_width = [1,2.5];
DisplayName1 = ["Without Filter","Filtered"];
DisplayName2 = [" Avg Rank"," Subject Ind"," Sub 1"," Sub 2"];

x_lims_low = 65;
x_lims_high = 95;
s = 6;
signal_avg_rank = zeros(1,118);
signal_sub_indp = zeros(1,118);
signal_sub1 = zeros(1,118);
signal_sub2 = zeros(1,118);
for filt = 1:2
    for ch = 3:118
        signal_avg_rank(ch) = sub_dp.RESULTS_BCIC3_4A(ch,filt,6).avg_results(1);
        signal_sub_indp(ch) = sub_indp.RESULTS_BCIC3_4A(ch,filt).avg_results(1);
        signal_sub1(ch) = sub_dp.RESULTS_BCIC3_4A(ch,filt,1).avg_results(1);
        signal_sub2(ch) = sub_dp.RESULTS_BCIC3_4A(ch,filt,2).avg_results(1);

    end    
    signal_avg_rank(1:2) = [];
    signal_sub_indp(1:2) = [];
    signal_sub1(1:2) = [];
    signal_sub2(1:2) = [];
    
    subplot(2,2,1)
    hold on
    plot(signal_avg_rank,"r",'LineWidth',line_width(filt),...
        'DisplayName',strcat(DisplayName1(filt),DisplayName2(1)))
    hold off
    
    xlim([2 120]); 
    ylim([x_lims_low x_lims_high]); 
    grid on;
    
    ylabel("Accuracy (%)",'FontSize',fontzie,'FontWeight','bold')
    xlabel("Number of Channels",'FontSize',fontzie,'FontWeight','bold')
    
    legend;

    subplot(2,2,2)
    hold on
    plot(signal_sub_indp,"k",'LineWidth',line_width(filt),...
        'DisplayName',strcat(DisplayName1(filt),DisplayName2(2)))
    
    hold off
    
    xlim([2 120]); 
    ylim([x_lims_low x_lims_high]); 
    grid on;
    ylabel("Accuracy (%)",'FontSize',fontzie,'FontWeight','bold')
    xlabel("Number of Channels",'FontSize',fontzie,'FontWeight','bold')
    legend;
    
    subplot(2,2,3)
    hold on
    plot(signal_sub1,"m",'LineWidth',line_width(filt),...
        'DisplayName',strcat(DisplayName1(filt),DisplayName2(3)))
    hold off
    
    xlim([2 120]); 
    ylim([x_lims_low x_lims_high]); 
    grid on;
    
    ylabel("Accuracy (%)",'FontSize',fontzie,'FontWeight','bold')
    xlabel("Number of Channels",'FontSize',fontzie,'FontWeight','bold')
    
    legend;

    subplot(2,2,4)
    hold on
    plot(signal_sub2,"g",'LineWidth',line_width(filt),...
        'DisplayName',strcat(DisplayName1(filt),DisplayName2(4)))
    
    hold off
    
    xlim([2 120]); 
    ylim([x_lims_low x_lims_high]); 
    grid on;
    
    ylabel("Accuracy (%)",'FontSize',fontzie,'FontWeight','bold')
    xlabel("Number of Channels",'FontSize',fontzie,'FontWeight','bold')
    
    sgtitle("Filter Vs Without Filter for Average Accuracy Over Subjects");
    legend;

end



















