%%Laboratorio Morfologia
%%Equipo MRI: Andrea Corrales, Isabela Resendez, Rael Barragan, Juan Diego
%%Garcia
%% Mathematical Morphology
%Imprime la imagen de radiograph1

f=imread('radiograph1.jpg');
f=double(f(:,:,1));
f=f/max(max(f));
f=imresize(f,0.25);
figure(1)
imshow(f,[]);
title('imagen original')

%% Dilatation
%La funcion dilate, dilata la imagen dejandola un poco borrosa
se = strel('disk',5);
BW2 = imdilate(f,se); % se determina el valor de dilatación
imshow(BW2), title('Dilated') 

% Use different disk size
%% Erosion
%Esta funcion resalta los espacios en aires, dandose a notar mas los
%pulmones

se = strel('disk',5);
BW3 = imerode(f,se);
imshow(BW3), title('Eroded')%parece que los pixeles se reducen y se hacen grandes
figure;
% Use different disk size
imshowpair(BW2,BW3,'montage'), title('comparativa') % la diferencia es que uno resalta mas los claros y otra los oscuros
%% Opening
%Esta funcion utiliza ambas funcionces, erosion al inicio y dilatacion posteriormente, en la misma
%imagen, abriendo la escala de grises
se = strel('disk',7);
BW2 = imopen(f,se);
imshow(BW2), title('Opening')
%crea una borrosidad en toda la imagen que hace que no se vean los bordes
% Use different disk size
%% Closing
%Esta funcion utiliza ambas funcionces, dilatacion al inicio y erosion posteriormente, en la misma
%imagen, cerrando la escala de grises
se = strel('disk',7);
BW2 = imclose(f,se);
imshow(BW2), title('Closing') 
% lo borroso ahora ya tiene un poco mas de definición sin embargo se mira
% mucha sombra en los bordes de la imagen
% Use different disk size
%% Gradient
%Esta funcion dilata la escala de grises
se = strel('disk',1);
BW1 = imdilate(f,se) - imerode(f,se);
imshow(BW1), title('Gradient')

% la imagen se mira mas oscura, los pixeles blancos se ven reducidos
% Use different disk size

%% Preprocess the Image The Rice Matlab Example
% Read an image into the workspace.

I = imread('rice.png');
imshow(I), title('imagen original')
%% 
% The background illumination is brighter in the center of the image than at 
% the bottom. Preprocess the image to make the background illumination more uniform.
% 
% As a first step, remove all of the foreground (rice grains) using morphological 
% opening. The opening operation removes small objects that cannot completely 
% contain the structuring element. Define a disk-shaped structuring element with 
% a radius of 15, which fits entirely inside a single grain of rice.

se = strel('disk',15)
%% 
% To perform the morphological opening, use |imopen| with the structuring element.

background = imopen(I,se);
imshow(background)
%% 
% Subtract the background approximation image, |background|, from the original 
% image, |I|, and view the resulting image. After subtracting the adjusted background 
% image from the original image, the resulting image has a uniform background 
% but is now a bit dark for analysis.

I2 = I - background;
imshow(I2)
%% 
% Use |imadjust| to increase the contrast of the processed image |I2| by saturating 
% 1% of the data at both low and high intensities and by stretching the intensity 
% values to fill the |uint8| dynamic range.

I3 = imadjust(I2);
imshow(I3)
%% 
% Note that the prior two steps could be replaced by a single step using |imtophat| 
% which first calculates the morphological opening and then subtracts it from 
% the original image.
% 
% |I2 = imtophat(I,strel('disk',15));|
%% 
% Create a binary version of the processed image so you can use toolbox functions 
% for analysis. Use the |imbinarize| function to convert the grayscale image into 
% a binary image. Remove background noise from the image with the |bwareaopen| 
% function.

bw = imbinarize(I3);
bw = bwareaopen(bw,50);
imshow(bw)

% Use different size of the structural element

%% Skeletonize 2-D Grayscale Image
% Read a 2-D grayscale image into the workspace. Display the image. Objects 
% of interest are dark threads against a light background.

I = imread('threads.png');
imshow(I)
%% 
% Skeletonization requires a binary image in which foreground pixels are |1| 
% (white) and the background is |0| (black). To make the original image suitable 
% for skeletonization, take the complement of the image so that the objects are 
% light and the background is dark. Then, binarize the result.

Icomplement = imcomplement(I);
BW = imbinarize(Icomplement);
imshow(BW)
%% 
% Perform skeletonization of the binary image using |bwskel|.

out = bwskel(BW);
%% 
% Display the skeleton over the original image by using the |labeloverlay| function. 
% The skeleton appears as a 1-pixel wide blue line over the dark threads.

imshow(labeloverlay(I,out,'Transparency',0))
%% 
% Prune small spurs that appear on the skeleton and view the result. One short 
% branch is pruned from a thread near the center of the image.

out2 = bwskel(BW,'MinBranchLength',15);
imshow(labeloverlay(I,out2,'Transparency',0))
%Play with the size of Min Branch Lenght

%% The alternative method with bwmorph

BW3 = bwmorph(BW,'skel',Inf);
figure
imshow(BW3)
%% Lets play with the x-ray

se = strel('disk',7);
BW3 = f-imopen(f,se);
imshow(BW3,[])
bw = imbinarize(BW3);
imshow(bw,[])
bw = imopen(bw,strel('disk',1));
bw = imclose(bw,strel('disk',3));
imshow(bw,[])
bw = bwareaopen(bw,50);
imshow(bw,[])
BW3 = bwmorph(bw,'skel',Inf);
imshow(BW3)
imshow(labeloverlay(f,BW3,'Transparency',0))

% Do the same with your own image