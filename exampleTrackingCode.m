tic

startNumberImg = 1;
NotchX = 5999; %% initial notch X coordinate from picture
NotchY = 3111; %% initial notch Y coordinate from picture
thresholdFactor = 1.75; %treshold

cd ../lomakii1/Specimen20/img20200601/

inputImages = dir('SSP_*.JPG'); %Finding the input image name

cd ../../../coffenm1/

names = {inputImages(:).name};
namesSort = natsortfiles(names); %Sorting the files 

cd ../lomakii1/Specimen20/img20200601/

images = string(namesSort);
N = length(inputImages); %How meny images there are
NumberOfCycles = 1110304; %% Total number of cycles from machine
Scale = 5.2521e-6; %% scale showing how many meters in one pixel
CyclesPerImage = NumberOfCycles/N;
resultTable = zeros([N 6]);
% cd('inputData\End\')
mkdir("Tracker_1.75"); %Creating folder "Tracker"
crackTipX = 5999;
crackTipY = 3111;
m = 6720; %size of the image in x-axis
n = 4480; %size of the image in y-axis
for i = 1:1000:N  %% Processing images one-by-one
    filename = images(i);    
    A = imread(filename);
%  image(A)
% This section consider crack branching in 1 predefined cases. Block problematic noise using these.
%{
        if i >= 1 && i <= 19999 %% 1
            A = A(:,:,1);
            Xo = 5999;
            Yo = 3111;
            Rad = 100;
            [CrclX, CrclY] = meshgrid(1:m, 1:n);
            circlePix = (CrclX - Xo).^2 + (CrclY - Yo).^2 <= Rad.^2;
            A(circlePix) = 3;
        end


   %% End of branches declaration
    %}
    B = A(crackTipY-74:crackTipY+75,crackTipX-324:crackTipX+75);
    %%image(B)
    Th = mean(B(1:end,1:125),"all");
    E = imbinarize(B, (Th*thresholdFactor)/255);
    F = E*255;
    %%image(F);
    G = bwconncomp(E);
    numPixels = cellfun(@numel,G.PixelIdxList);
    [biggest,idx] = max(numPixels);
    H = zeros([150 400]);
    H(G.PixelIdxList{idx}) = 255;
    % image(H);
    [rowX,colX] = find(H==255);
    member = 1:1:400;
    allRovs = ismember(member,colX);
    indexedCols = find(allRovs == 1)
    Xsmallpix = min(indexedCols);
    %% START section
    % This section finds number of first column with a sequence of N
    % non-zeros elements
    % N = 10; % Required number of consecutive numbers following a first one
    % x = diff(indexedCols)==1;
    % f = find([false,x]~=[x,false]);
    % g = find(f(2:2:end)-f(1:2:end-1)>=N,1,'first');
    % Xsmallpix = indexedCols(f(2*g-1)); % First Col followed by >=N consecutive numbers
    %% FINISH section
    [rowY,colY] = find(H(:,Xsmallpix)==255);
    Ysmallpix = ceil(mean(rowY,"all"));
    Tracker = insertShape(F,'circle', [Xsmallpix Ysmallpix 5],'LineWidth', 2, "Color","red");
    %%image(Tracker);

    	
    trackName  = replace(filename, '.JPG', '.png');
    trackName = fullfile('Tracker_1.75',trackName);
    imwrite(Tracker,trackName);
    

    resultTable(i,1) = (startNumberImg-1) + i;    %% Image number
    resultTable(i,2)= round(i*CyclesPerImage);  %% Cycle number as a result of averaging cycles per image. Total number of cycles devided per total number of images
    resultTable(i,3) = crackTipX - (324 -Xsmallpix); %% Absolute X coordinates of the crack Tip on the image
    resultTable(i,4) = crackTipY - (74 - Ysmallpix);  %% Absolute Y coordinates of the crack Tip on the image
    resultTable(i,5) = (NotchX-crackTipX)*Scale;   %% Actual lenght of crack in X direction
    resultTable(i,6) = (NotchY-crackTipY)*Scale;   %% Actual lenght of crack in Y direction
    %% resultTable(i-1,5) = 0.016768191; %% this line should be swithed on while processing partially
    %% resultTable(i-1,6) = -0.000969016; %% this line should be swithed on while processing partially
    crackTipX = resultTable(i,3);
    crackTipY = resultTable(i,4);
    %{
    graphIndex = 1;
    num1 =xlsread('results.xlsx')
    x1=num1(:,5); %X-crack length
    y1=num1(:,2); %Cycle number
    %figure;
    plot(x1,y1), xlabel('crack length'), ylabel('Cycle number'), title('Crack length to cyckle number'),
    grid on;
    ax = gca;
    ax = fullfile('AnimatedGraph',ax)
    imwrite(graph, ax)
    %exportgraphics(ax, 'AnimatedGraph'+graphIndex+'.png')
    graphIndex = graphIndex + 1;
    %}
    
end
writematrix(resultTable, 'results_1.75.xlsx'); %saveing data as xlsx 



%Saveing Graph 
num = xlsread('results_1.75.xlsx')
x=num(:,2); %Cycle number
y=num(:,5); %X-crack length
%figure;
plot(x,y), ylabel('crack length'), xlabel('Cycle number'), title('Crack length to cycle number'),
grid on;
ax = gca;
exportgraphics(ax, 'Graph9_1.75.png');
%{
%GIF maker-----------------
cd Tracker_1.75/
inputImages = dir('SSP_*.png'); %Finding the input image name
cd ../
names = {inputImages(:).name};
namesSort = natsortfiles(names); %Sorting the files 
cd Tracker_1.75/
images = string(namesSort);

N = length(inputImages); %How meny images there are
step = 10
h = figure;
gifname = 'CrackGif_1.75.gif';
for i = 1:step:N  %% Processing images one-by-one
    filename = images(i);    
    A = imread(filename);
 
      [imind,cm] = rgb2ind(A,256); 
      % Write to the GIF File 
      if i == 1
          imwrite(imind,cm,gifname,'gif', 'Loopcount',Inf, 'DelayTime', 0.05); 
      else 
          imwrite(imind,cm,gifname,'gif','WriteMode','append', 'DelayTime', 0.05); 
      end 
end
cd ../

%}

toc
