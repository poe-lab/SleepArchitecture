function varargout = StateTimeBinAnalysis(varargin)
% STATETIMEBINANALYSIS M-file for StateTimeBinAnalysis.fig
%      STATETIMEBINANALYSIS, by itself, creates a new STATETIMEBINANALYSIS or raises the existing
%      singleton*.
%
%      H = STATETIMEBINANALYSIS returns the handle to a new STATETIMEBINANALYSIS or the handle to
%      the existing singleton*.
%
%      STATETIMEBINANALYSIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STATETIMEBINANALYSIS.M with the given input arguments.
%
%      STATETIMEBINANALYSIS('Property','Value',...) creates a new STATETIMEBINANALYSIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before StateTimeBinAnalysis_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to StateTimeBinAnalysis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help StateTimeBinAnalysis

% Last Modified by GUIDE v2.5 03-Jul-2014 09:31:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @StateTimeBinAnalysis_OpeningFcn, ...
                   'gui_OutputFcn',  @StateTimeBinAnalysis_OutputFcn, ...
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

% --- Executes just before StateTimeBinAnalysis is made visible.
function StateTimeBinAnalysis_OpeningFcn(hObject, eventdata, handles, varargin)
global batchProcess
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to StateTimeBinAnalysis (see VARARGIN)

% Choose default command line output for StateTimeBinAnalysis
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
batchProcess = 1;

% UIWAIT makes StateTimeBinAnalysis wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = StateTimeBinAnalysis_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when selected object is changed in scoredTypePanel.
function scoredTypePanel_SelectionChangeFcn(hObject, eventdata, handles)
global batchProcess

switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'radiobutton1'
        batchProcess = 1; % Code for when 'Batch Processing' radio button is selected.
    case 'radiobutton2'
        batchProcess = 0; % Code for when "Single File' radio button is selected.
end

% --- Executes on button press in analyzeButton.
function analyzeButton_Callback(hObject, eventdata, handles) %#ok<*INUSL>
% hObject    handle to analyzeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global batchProcess
timeBinSize = str2double(get(handles.binSize,'String'));   % returns contents of binSize as a double
working_dir=pwd;
current_dir='C:\SleepData\Results';
cd(current_dir);

%% Load Scored File(s) files
if batchProcess
    % Select folder and get list of Excel files:
    fileType = '*.xls';
    [dataFolder, fileName, numberOfDataFiles] = batchLoadFiles(fileType);
else
    dataFolder = [];
    fileName = [];
    fileSelectedCheck = 0;
    % Select a single file:
    while isequal(fileSelectedCheck,0)
        [fileName, dataFolder] = uigetfile('*.xls', 'Select the scored file');
        if isempty(fileName) || isempty(dataFolder)
            uiwait(errordlg('You need to select a file. Please try again',...
                'ERROR','modal'));
        else
            fileSelectedCheck = 1;
        end 
    end
    cd(working_dir);
    numberOfDataFiles = 1;
end
for m = 1:numberOfDataFiles
    StateAnalysis_xHrBins(dataFolder,fileName(m,:), timeBinSize);
end
cd(working_dir);
msgbox('Analysis complete.','Pop-up');

function binSize_Callback(hObject, eventdata, handles) %#ok<*INUSD>

tBin = str2double(get(hObject,'String'));  % returns contents of binSize as a double
if isnan(tBin)
    set(hObject, 'String', 2);
    errordlg('Input must be a number','Error');
end
if tBin <= 0
    set(hObject, 'String', 2);
    errordlg('Bin size must be > 0 Hours','Error');
end

% --- Executes during object creation, after setting all properties.
function binSize_CreateFcn(hObject, eventdata, handles) %#ok<*DEFNU>

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
