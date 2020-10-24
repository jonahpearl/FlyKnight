function [FullMov, FPS] = ...
    flyloadspeedyvid(VidObj, channel2choose,...
    nframe_flyload, firstframe2load, frames2skip, nVidFrame, vidDuration)

disp('==================================')
disp('Loading Data')

% Read first frame to get size of video
firstFrame = read(VidObj , 1);
[nrow, ncol, ~] = size(firstFrame); % don't need 3rd dim, which is RGB channels

% pre-allocate frame-size x num frames matrix
FullMov = uint8(ones(nrow, ncol, nframe_flyload));

for i = firstframe2load : frames2skip : nVidFrame
    Mov = read(VidObj , i);
    Mov_singlechannel=Mov(:,:,channel2choose);
    FullMov(:,:,(i - firstframe2load) / frames2skip + 1) = Mov_singlechannel;
end


endframe = i;

%% Processing
disp('==================================')
disp('Processing')

for i = 1 : nframe_flyload
    % Reverse the arena
    FullMov(:,:,i) = imcomplement(FullMov(:,:,i));
end

FPS = nframe_flyload / (vidDuration*(endframe-1)/(nVidFrame-1));

end