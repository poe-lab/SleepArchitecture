function varargout = StateAnalysisTools(varargin)
% STATEANALYSISTOOLS M-file for StateAnalysisTools.fig
%      STATEANALYSISTOOLS, by itself, creates a new STATEANALYSISTOOLS or raises the existing
%      singleton*.
%
%      H = STATEANALYSISTOOLS returns the handle to a new STATEANALYSISTOOLS or the handle to
%      the existing singleton*.
%
%      STATEANALYSISTOOLS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STATEANALYSISTOOLS.M with the given input arguments.
%
%      STATEANALYSISTOOLS('Property','Value',...) creates a new STATEANALYSISTOOLS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before StateAnalysisTools_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to StateAnalysisTools_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help StateAnalysisTools

% Last Modified by GUIDE v2.5 12-Nov-2009 11:50:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @StateAnalysisTools_OpeningFcn, ...
                   'gui_OutputFcn',  @StateAnalysisTools_OutputFcn, ...
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


% --- Executes just before StateAnalysisTools is made visible.
function StateAnalysisTools_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to StateAnalysisTools (see VARARGIN)

% Choose default command line output for StateAnalysisTools
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes StateAnalysisTools wait for user response (see UIRESUME)
% uiwait(handles.background);


% --- Outputs from this function are returned to the command line.
function varargout = StateAnalysisTools_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in phaseCalcButton.
function phaseCalcButton_Callback(hObject, eventdata, handles) %#ok<*DEFNU>
% hObject    handle to phaseCalcButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PhaseCalculatorGUI  %Opens the phase calculator program.
delete(handles.figure1) %Closes the State Analysis toolbox.

% --- Executes on button press in timeBinAnalysisButton.
function timeBinAnalysisButton_Callback(hObject, eventdata, handles)
% hObject    handle to timeBinAnalysisButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
StateTimeBinAnalysis  %Opens the time bin state analysis program.
delete(handles.figure1) %Closes the State Analysis toolbox.

% --- Executes on button press in powerFrequencyButton.
function powerFrequencyButton_Callback(hObject, eventdata, handles)
% hObject    handle to powerFrequencyButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SeqPSDvFrequencyAnalysis
delete(handles.figure1)

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
TrackPositionGUI
delete(handles.figure1)

% --- Executes during object creation, after setting all properties.
function bgPhoto_CreateFcn(hObject, eventdata, handles) %#ok<*INUSD>
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1
axes(hObject) %#ok<MAXES>

rgb = imread('C:\Sleepscorer\StateAnalysisToolsBackgroundb.jpg');
image(rgb);
axis off
