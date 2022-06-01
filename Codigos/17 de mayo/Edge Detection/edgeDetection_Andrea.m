% semana 1
% clase 2 
% edge detection
% Andrea

%% Cargar imagenes
f=imread('radiograph1.jpg');
f=imresize(f,0.25);
f=double(f(:,:,1));
imshow(f,[])
%% se utiliza una mascara
edgex=[1,-1]; % se crea una máscara
g1=conv2(f,edgex,'same'); %convolución
imshow(g1,[-10,10]); % al hacer la convolución se 
title('Derivada en X')
%% 
edgey=[-1 -2 -1;0,0,0;1,2,1]/8 %
g2=conv2(f,edgey,'same');
imshow(g2,[-10,10])
figure(2)
subplot(1,2,1)
imshow(g1,[-10,10])
title('Dx')
subplot(1,2,2)
imshow(g2,[-10,10])
title('Dy')
figure(3)
subplot(1,1,1)
%%  sobel mask dx and dy for image gradient
edgex=[1,0,-1;2,0,-2;1,0,-1]/8
gx=conv2(f,edgex,'same');
gy=conv2(f,edgey,'same');
mag=abs(gx)+abs(gy);
imshow(mag,[]);
title('Gradient Magnitude=|dx|+|gy|')

%
%% estimar el nivel de ruido
noisemask = [-1, 0 1];
noiseimage = conv2(f,noisemask,'same'); 
noisevariance = mean2(noiseimage.^2); %estimar la varianza
noisestd = sqrt(noisevariance/2);
edgedetection1 = mag > noisestd; %el ruido tiene una magnitud mayor
edgedetection2 = mag > 2*noisestd;
subplot(1,2,1)
imshow(edgedetection1,[]);
title('edge detection at sigma')
subplot(1,2,2)
imshow(edgedetection2,[]);
title('edge detection at 2 sigma')
%% 
figure(4)
subplot(1,1,1)
angle=atan2(gy,gx); %angulo entre uno y otro
imshow(angle,[]);
title('orientación del gradiente')
colormap("autumn")

%%
edgcany=edge(f,'Canny');
imshow(edgcany,[]);
title('cany edge')