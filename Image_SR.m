clear;clc;
addpath('Data');
addpath('Utilities');
addpath('Dict');
addpath('SPAMS');
addpath('SPAMS/release/mkl64');

% Semi-Coupled Dictionary Learning for Super-Resolution
% Author: Shenlong Wang, 
% Latest Update: 6, June 2012
% This code is for the paper:

% S. Wang, L. Zhang, Y. Liang and Q. Pan, "Semi-coupled Dictionary Learning 
% with Applications in Super-resolution and Photo-Sketch Synthesis", in CVPR 2012. 

% Contact: {csslwang, cslzhang}@comp.polyu.edu.hk



load NaturalSR;
cls_num = 32;
nOuterLoop = 1;
nInnerLoop = 5;
load KMeans_5x5_32_Factor3 vec par param;


te_HR = double(imdong.Butterfly);
clear im imdong im_tr;
[im_h, im_w, im_c] = size(te_HR);
te_LR           =   te_HR(1 : par.nFactor : im_h, 1 : par.nFactor : im_w, :);
imwrite(uint8(te_LR), 'Result/GirlRGB_LR.png');
imwrite(uint8(te_HR), 'Result/GirlRGB_HR.png');

[im_hout] = scdl_interp(te_LR, im_h, im_w, par.nFactor);
if im_c == 3
    lum_out = double(rgb2ycbcr(uint8(im_hout)));
    lum_ori = double(rgb2ycbcr(uint8(te_HR)));
    fprintf('\nPSNR of Semi-Coupled DL: %2.2f \n', csnr(lum_out(:,:,1), lum_ori(:,:,1), 5, 5));
else
    fprintf('\nPSNR of Semi-Coupled DL: %2.2f \n', csnr(im_out, te_HR, 5, 5));
end
imwrite(uint8(im_hout),'Result/GirlRGB_ScDL_X3.png');
