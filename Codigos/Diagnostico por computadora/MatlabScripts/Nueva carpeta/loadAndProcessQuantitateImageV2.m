%% Filename
quantiativeData = [];
imagename = strcat(melanomapath,imageFile);

%% Image Loading
f=imread(imagename);
sz = size(f);
f=double(imresize(f,[512,512*sz(2)/sz(1)]))/255;
f=imcrop(f,[32 32 (512*sz(2)/sz(1)-32) 480 ]);
f=histeq(f);
figure(1)
subplot(2,2,1)
imshow(f)
title(imageFile);
grayscale = min(f,[],3);
maskthr = max([0.125,0.85*graythresh(grayscale)]);
mask = grayscale <= maskthr;
subplot(2,2,2)
imshow(mask,[])
title('Raw Mask');
filterDisk0 = strel('disk',5);
filterDisk = strel('disk',50);
filterDisk2 = strel('disk',5);
filterDisk3 = strel('disk',10);
maskMorph = imclose(mask,filterDisk0);
maskMorph = imopen(maskMorph,filterDisk);
maskMorph = imclose(maskMorph,filterDisk);
finalmask = imdilate(maskMorph,filterDisk2);
%imshow(finalmask,[])

controlmask = imdilate(finalmask,filterDisk)-finalmask;

%%
subplot(2,2,3)
imshow(grayscale)
title('Min Grayscale');
subplot(2,2,4)
lesionimage = f.*finalmask ;
imshow(lesionimage,[]);
title('Lesion Mask');

controlimage = f.*controlmask;
subplot(2,2,2)
imshow(controlimage)
title('Control Mask');


%% Extract features

for (channel = 1:3)
    
    LesionData = lesionimage(:,:,channel) + not(finalmask);
%    imshow(LesionData,[]);
    histoData = reshape(LesionData(finalmask),1,[]);
    temp_mean = mean(histoData);
    temp_m2 = moment(histoData,2);
    temp_m3 = moment(histoData,3);
    temp_m4 = moment(histoData,4);
    
    masked_m2 = sqrt(moment(histoData,2));
    masked_m3 = moment(histoData,3);
    masked_m3 = power(abs(masked_m3),1/3).*sign(masked_m3);
    masked_m4 = power(moment(histoData,4),1/4);
    dq = quantile(histoData,[0.01,0.05,0.25,0.5,0.75,0.95,0.99]);
    cov=0;
    q90cov=0;
    if (abs(temp_mean) > 0)
        cov = log(10000.0*masked_m2/abs(temp_mean) + 1.0);
    end
    if (abs(dq(4)) > 0)
        q90cov = log(10000.0*(dq(6)-dq(2))/abs(dq(4)) + 1.0);
    end

    [N,edges] = histcounts(histoData,32);
    N = N/sum(N);
    N = N.*log(N);
    TF = isnan(N);
    N(TF) = 0;

    entropy = -sum(N);
    

    quantiativeData = [quantiativeData,temp_mean,masked_m2,masked_m3,masked_m4,entropy,cov,q90cov];

    %%%%%%%%%%%%%%%% Temperature GLCM %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    glcm_0 = graycomatrix(LesionData,'NumLevels',numGLCMBins,'GrayLimits',[0.0,1.00],'Offset',[0 1; -1 1; -1 0; -1 -1],'Symmetric',true);
    glcm_1 = graycomatrix(LesionData(finalmask),'NumLevels',numGLCMBins,'GrayLimits',[0.0,1.00],'Offset',[0 1; -1 1; -1 0; -1 -1],'Symmetric',true);
    glcm_2 = graycomatrix(LesionData(finalmask),'NumLevels',numGLCMBins,'GrayLimits',[0.0,1.00],'Offset',[0 2; -2 2; -2 0; -2 -2],'Symmetric',true);
    glcm_3 = graycomatrix(LesionData(finalmask),'NumLevels',numGLCMBins,'GrayLimits',[0.0,1.00],'Offset',[0 4; -3 3; -4 0; -3 -3],'Symmetric',true);
    glcm_4 = graycomatrix(LesionData(finalmask),'NumLevels',numGLCMBins,'GrayLimits',[0.0,1.00],'Offset',[0 8; -6 6; -8 0; -6 -6],'Symmetric',true);
%    glcm_0 = sum(glcm_0,3);
    glcm_1 = sum(glcm_1,3);
    glcm_2 = sum(glcm_2,3);
    glcm_3 = sum(glcm_3,3);
    glcm_4 = sum(glcm_4,3);
    GLCM_stats_1 = graycoprops(glcm_1);
    GLCM_stats_2 = graycoprops(glcm_2);
    GLCM_stats_3 = graycoprops(glcm_3);
    GLCM_stats_4 = graycoprops(glcm_4);

    quantiativeData = [quantiativeData,GLCM_stats_1.Contrast,GLCM_stats_1.Correlation,GLCM_stats_1.Energy,GLCM_stats_1.Homogeneity];
    quantiativeData = [quantiativeData,GLCM_stats_2.Contrast,GLCM_stats_2.Correlation,GLCM_stats_2.Energy,GLCM_stats_2.Homogeneity];
    quantiativeData = [quantiativeData,GLCM_stats_3.Contrast,GLCM_stats_3.Correlation,GLCM_stats_3.Energy,GLCM_stats_3.Homogeneity];
    quantiativeData = [quantiativeData,GLCM_stats_4.Contrast,GLCM_stats_4.Correlation,GLCM_stats_4.Energy,GLCM_stats_4.Homogeneity];


    GLCMSlope = [abs(log(1/2*(1.001-GLCM_stats_1.Correlation)/(1.001-GLCM_stats_2.Correlation)))/log(2)];
    GLCMSlope = [GLCMSlope,abs(log(1/2*(1.001-GLCM_stats_2.Correlation)/(1.001-GLCM_stats_3.Correlation)))/log(2)];
    GLCMSlope = [GLCMSlope,abs(log(1/4*(1.001-GLCM_stats_1.Correlation)/(1.001-GLCM_stats_3.Correlation)))/log(4)];
    GLCMSlope = [GLCMSlope,abs(log(1/2*(1.001-GLCM_stats_3.Correlation)/(1.001-GLCM_stats_4.Correlation)))/log(2)];
    GLCMSlope = [GLCMSlope,abs(log(1/4*(1.001-GLCM_stats_2.Correlation)/(1.001-GLCM_stats_4.Correlation)))/log(4)];
    GLCMSlope = [GLCMSlope,abs(log(1/8*(1.001-GLCM_stats_1.Correlation)/(1.001-GLCM_stats_4.Correlation)))/log(8)];
    meanGLCMSlope = mean(GLCMSlope);

    quantiativeData = [quantiativeData,meanGLCMSlope];

    GLCMSlope = [abs(log(1/2*GLCM_stats_1.Contrast/GLCM_stats_2.Contrast))/log(2)];
    GLCMSlope = [GLCMSlope,abs(log(1/2*GLCM_stats_2.Contrast/GLCM_stats_3.Contrast))/log(2)];
    GLCMSlope = [GLCMSlope,abs(log(1/4*GLCM_stats_1.Contrast/GLCM_stats_3.Contrast))/log(4)];
    GLCMSlope = [GLCMSlope,abs(log(1/2*GLCM_stats_3.Contrast/GLCM_stats_4.Contrast))/log(2)];
    GLCMSlope = [GLCMSlope,abs(log(1/4*GLCM_stats_2.Contrast/GLCM_stats_4.Contrast))/log(4)];
    GLCMSlope = [GLCMSlope,abs(log(1/8*GLCM_stats_1.Contrast/GLCM_stats_4.Contrast))/log(8)];

    meanGLCMSlope = mean(GLCMSlope);

    quantiativeData = [quantiativeData,meanGLCMSlope];


    GLCMSlope = [abs(log(2*GLCM_stats_1.Energy/GLCM_stats_2.Energy))/log(2)];
    GLCMSlope = [GLCMSlope,abs(log(2*GLCM_stats_2.Energy/GLCM_stats_3.Energy))/log(2)];
    GLCMSlope = [GLCMSlope,abs(log(4*GLCM_stats_1.Energy/GLCM_stats_3.Energy))/log(4)];
    GLCMSlope = [GLCMSlope,abs(log(2*GLCM_stats_3.Energy/GLCM_stats_4.Energy))/log(2)];
    GLCMSlope = [GLCMSlope,abs(log(4*GLCM_stats_2.Energy/GLCM_stats_4.Energy))/log(4)];
    GLCMSlope = [GLCMSlope,abs(log(8*GLCM_stats_1.Energy/GLCM_stats_4.Energy))/log(8)];

    meanGLCMSlope = mean(GLCMSlope);

    quantiativeData = [quantiativeData,meanGLCMSlope];


    GLCMSlope = [abs(log(1/2*(1.001-GLCM_stats_1.Homogeneity)/(1.001-GLCM_stats_2.Homogeneity)))/log(2)];
    GLCMSlope = [GLCMSlope,abs(log(1/2*(1.001-GLCM_stats_2.Homogeneity)/(1.001-GLCM_stats_3.Homogeneity)))/log(2)];
    GLCMSlope = [GLCMSlope,abs(log(1/4*(1.001-GLCM_stats_1.Homogeneity)/(1.001-GLCM_stats_3.Homogeneity)))/log(4)];
    GLCMSlope = [GLCMSlope,abs(log(1/2*(1.001-GLCM_stats_3.Homogeneity)/(1.001-GLCM_stats_4.Homogeneity)))/log(2)];
    GLCMSlope = [GLCMSlope,abs(log(1/4*(1.001-GLCM_stats_2.Homogeneity)/(1.001-GLCM_stats_4.Homogeneity)))/log(4)];
    GLCMSlope = [GLCMSlope,abs(log(1/8*(1.001-GLCM_stats_1.Homogeneity)/(1.001-GLCM_stats_4.Homogeneity)))/log(8)];

    meanGLCMSlope = mean(GLCMSlope);

    quantiativeData = [quantiativeData,meanGLCMSlope];


end

allquantiativeData = [allquantiativeData;quantiativeData];