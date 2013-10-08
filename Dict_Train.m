clear;clc;
addpath('Data');
addpath('Utilities');
addpath('SPAMS');
addpath('SPAMS/release/mkl64');

% Parameters Setting
% par.cls_num            =    32
% par.nFactor            =    3;
% par.step               =    2;
% par.win                =    5;
% par.rho = 5e-2;
% par.lambda1         =       0.01;
% par.lambda2         =       0.001;
% par.mu              =       0.01;
% par.sqrtmu          =       sqrt(par.mu);
% par.nu              =       0.1;
% par.nIter           =       100;
% par.epsilon         =       5e-3;
% par.t0              =       5;
% par.K               =       256;
% par.L               =       par.win * par.win;
% param.K = par.K;
% param.lambda = par.lambda1;
% param.iter=300; 
% param.L = par.win * par.win;
% flag_initial_done = 0;
cls_num = 32;
load KMeans_5x5_32_Factor3;

% Initiate Dictionary


Dini = [];
for i = 1 : cls_num
    XH_t = double(Xh{i});
    XL_t = double(Xl{i});
    XH_t = XH_t - repmat(mean(XH_t), [par.win^2 1]);
    XL_t = XL_t - repmat(mean(XL_t), [par.win^2 1]);
    fprintf('Semi-Coupled dictionary learning: Cluster: %d\n', i);
    D = mexTrainDL([XH_t;XL_t], param);
    Dini{i} = D;
   save Data/Dict_SR_Initial Dini;
end

% Semi-Coupled Dictionary Learning
for i = 1 : cls_num
    load KMeans_5x5_32_Factor3 Xh Xl;
    XH_t = double(Xh{i});
    XL_t = double(Xl{i});
    clear Xh Xl;
    XH_t = XH_t - repmat(mean(XH_t), [par.win^2 1]);
    XL_t = XL_t - repmat(mean(XL_t), [par.win^2 1]);
    load Data/Dict_SR_Initial Dini;
    D = Dini{i};
    clear Dini;
    Dh = D(1:par.win * par.win,:);
    Dl = D(par.win * par.win+1:end,:);
    Wl = eye(size(Dh, 2));
    Wh = eye(size(Dl, 2));
    Alphah = mexLasso([XH_t;XL_t], D, param);
    Alphal = Alphah;
    clear D;
    fprintf('Semi-Coupled dictionary learning: Cluster: %d\n', i);
    [Alphah, Alphal, XH_t, XL_t, Dh, Dl, Wh, Wl, f] = coupled_DL(Alphah, Alphal, XH_t, XL_t, Dh, Dl, Wh, Wl, par);
    Dict.DH{i} = Dh;
    Dict.DL{i} = Dl;
    Dict.WH{i} = Wh;
    Dict.WL{i} = Wl;
    Dict.f{i} = f;
    save Dict_SR_Factor3_backup Dict;
end

