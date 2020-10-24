function [Arena, FPS] = ...
    flyload(VidObj, channel2choose,...
    nframe_flyload, firstframe2load, frames2skip, nVidFrame, vidDuration,...
    quietmode,...
    cropindex1, cropindex2, cropindex3, cropindex4, cropindex1_manual, cropindex3_manual)

%% Initiation
%{
%tic
disp('==================================')
disp('Initiation')
targetfps=0.1;
channel2choose=1; % Default RGB channel to choose. 1 = R, 2 = G, 3 = B.
firstframe2load=100;

filename = uigetfile('*.MP4','Select the video file');
VidObj = VideoReader(filename);
nVidFrame = VidObj.NumberOfFrames;
%nVidFrame = 1000;
vidHeight = VidObj.Height;
vidWidth = VidObj.Width;
vidfps = VidObj.FrameRate;
vidDuration = VidObj.Duration;
%vidDuration=nVidFrame/vidfps;

frames2skip=round(vidfps/targetfps);
nframe_flyload=length(firstframe2load : frames2skip : nVidFrame);

%Mov(1:nframe_flyload) = struct('cdata', zeros(vidHeight, vidWidth, 3, 'uint8'), 'colormap', []);
%toc
%}

%% Cropping Measurement
%{
%tic
disp('==================================')
disp('Cropping Measurement')
Mov=read(VidObj,firstframe2load);
figure(99)
imshow(Mov(:,:,channel2choose))
croptangle=imrect;
position=wait(croptangle);
close 99
cropindex1=round(position(2));
cropindex2=round(position(4))+round(position(2));
cropindex3=round(position(1));
cropindex4=round(position(3))+round(position(1));

%toc
%}

%% Loading Data
%
%tic
disp('==================================')
disp('Loading Data')
if quietmode==0
    dispbar=waitbar(0,['Loading Data Video',num2str(vid_num),' - Arena',num2str(arena_num)]);
end

% Determine the arena height and width
arena_height = cropindex4 - cropindex3;
arena_width = cropindex2 - cropindex1;

% (Outside this function, for each Arena)
% For each frame, get full frame and crop it to this arena.
Arena = uint8(ones(arena_height , arena_width , nframe_flyload));
for i = firstframe2load : frames2skip : nVidFrame
    Mov = read(VidObj , i);
    Mov_singlechannel=Mov(:,:,channel2choose);
    Arena(:,:,(i - firstframe2load) / frames2skip + 1) = ...
        Mov_singlechannel(cropindex3 + cropindex1_manual : cropindex4 + cropindex1_manual - 1 ,...
        cropindex1 + cropindex3_manual : cropindex2 + cropindex3_manual - 1);
    if quietmode==0
        waitbar(i/nVidFrame,dispbar)
    end
end

if quietmode==0
    close(dispbar)
end

endframe = i;
%toc
%}

%% Processing
%
%tic
disp('==================================')
disp('Processing')

for i = 1 : nframe_flyload
    % Reverse the arena
    Arena(:,:,i) = imcomplement(Arena(:,:,i));
end

FPS = nframe_flyload / (vidDuration*(endframe-1)/(nVidFrame-1));
end

%implay(Arena,FPS)
%toc
%}

%keep Arena FPS filename arena_num trace_data_mat
