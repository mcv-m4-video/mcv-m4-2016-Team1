close all;
clear all;
clc;

fprintf('Loading general parameters...\n');

%% Select execution options

color_space = 'YUV'; % 'RGB', 'Gray', 'HSV', 'YUV'

do_task5 = false;
do_task6 = false;
show_videos_5 = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load Parameters
addpath(genpath('.'))

[gt_input_highway,gt_input_fall,gt_input_traffic] = load_gt();
[seq_input_highway, seq_input_fall, seq_input_traffic] = load_seqs(color_space);

global params;
params = load_parameters();
show_videos_1 = params.showvideos1;


for i = 1:length(params.alpha)
    for j = 1:length(params.P)

    disp(['Computing for: alpha = ', num2str(params.alpha(i)),' and P = ' num2str(params.P(j))]);
    
    [forEstim_highway, t1_h, mean_h]= task1(seq_input_highway,params.alpha(i), params.P(j), show_videos_1, color_space);
    [forEstim_fall,t1_f, mean_f] = task1(seq_input_fall,params.alpha(i), params.P(j),show_videos_1, color_space);
    [forEstim_traffic,t1_t, mean_t]= task1(seq_input_traffic,params.alpha(i), params.P(j),show_videos_1, color_space);

    
    % Evaluation functions for TASK 1 (TASK 2 and TASK 3)
    [TP_h(i,j), FP_h(i,j), FN_h(i,j), TN_h(i,j), Precision_h(i,j), Accuracy_h(i,j), Specificity_h(i,j), Recall_h(i,j), F1_h(i,j)] = task2(forEstim_highway,gt_input_highway(t1_h:end));
    [TP_f(i,j), FP_f(i,j), FN_f(i,j), TN_f(i,j), Precision_f(i,j), Accuracy_f(i,j), Specificity_f(i,j), Recall_f(i,j), F1_f(i,j)] = task2(forEstim_fall,gt_input_fall(t1_f:end));
    [TP_t(i,j), FP_t(i,j), FN_t(i,j), TN_t(i,j), Precision_t(i,j), Accuracy_t(i,j), Specificity_t(i,j), Recall_t(i,j), F1_t(i,j)] = task2(forEstim_traffic,gt_input_traffic(t1_t:end));
    end
end

% Best F1 Score and Alpha
if params.P == 0
    [maxF1h,id_h] = max(F1_h); good_alpha_h = params.alpha(id_h);
    [maxF1f,id_f] = max(F1_f); good_alpha_f = params.alpha(id_f);
    [maxF1t,id_t] = max(F1_t); good_alpha_t = params.alpha(id_t);

    disp(['max F1 highway: ', num2str(maxF1h), ' in alpha: ',num2str(good_alpha_h)]);
    disp(['max F1 fall: ', num2str(maxF1f), ' in alpha: ',num2str(good_alpha_f)]);
    disp(['max F1 traffic: ', num2str(maxF1t), ' in alpha: ',num2str(good_alpha_t)]);

    plot_f1_t2(params.alpha, F1_h, F1_f, F1_t);

end    


disp('--------Plot AUC--------');

for i = 1: length(params.P)
    
    % Plot Precision VS Recall
    % plot_precision_recall_t3([1,Recall_h(:,i)',0], [1,Recall_f(:,i)',0], [1,Recall_t(:,i)',0], [0,Precision_h(:,i)',1], [0,Precision_f(:,i)',1], [0,Precision_t(:,i)',1]);
    plot_PR_Combined([1,Recall_h(:,i)',0], [1,Recall_f(:,i)',0], [1,Recall_t(:,i)',0], [0,Precision_h(:,i)',1], [0,Precision_f(:,i)',1], [0,Precision_t(:,i)',1]);

    % Calculate the area under the curve
    Area_h(i) = trapz(flip([1,Recall_h(:,i)',0]), flip([0,Precision_h(:,i)',1]));
    Area_f(i) = trapz(flip([1,Recall_f(:,i)',0]), flip([0,Precision_f(:,i)',1]));
    Area_t(i) = trapz(flip([1,Recall_t(:,i)',0]), flip([0,Precision_t(:,i)',1]));
    
    Area(i) = (Area_h(i) + Area_f(i) + Area_t(i)) / 3;

    disp(['Area under the curve for the Highway: ', num2str(Area_h(i))])
    disp(['Area under the curve for the Fall: ', num2str(Area_f(i))])
    disp(['Area under the curve for the Traffic: ', num2str(Area_t(i))])
    disp(['Average area under the curve: ', num2str(Area(i))])

end


if params.P ~= 0

    % Plots the Area vs the number of pixels used in bwareaopen
    plot_task2(Area_h,Area_f,Area_t);
    
end

if(do_task5)
    disp('--------TASK 5--------')
    disp('Press any key to continue with task 5');
    pause;
    close all;
    for i = 1:length(params.alpha)
        for j = 1:length(params.P)
            
            disp(['Computing for: alpha = ', num2str(params.alpha(i)),' and P = ' num2str(params.P(j))]);
            
            [forEstim_highway, t1_h, mean_h]= task1(seq_input_highway,params.alpha(i), params.P(j), show_videos_1, color_space);
            [forEstim_fall,t1_f, mean_f] = task1(seq_input_fall,params.alpha(i), params.P(j),show_videos_1, color_space);
            [forEstim_traffic,t1_t, mean_t]= task1(seq_input_traffic,params.alpha(i), params.P(j),show_videos_1, color_space);
            
            forEstim_highway = remove_shadows(forEstim_highway,seq_input_highway(t1_h:end),mean_h, show_videos_5, color_space);
            forEstim_fall = remove_shadows(forEstim_fall,seq_input_fall(t1_f:end),mean_f, show_videos_5, color_space);
            forEstim_traffic = remove_shadows(forEstim_traffic,seq_input_traffic(t1_t:end),mean_t, show_videos_5, color_space);
            
            % Evaluation functions for TASK 1 (TASK 2 and TASK 3)
            [TP_h(i,j), FP_h(i,j), FN_h(i,j), TN_h(i,j), Precision_h(i,j), Accuracy_h(i,j), Specificity_h(i,j), Recall_h(i,j), F1_h(i,j)] = task2(forEstim_highway,gt_input_highway(t1_h:end));
            [TP_f(i,j), FP_f(i,j), FN_f(i,j), TN_f(i,j), Precision_f(i,j), Accuracy_f(i,j), Specificity_f(i,j), Recall_f(i,j), F1_f(i,j)] = task2(forEstim_fall,gt_input_fall(t1_f:end));
            [TP_t(i,j), FP_t(i,j), FN_t(i,j), TN_t(i,j), Precision_t(i,j), Accuracy_t(i,j), Specificity_t(i,j), Recall_t(i,j), F1_t(i,j)] = task2(forEstim_traffic,gt_input_traffic(t1_t:end));
        end
    end
end
for i = 1: length(params.P)
    
    % Plot Precision VS Recall
    plot_precision_recall_t3([1,Recall_h(:,i)',0], [1,Recall_f(:,i)',0], [1,Recall_t(:,i)',0], [0,Precision_h(:,i)',1], [0,Precision_f(:,i)',1], [0,Precision_t(:,i)',1]);

    % Calculate the area under the curve
    Area_h(i) = trapz(flip([1,Recall_h(:,i)',0]), flip([0,Precision_h(:,i)',1]));
    Area_f(i) = trapz(flip([1,Recall_f(:,i)',0]), flip([0,Precision_f(:,i)',1]));
    Area_t(i) = trapz(flip([1,Recall_t(:,i)',0]), flip([0,Precision_t(:,i)',1]));

    disp(['Area under the curve for the Highway: ', num2str(Area_h(i))])
    disp(['Area under the curve for the Fall: ', num2str(Area_f(i))])
    disp(['Area under the curve for the Traffic: ', num2str(Area_t(i))])

end


disp('--------TASK 6--------');
% Best F1 Score and Alpha

if (do_task6)
    if length(params.P) == 1

            Fbeta_h=0; Fbeta_f=0; Fbeta_t=0;
            cont_h=0; cont_f=0; cont_t=0;

            % Apply Foreground Maps
            for i = 1:length(forEstim_highway)
                if nnz(gt_input_highway{i+t1_f-1}>=170)==0
                    continue
                end
                Fbeta_h = Fbeta_h + WFb(double(forEstim_highway{i}),gt_input_highway{i+t1_h-1}>=170);
                cont_h = cont_h+1;
            end
            for i = 1:length(forEstim_fall)
                if nnz(gt_input_fall{i+t1_f-1}>=170)==0
                    continue
                end
                Fbeta_f = Fbeta_f + WFb(double(forEstim_fall{i}),gt_input_fall{i+t1_f-1}>=170);
                cont_f = cont_f+1;
            end
            for i = 1:length(forEstim_traffic)
                if nnz(gt_input_traffic{i+t1_f-1}>=170)==0
                    continue
                end
                Fbeta_t = Fbeta_t + WFb(double(forEstim_traffic{i}),gt_input_traffic{i+t1_t-1}>=170);
                cont_t = cont_t+1;
            end    

            Fbeta_h = Fbeta_h/cont_h;
            Fbeta_f = Fbeta_f/cont_f;
            Fbeta_t = Fbeta_t/cont_t;
            Fbeta_avg = (Fbeta_h + Fbeta_f + Fbeta_t)/3;

            disp(['Fbeta for the Highway: ', num2str(Fbeta_h)])
            disp(['Fbeta the curve for the Fall: ', num2str(Fbeta_f)])
            disp(['Fbeta for the Traffic: ', num2str(Fbeta_t)])
            disp(['Fbeta for the Average: ', num2str(Fbeta_avg)])

    end    
end

