function [inter_fly_dist, Flags, background] = flytrack(Arena, FPS, vid_num, arena_num, settings_file, quietmode, backgroundInput)


%%%%%%%%%%%%%%%% Flytrack %%%%%%%%%%%%%%%%%
%%%%%%%%%%%% Harvard University %%%%%%%%%%%
%%%%%%%%%%%%%%% Rogulja Lab %%%%%%%%%%%%%%%
%%%%%%%%%%% Crickmore Research %%%%%%%%%%%%
%%%%%%% Programmed by Stephen Zhang %%%%%%%
%%%%%%%%% Version 0.10 08/24/2013 %%%%%%%%%
%%%%%%%%% Version 0.20 08/25/2013 %%%%%%%%%
%%%%%%%%% Version 0.30 08/26/2013 %%%%%%%%%
%%%%%%%%% Version 0.31 09/10/2013 %%%%%%%%%
%%%%%%%%% Version 0.32 09/11/2013 %%%%%%%%%
%%%%%%%%% Version 0.40 09/14/2013 %%%%%%%%%
%%%%%%%%% Version 0.41 09/16/2013 %%%%%%%%%
%%%%%%%%% Version 0.42 09/20/2013 %%%%%%%%%
%%%%%%%%% Version 0.50 09/21/2013 %%%%%%%%%
%%%%%%%%% Version 0.60 09/22/2013 %%%%%%%%%
%%%%%%%%% Version 0.63 09/26/2013 %%%%%%%%%
%%%%%%%%% Version 0.70 10/16/2013 %%%%%%%%%
%%%%%%%%% Version 0.80 11/03/2013 %%%%%%%%%
%%%%%%%%% Version 0.90 11/03/2013 %%%%%%%%%
%%%%%%%%% Version 1.00 12/24/2014 %%%%%%%%%

%% Initiation
%
%tic

disp('===========================================')
disp('Initiation')


% Determine the estimated size of a fly
% flysize = settings_file{9};
% flysize = str2double(flysize(strfind(flysize, ',')+1:end));
flysize = settings_file.data(4);

% Determine the gamma for intensity thresholding
% gamma = settings_file{10};
% gamma = str2double(gamma(strfind(gamma, ',')+1:end));
gamma = settings_file.data(5); % 5 for lightpad, 2 for heatrig

% Determine the threshold of bw thresholding
% custom_bw_threshold_modifier = settings_file{13};
% custom_bw_threshold_modifier = str2double(custom_bw_threshold_modifier(strfind(custom_bw_threshold_modifier, ',')+1:end));
custom_bw_threshold_modifier = settings_file.data(8);

% Determine the area threshold for demooning
% demoon_cutoff = settings_file{14};
% demoon_cutoff = str2double(demoon_cutoff(strfind(demoon_cutoff, ',')+1:end));
demoon_cutoff = settings_file.data(9);

% Pixels per cm, from settings file
pixel_per_cm = settings_file.data(14); % 108 for lightpad, 96 for heatright


% Get the dimensions fo the arena
viddim = size(Arena);

% Get how many frames are in the arena
% COMMON ERROR: Video is too short. Stuck in try-catch to make it clear
try
    nframe = viddim(3);
catch err
    disp('ERROR: ONE OF THE VIDEO FILES IS TOO SHORT. Make sure the videos are all longer than 1 minute.')
end
% Get the x-y size of the arena
% arena_dim = viddim(1:2);

% 2 fly tracking
nfly = 2;

if arena_num == 1
    % Set up the flag matrix of what happens in each frame
    Flags = zeros( nframe, 1 ); 
    % 0-normal 1-reduction 2-watershed 3-anti-overwatershed 
    % 4-force(dot) 5-force(ext) 6-force(int) 7-creation
    % The tens digit refers to whether this frame is demooned
    % 1X - demooned, 0X - not demooned
    

end
%toc
%}

%% Color Adjustment and Background Calculation
%
%tic
disp('===========================================')
disp('Background Calculation')

% If first video, call flytrackbackground function to calculate the background
% If not first video, receives background from first video.

if backgroundInput == -1
    background = flytrackbackground( Arena, FPS, nframe, settings_file );
else
    background = backgroundInput;
end

%toc
%}

%% Background Correction and Tracking
%
%tic
disp('===========================================')
disp('Background Correction and Tracking');

% Prime the matrices of for frame processing. As of now, these matrices are
% not outputed
arena_rev_nbg_bw_erode = single(zeros(viddim)); % I am leaving the erode unchanged throughout the code
arena_rev_nbg_bw_erode_lb = zeros(viddim);

% Prime a vector to record how many flies were finally detected in each
% frame
nflydetected = zeros(nframe,1);

% Counters for processes
n_watershed = 0;
n_force_seg = 0;
n_reduce = 0;
n_created = 0;

clear props; % This step seems needed no matter what

% Prime the props structure to record the properties of flies
props(1:nfly,1:nframe) = struct('Centroid',zeros(1,2,'double')); %,'Area',[],'MajorAxisLength',[],'MinorAxisLength',[],'Eccentricity',[],'Orientation',[]);

% If quiet mode is off, let people know what is going on
if quietmode == 0
    dispbar = waitbar(0,['Tracking Video',num2str(vid_num),'- Arena',num2str(arena_num)]);
end

for i=1:nframe
%     tic
    % Subtract the background and threshold the frame
    arena_rev_nbg_bw = flytrackbw( Arena, i, background, gamma, custom_bw_threshold_modifier);
    
    % Remove the moon-shaped ring before erosion
    % JP notes: this sometimes creates an issue when fly is touching the
    % edge of the arena, so one or both flies are removed along with the
    % "moon" (the edge of the arena).
    [ arena_rev_nbg_bw, Flags(i) ] = flytrackdemoon( arena_rev_nbg_bw, demoon_cutoff);
    
    % Erode the images (get rid of small shades) and label them
    arena_rev_nbg_bw_erode(:,:,i) = imerode(arena_rev_nbg_bw,strel('disk', flysize));
    [ arena_rev_nbg_bw_erode_lb(:,:,i) , nflydetected(i) ] = bwlabel( arena_rev_nbg_bw_erode(: , : , i ));
    
    if nflydetected(i) < nfly % Need watershed
        %disp(['Frame ' , num2str(i) , ' Watershedding'])
        n_watershed = n_watershed + 1;
        [ arena_rev_nbg_bw_erode_lb(:,:,i), nflydetected(i), Flags(i) ] = flytrackwatershed( arena_rev_nbg_bw_erode(:,:,i), nfly, Flags(i) );
        
        if nflydetected(i) < nfly % Need force segmentation (dot removal)
            %disp('Watershedding Unsuccessful')
            n_force_seg = n_force_seg + 1;
            [ arena_rev_nbg_bw_erode_lb(:,:,i), nflydetected(i), Flags(i) ] = flytrackdotremoval( arena_rev_nbg_bw_erode(:,:,i), nfly, Flags(i) );
            
            if nflydetected(i) < nfly % Need force segmentation (external ring removal)
                %disp('Dot removal Unsuccessful')
                [ arena_rev_nbg_bw_erode_lb(:,:,i), nflydetected(i), Flags(i) ] = flytrackexring( arena_rev_nbg_bw_erode(:,:,i), nfly, Flags(i) );
                
                if nflydetected(i) < nfly % Need force segmentation (internal ring removal)
                    %disp('External Ring Removal Unsuccessful') % Initiate internal ring removal
                    [ arena_rev_nbg_bw_erode_lb(:,:,i), nflydetected(i), Flags(i) ] = flytrackinring( arena_rev_nbg_bw_erode(:,:,i), nfly, Flags(i) );
                    
                    if nflydetected(i) < nfly % Need to create a fly
                        % Flag creation
                        Flags(i) = Flags(i) + 7;
                        
                        if i == 1
                            % If this is the first frame, start creating
                            arena_rev_nbg_bw_erode_lb(:,:,i) = flytrackcreation( arena_rev_nbg_bw_erode(:,:,i),2);
                            nflydetected(i) = nfly;
                        else
                            % If this is not the first frame, use
                            % everything from the last frame (temporary solution)
                            arena_rev_nbg_bw_erode_lb(:,:,i) = arena_rev_nbg_bw_erode_lb(:,:,i-1);
                            nflydetected(i) = nflydetected(i-1);
                        end
                    end
                end
            end
        end
                       
    elseif nflydetected(i) > nfly % Reduce arena if too many flies
        n_reduce = n_reduce + 1;
        % The flag and nflydetected here are predictable since the function
        % never fails
        Flags(i) =Flags(i) + 1;
        nflydetected(i) = nfly;
        arena_rev_nbg_bw_erode_lb(:,:,i) = flytrackreduction( arena_rev_nbg_bw_erode_lb(:,:,i) , nfly );
    end
    
    props(:,i)=regionprops(arena_rev_nbg_bw_erode_lb(:,:,i),'Centroid'); %,'Orientation','Area','Eccentricity','MajorAxisLength','MinorAxisLength');
    
    if quietmode==0
        waitbar(i/nframe,dispbar)
    end
    
%     toc
end
% arena_rev_nbg_bw_erode_lb=uint8(arena_rev_nbg_bw_erode_lb); % If this
% matrix is outputed, then uint8 is suggested to reduce memory usage
% arena_rev_nbg_bw_erode=uint8(arena_rev_nbg_bw_erode); % If this matrix is
% outputed, then uint8 is suggested to reduce memory usage
if quietmode==0
    close(dispbar)
end
disp(['Video',num2str(vid_num),'- Arena',num2str(arena_num)])
disp(['Watershedding done: ' , num2str(n_watershed)])
disp(['Forced Segmentation done: ' , num2str(n_force_seg)])
disp(['Reduction done: ' , num2str(n_reduce)])
disp(['Creation done: ' , num2str(n_created)])
%toc
%}

%% 1st Order Data
%
%tic
disp('===========================================')
disp('1st Order Data')
Centroids=ones(nframe,2,nfly).*NaN; 
% Area=ones(nframe,nfly).*NaN;
% MajorAxisLength=ones(nframe,nfly).*NaN;
% MinorAxisLength=ones(nframe,nfly).*NaN;
% Eccentricity=ones(nframe,nfly).*NaN;
% Orientation=ones(nframe,nfly).*NaN;

for i=1:nfly
    Centroids(:,:,i) = round( reshape( [ props(i,:).Centroid ]' , [ 2 , nframe ] )' );
%     Area(:,i)=reshape([props(i,:).Area]',[1,nframe])';
%     MajorAxisLength(:,i)=reshape([props(i,:).MajorAxisLength]',[1,nframe])';
%     MinorAxisLength(:,i)=reshape([props(i,:).MinorAxisLength]',[1,nframe])';
%     Eccentricity(:,i)=reshape([props(i,:).Eccentricity]',[1,nframe])';
%     Orientation(:,i)=reshape([props(i,:).Orientation]',[1,nframe])';
end

% Add a designation step here

%toc

%}

%% Designation
%
disp('===========================================')
disp('Designation')

%tic
[ CentroidsA, CentroidsB, ~, ~ ] = flytrackdesignation( Centroids, nframe );
% AreaA=sum(Area.*FlyA,2);
% AreaB=sum(Area.*FlyB,2);
% MajorAxisLengthA=sum(MajorAxisLength.*FlyA,2);
% MajorAxisLengthB=sum(MajorAxisLength.*FlyB,2);
% MinorAxisLengthA=sum(MinorAxisLength.*FlyA,2);
% MinorAxisLengthB=sum(MinorAxisLength.*FlyB,2);
% EccentricityA=sum(Eccentricity.*FlyA,2);
% EccentricityB=sum(Eccentricity.*FlyB,2);
% OrientationA=sum(Orientation.*FlyA,2);
% OrientationB=sum(Orientation.*FlyB,2);

%toc
%}

%% Visualization
% The positions have not been re mapped after designation.

%tic
disp('===========================================')
disp('Visualization')

% 
marker_layer=zeros(viddim);
for i=1:nfly
    for j=1:nframe
        marker_layer(Centroids(j,2,i),Centroids(j,1,i),j)=1; % (y,x) because on a image, down means y increases (counterintuitive from matrix)
    end
end

combined_layer=mat2gray(Arena)+marker_layer;
implay(combined_layer,FPS*50)
%toc


%% 2nd Order Data
%
%tic
disp('===========================================')
disp('2nd Order Data')
% Unit Conversion
%{
figure(99)
imshow(Arena(:,:,1))
h = imline;
position = wait(h);
delta_position=diff(position);
calibration_pixels=sqrt(delta_position(1).^2+delta_position(2).^2);
pixel_per_cm=calibration_pixels/calibration_line_length;
close 99
%}


%cm_per_pixel= ; % Direct Input is fine too

% Calculate Distances
%speedcap=80;
centroid_delta_spatial = CentroidsA - CentroidsB;

% Calculate the final distance to output
inter_fly_dist = sqrt( centroid_delta_spatial( : , 1 ).^2 +...
    centroid_delta_spatial( : , 2 ) .^ 2 ) ./ pixel_per_cm;
%outlierindex=find(abs(diff(inter_fly_dist))>0.3);
%duplicated_outlier=find(diff(outlierindex)==1);
%outlierindex(duplicated_outlier)=[];
%inter_fly_dist_filtered=[(1:nframe)'/FPS,inter_fly_dist];
%inter_fly_dist_filtered(outlierindex,:)=[];

% Plot Distances

%
%     figure(arena_num+80)
%     plot((1:nframe)/FPS/60,inter_fly_dist,'-');
%     find(Flags==1)/FPS/60,0.7,'r.',...
%     find(Flags==2)/FPS/60,0.71,'r.')
%     find(Flags==3)/FPS/60,0.72,'r.',...
%     find(Flags==4)/FPS/60,0.73,'r.',...
%     find(Flags==5)/FPS/60,0.74,'r.',...
%     find(Flags==6)/FPS/60,0.75,'r.',...
%     find(Flags==7)/FPS/60,0.76,'r.')

% xlabel('Time/min')
% ylabel('Inter Fly Distances/cm')
% title('Distance')
%}

%{
figure
plot(inter_fly_dist_filtered(:,1),inter_fly_dist_filtered(:,2))
xlabel('Time/sec')
ylabel('Inter Fly Distances/cm')
title('Filtered distance')
%}



% Calculate Speeds (need fly designation)
%{
centroid_delta_temporal_A=diff(CentroidsA);
centroid_delta_temporal_B=diff(CentroidsB);
speeds=ones(nframe-1,nfly).*NaN;
speeds(:,1)=sqrt(centroid_delta_temporal_A(:,1).^2+centroid_delta_temporal_B(:,1).^2)/pixel_per_cm*FPS;
speeds(:,2)=sqrt(centroid_delta_temporal_B(:,1).^2+centroid_delta_temporal_B(:,2).^2)/pixel_per_cm*FPS;
%

% Plot Speeds
%
figure
plot((1:nframe-1)/FPS/60,speeds(:,1),(1:nframe-1)/FPS/60,speeds(:,2))
xlabel('Time/min')
ylabel('speeds/cm*s^-^1')
title('speed')
legend('FlyA','FlyB')

%}

%toc
%}



% keep Arena CentroidsA CentroidsB EccentricityA EccentricityB FPS MajorAxisLengthA MajorAxisLengthB MinorAxisLengthA MinorAxisLengthB...
%     OrientationA OrientationB arena_rev_nbg_bw_erode arena_rev_nbg_bw_erode_lb backcalcskip_endframe background background_calc_end_time...
%     backgroundcalcstack flysize gamma inter_fly_dist inter_fly_dist_filtered n_anti_overshed n_created n_force_seg n_reduce n_watershed nfly...
%     nflydetected nframe pixel_per_cm arena_dim fwatershed fforce_seg fanti_overshed freduce fcreate FlyA FlyB AreaA AreaB Flags filename arena_num

%% 2nd Order Data
%{
%tic
disp('===========================================')
disp('2nd Order Data')
%toc
%}

%% 2nd Order Data
%{
%tic
disp('===========================================')
disp('2nd Order Data')
%toc
%}

%% 2nd Order Data
%{
%tic
disp('===========================================')
disp('2nd Order Data')
%toc
%}
end


