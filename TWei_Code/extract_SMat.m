clear
clc
close all

addpath('data')
dataset = {'1_mECS', '2_Kolod', '3_Pollen', '4_Usoskin'} %% four datasets tested on the paper

for i = 1:4
    load(['Test_' dataset{i}]);
    C = max(true_labs); %%% number of clusters
    rng('default'); %%% for reproducibility
    [y, S, F, ydata,alpha] = SIMLR(in_X,C,10);
    writematrix(true_labs, ['data' dataset{i} '_TrueLabels.txt']);
    writematrix(S, ['data' dataset{i} '_SMat.txt']); 
end
