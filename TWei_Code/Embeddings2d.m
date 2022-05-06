clear
clc
close all

addpath('data')
addpath('src')
dataset = {'1_mECS', '2_Kolod', '3_Pollen', '4_Usoskin'}

for i = 1:4
    load(['Test_' dataset{i}]);
    X_log10 = log10(in_X+1);
    D = size(X_log10,2);

    %Center data
    X_mean = mean(X_log10,1);
    %X_mean = mean(in_X,1);
    X = X_log10 - X_mean;%./std(X_log10,1);
    %X = X./(repmat(sum(X.*X,2).^.5,1,D));

    C = max(true_labs); %%% number of clusters
    rng('default');

    opt = struct;
    opt.scaleopt='normal';      %normal or log
    opt.p=1;                    %0<p<=1
    opt.initopt='pca';          %random or pca
    opt.svdopt='normal';    %normal or randomized
    opt.maxiter=20;            %default
    opt.epsilon=10^-10;         %default
    
    X_ggd = X./(repmat(sum(X.*X,2).^.5,1,D));
   
    [y, S, F, ydata,alpha] = SIMLR(in_X,C,10);
    idx = kmeans(ydata, C);
    [acc, rand_ind, match] = AccMeasure(true_labs, idx);
    pred_labs = zeros(size(true_labs));
    for j=1:C
        pred_labs(idx == match(2,j)) = match(1,j);
    end
    %NMI = Cal_NMI(y, true_labs);
    NMI = Cal_NMI(pred_labs, true_labs);
    disp('SIMLR')
    fprintf(['The NMI value for dataset ' dataset{i} ' is %f\n'], NMI);
    %subplot(2,2,pi);

    Vk = fms(X, 2, opt);
    proj_X_fms = X * Vk;
    idx = kmeans(proj_X_fms,C);
    [acc, rand_ind, match] = AccMeasure(true_labs, idx);
    pred_labs = zeros(size(true_labs));
    for j=1:C
        pred_labs(idx == match(2,j)) = match(1,j);
    end
    NMI = Cal_NMI(true_labs, pred_labs);
    disp('FMS')
    fprintf(['The NMI value for dataset ' dataset{i} ' is %f\n'], NMI);
    
    [Vk, conv] = ggd(X_ggd,1,100,2,0);
    proj_X_ggd = X_ggd * Vk;
    idx = kmeans(proj_X_ggd, C);
    [acc, rand_ind, match] = AccMeasure(true_labs, idx);
    pred_labs = zeros(size(true_labs));
    for j=1:C
        pred_labs(idx == match(2,j)) = match(1,j);
    end
    NMI = Cal_NMI(true_labs, pred_labs);
    disp('GGD')
    fprintf(['The NMI value for dataset ' dataset{i} ' is %f\n'], NMI);
    
    figure;
    gscatter(ydata(:,1),ydata(:,2),true_labs);
    title(['SIMLR data' dataset{i}])
    figure;
    gscatter(proj_X_fms(:,1),proj_X_fms(:,2),true_labs);
    title(['FMS data' dataset{i}]);
    figure;
    gscatter(proj_X_ggd(:,1),proj_X_ggd(:,2),true_labs);
    title(['GGD data' dataset{i}]);
    hold off

end
