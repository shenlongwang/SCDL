clc;clear;
addpath('Data');
addpath('Utilities');

load Kodak_Train24;
load params par param;
par.nFactor = 3;
for i = 1 : 24
    imHR               =   double(HR_tr{i});
    [im_h, im_w]       =   size(imHR);
    imLR           =   imHR(1 : par.nFactor : im_h, 1 : par.nFactor : im_w);
    [CX CY] = meshgrid(1 : im_w, 1:im_h);
    [X Y] = meshgrid(1:par.nFactor:im_w, 1:par.nFactor:im_h);
    imBicubic  =   interp2(X, Y, imLR, CX, CY, 'spline');
    if (size(imHR, 1) > size(imBicubic, 1))
        [im_h, im_w]       =   size(imBicubic);
        imHR = imHR(1:im_h, 1:im_w, :);
    end
    fprintf('PSNR of Bicubic Training Image: %2.2f \n', csnr(imBicubic, imHR, 5, 5));
    HR_tr{i} = imHR;
    LR_Bicubic{i} = imBicubic;
end

psf = fspecial('gauss', par.win+2, 2.2);
XH = [];
XL = [];
YH = [];
YL = [];
for i = 1 : 12    
    [Th Tl] = data2patch(conv2(HR_tr{i}, psf, 'same') - HR_tr{i}, conv2(LR_Bicubic{i}, psf, 'same') - LR_Bicubic{i}, par);
    [Th2 Tl2] = data2patch(HR_tr{i}, LR_Bicubic{i}, par);
    idx = randperm(size(Th, 2));
    Th = Th(:, idx(1:40000));
    Tl = Tl(:, idx(1:40000));
    Th2 = Th2(:, idx(1:40000));
    Tl2 = Tl2(:, idx(1:40000));   
    YH = [YH, Th];
    YL = [YL, Tl];    
    XH = [XH, Th2];
    XL = [XL, Tl2];
end
[cls_idx,vec,cls_num]  =  My_kmeans(YH, 32, 200);
for c = 1 : cls_num
    idx = find(cls_idx == c);
    if (length(idx) > 40000)
        select_idx = randperm(length(idx));
        idx = idx(select_idx(1:40000));
    end
    Yh{c} = YH(:, idx);
    Yl{c} = YL(:, idx);
    Xh{c} = XH(:, idx);
    Xl{c} = XL(:, idx);
end
clear YH XH YL XL;

for i = 13 : 24    
    [Th Tl] = data2patch(conv2(HR_tr{i}, psf, 'same') - HR_tr{i}, conv2(LR_Bicubic{i}, psf, 'same') - LR_Bicubic{i}, par);
    [Th2 Tl2] = data2patch(HR_tr{i}, LR_Bicubic{i}, par);
    idx_temp = setPatchIdx(Th, vec');
    for c = 1 : cls_num
        if (size(Yh{c}, 2) < 30000)
            Yh{c} = [Yh{c}, Th(:, idx_temp == c)];
            Yl{c} = [Yl{c}, Tl(:, idx_temp == c)];
            Xh{c} = [Xh{c}, Th2(:, idx_temp == c)];
            Xl{c} = [Xl{c}, Tl2(:, idx_temp == c)];
        end
    end
end
clear YH XH YL XL;
save KMeans_5x5_32_Factor3 Xh Yh Xl Yl par param; 