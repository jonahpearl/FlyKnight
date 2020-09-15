function varargout = flyprimegui(varargin)
% FLYPRIMEGUI MATLAB code for flyprimegui.fig
%      FLYPRIMEGUI, by itself, creates a new FLYPRIMEGUI or raises the existing
%      singleton*.
%
%      H = FLYPRIMEGUI returns the handle to a new FLYPRIMEGUI or the handle to
%      the existing singleton*.
%
%      FLYPRIMEGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FLYPRIMEGUI.M with the given input arguments.
%
%      FLYPRIMEGUI('Property','Value',...) creates a new FLYPRIMEGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before flyprimegui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to flyprimegui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help flyprimegui

% Last Modified by GUIDE v2.5 27-Nov-2013 15:50:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @flyprimegui_OpeningFcn, ...
                   'gui_OutputFcn',  @flyprimegui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before flyprimegui is made visible.
function flyprimegui_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to flyprimegui (see VARARGIN)
handles.mac=getmac;
% if strcmp(handles.mac,'B8-CA-3A-8C-4C-AB')==0
%     exit
% end

% Load the setting file
% settings_file = importdata('flytrack_settings.csv');
settings_file = importdata('flytrack_settings.xlsx');
% settings_file = importdata('settings_file.mat');

% General path of videos
% genvidpath = settings_file.textdata{1};
% handles.genvidpath = genvidpath(strfind(genvidpath, ',')+1:end);
genvidpath = settings_file.textdata{1,2};
handles.genvidpath = genvidpath;

YesNo = evalin('base','exist(''run_list'',''var'')');
handles.firstframe2load=100;
handles.channel2choose=1;

if YesNo==1
    handles.runlist=evalin('base','run_list');
    handles.runlistindex=size(handles.runlist,1)+1;
    set(handles.listbox_filenames,'String',handles.runlist(:,1))
else
    handles.runlist={};
    handles.runlistindex=1;
end
assignin('base', 'mac', handles.mac);


% Choose default command line output for flyprimegui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes flyprimegui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = flyprimegui_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in loadvidbut.
function loadvidbut_Callback(hObject, ~, handles)
% hObject    handle to loadvidbut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, filepath] = uigetfile( fullfile(handles.genvidpath,'*.MP4'),'Select the video file');

addpath(filepath);

num_vids=inputdlg('Enter the number of videos','Number of Videos');
isgap=inputdlg('Gap/empty wells? (1=yes, 0=no)','Gaps/empty wells');
if str2double(isgap{1})==0
    cropindex1_manual=5;
    cropindex2_manual=715;
    cropindex3_manual=1;
    cropindex4_manual=1280;
else
    h=msgbox('Please wait ~60 secs for loading');
    VidObj = VideoReader(filename);
    Mov=read(VidObj,handles.firstframe2load);
    delete(h)
    figure(99)
    imshow(Mov(:,:,handles.channel2choose))
    croptangle=imrect;
    position_manual=wait(croptangle);
    close 99
    cropindex1_manual=round(position_manual(2));
    cropindex2_manual=round(position_manual(4))+round(position_manual(2));
    cropindex3_manual=round(position_manual(1));
    cropindex4_manual=round(position_manual(3))+round(position_manual(1));
end


handles.runlist{handles.runlistindex,1}=filename;
handles.runlist{handles.runlistindex,2}=filepath;
handles.runlist{handles.runlistindex,3}=num_vids;
handles.runlist{handles.runlistindex,4}=[cropindex1_manual,cropindex2_manual,cropindex3_manual,cropindex4_manual];
handles.runlistindex=handles.runlistindex+1;
set(handles.listbox_filenames,'String',handles.runlist(:,1))
assignin('base', 'run_list', handles.runlist);
guidata(hObject, handles);






% --- Executes on selection change in listbox_filenames.
function listbox_filenames_Callback(~, ~, ~)
% hObject    handle to listbox_filenames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_filenames contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_filenames


% --- Executes during object creation, after setting all properties.
function listbox_filenames_CreateFcn(hObject, ~, ~)
% hObject    handle to listbox_filenames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in closebutton.
function closebutton_Callback(~, ~, ~)
% hObject    handle to closebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(gcf)


% --- Executes on button press in pushbutton_delete.
function pushbutton_delete_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_delete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
todelete=get(handles.listbox_filenames,'Value');
handles.runlist(todelete,:)='';
set(handles.listbox_filenames,'String',handles.runlist(:,1))
assignin('base', 'run_list', handles.runlist);
handles.runlistindex=handles.runlistindex-length(todelete);
guidata(hObject, handles);
    
