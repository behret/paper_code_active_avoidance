function varargout = testFilters(varargin)
% TESTFILTERS MATLAB code for testFilters.fig
%      TESTFILTERS, by itself, creates a new TESTFILTERS or raises the existing
%      singleton*.
%
%      H = TESTFILTERS returns the handle to a new TESTFILTERS or the handle to
%      the existing singleton*.
%
%      TESTFILTERS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TESTFILTERS.M with the given input arguments.
%
%      TESTFILTERS('Property','Value',...) creates a new TESTFILTERS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before testFilters_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to testFilters_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help testFilters

% Last Modified by GUIDE v2.5 25-Oct-2017 15:16:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @testFilters_OpeningFcn, ...
                   'gui_OutputFcn',  @testFilters_OutputFcn, ...
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







% --- Executes just before testFilters is made visible.
function testFilters_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for testFilters
handles.output = hObject;

% parse inputs
handles.frame = varargin{1};

% plot original frame
imagesc(handles.frame,'Parent', handles.original)
colormap gray
set(handles.original,'XTick',[])
set(handles.original,'YTick',[])
axes(handles.original)
title('Original')

% plot filtered frames
plotLowPass(handles);
plotBandPass(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes untitled1 wait for user response (see UIRESUME)
uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = testFilters_OutputFcn(hObject, eventdata, handles) 
valLowPass = get(handles.slider1,'Value');
valBandPassLow = get(handles.slider2,'Value');
valBandPassHigh = get(handles.slider3,'Value');
varargout{1} = [round(valLowPass) round(valBandPassLow) round(valBandPassHigh)];
delete(handles.figure1)








%%%%%%%%%%%%%
% CALLBACKS %
%%%%%%%%%%%%%

function slider1_Callback(hObject, eventdata, handles)
plotLowPass(handles)

function slider1_CreateFcn(hObject, eventdata, handles)
% set slider to initial value
minValLowPass = 1;
maxValLowPass = 20;
initialValLowPass = 4;
set(hObject,'Min',minValLowPass)
set(hObject,'Max',maxValLowPass)
set(hObject,'Value',initialValLowPass)
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function slider2_Callback(hObject, eventdata, handles)
plotBandPass(handles)

function slider2_CreateFcn(hObject, eventdata, handles)
minValLowPass = 1;
maxValLowPass = 100;
initialValLowPass = 50;
set(hObject,'Min',minValLowPass)
set(hObject,'Max',maxValLowPass)
set(hObject,'Value',initialValLowPass)
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function slider3_Callback(hObject, eventdata, handles)
plotBandPass(handles)

function slider3_CreateFcn(hObject, eventdata, handles)
minValLowPass = 1;
maxValLowPass = 100;
initialValLowPass = 30;
set(hObject,'Min',minValLowPass)
set(hObject,'Max',maxValLowPass)
set(hObject,'Value',initialValLowPass)
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end





%%%%%%%%%%%%%%%%%%%%
% HELPER FUNCTIONS %
%%%%%%%%%%%%%%%%%%%%

function plotLowPass(handles)
valLowPass = get(handles.slider1,'Value'); 
[ outFrame,cutoffFilter ] = getFilteredFrame( handles.frame,valLowPass );
imagesc(outFrame,'Parent', handles.lowPass)
colormap gray
set(handles.lowPass,'XTick',[])
set(handles.lowPass,'YTick',[])
axes(handles.lowPass)
title('Image Divided by Low-pass')

imagesc(cutoffFilter,'Parent', handles.lowPassFilter)
set(handles.lowPassFilter,'XTick',[])
set(handles.lowPassFilter,'YTick',[])
axes(handles.lowPassFilter)
title('Low-pass Filter')


function plotBandPass(handles)
valBandPassLow = get(handles.slider2,'Value');
valBandPassHigh = get(handles.slider3,'Value');
[ outFrame,cutoffFilter ] = getFilteredFrame( handles.frame,[valBandPassLow valBandPassHigh]);
imagesc(outFrame,'Parent', handles.bandPass)
colormap gray
set(handles.bandPass,'XTick',[])
set(handles.bandPass,'YTick',[])
axes(handles.bandPass)
title('BP-Filtered Image')

imagesc(cutoffFilter,'Parent', handles.bandPassFilter)
set(handles.bandPassFilter,'XTick',[])
set(handles.bandPassFilter,'YTick',[])
axes(handles.bandPassFilter)
title('Band-pass Filter')


function [ outFrame,cutoffFilter ] = getFilteredFrame( frame,filterVal )
if length(filterVal) > 1 % band pass if two values
    padSize = max(size(frame));
    filterSize = [size(frame,1) + 2*padSize , size(frame,2) + 2*padSize];
    lowpassFilter = mat2gray(fspecial('gaussian',filterSize,filterVal(1)));
    highpassFilter = 1 - mat2gray(fspecial('gaussian',filterSize,filterVal(2)));
    cutoffFilter = mat2gray(highpassFilter.*lowpassFilter);
    outFrame = filterImage( frame, cutoffFilter, padSize, 'bandpass' );    
else % low pass if one values
    padSize = max(size(frame));
    filterSize = [size(frame,1) + 2*padSize , size(frame,2) + 2*padSize];
    cutoffFilter = mat2gray(fspecial('gaussian',filterSize,filterVal));
    outFrame = filterImage( single(frame), cutoffFilter, padSize, 'lowpass' );   
end
