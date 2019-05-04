%% Prime Initiation
%

Knightmode=1;
firstframe2load=100;
channel2choose=1;

if exist('run_list','var')==0
    run_list={};
end

run_list_index=size(run_list,1)+1;

filename = uigetfile('J:\Copulation_Duration_Videos\*.MP4','Select the video file');
filepath=['J:\Copulation_Duration_Videos\',filename(1:10),'\'];
addpath(filepath);
num_vids=inputdlg('Enter the number of videos','Number of Videos');

run_list{run_list_index,1}=filename;
run_list{run_list_index,2}=filepath;
run_list{run_list_index,3}=num_vids;

VidObj = VideoReader(filename);
Mov=read(VidObj,firstframe2load);
figure(99)
imshow(Mov(:,:,channel2choose))
croptangle=imrect;
position_manual=wait(croptangle);
close 99

cropindex1_manual=round(position_manual(2));
cropindex2_manual=round(position_manual(4))+round(position_manual(2));
cropindex3_manual=round(position_manual(1));
cropindex4_manual=round(position_manual(3))+round(position_manual(1));

run_list{run_list_index,4}=[cropindex1_manual,cropindex2_manual,cropindex3_manual,cropindex4_manual];
keep run_list

%}