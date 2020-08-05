function varargout = rangefinder(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @rangefinder_OpeningFcn, ...
                   'gui_OutputFcn',  @rangefinder_OutputFcn, ...
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

function rangefinder_OpeningFcn(hObject, eventdata, handles, varargin)
set(handles.axes2,'XTick',[],'YTick',[])
movegui(hObject,'center')
set(handles.parar_b,'UserData',0)
set(handles.axes1,'XTick',[],'YTick',[])
imaqreset
handles.output = hObject;
guidata(hObject, handles);

function varargout = rangefinder_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function inicio_b_Callback(hObject, eventdata, handles)
set(handles.inicio_b,'Enable','off')
set(handles.parar_b,'UserData',0)
start(handles.vid);
res=handles.vid.VideoResolution;
ancho=res(1);
alto    =res(2);
lim_f1=ceil(alto/2);
lim_f2=ceil(alto-1);
lim_c1=ceil(ancho/2-25);
lim_c2=ceil(ancho/2+24);
limites=[lim_f1,lim_f2,lim_c1,lim_c2];
if strcmp(handles.vid.VideoFormat,'RGB24_320x240')
    convertir=0;
else
    convertir=1;
end
while true    
    if get(handles.parar_b,'UserData')
        stop(handles.vid);
        break
    end
    imgn = getdata(handles.vid,1,'uint8');       
    if convertir==1, imgn=ycbcr2rgb(imgn); end
    axes(handles.axes1);
    image(imgn);
     axis off 
    [X, Y, distancia]=detect_fcn(imgn,limites);       
    set(handles.x_coord,'String',X)
    set(handles.y_coord,'String',Y)
    set(handles.distancia,'String',distancia)
end

guidata(hObject, handles);

function parar_b_Callback(hObject, eventdata, handles)
set(handles.parar_b,'UserData',1)
set(handles.inicio_b,'Enable','on')


function figure1_CloseRequestFcn(hObject, eventdata, handles)
try
    if(strcmp(handles.vid.running,'on'))
    set(handles.parar_b,'UserData',1)
else
    delete(hObject);
    end
catch
    delete(hObject);
end

function camara_b_Callback(hObject, eventdata, handles)
sel_camera
uiwait
set(handles.inicio_b,'Enable','on')
set(handles.parar_b,'Enable','on')
global id es_web_ext
try
    if es_web_ext==1
        formato='RGB24_320x240';
    else
        errordlg('Camara no soportada','ERROR')
        return
    end
    handles.vid = videoinput('winvideo',id,formato);
    set(handles.vid,'TriggerRepeat',Inf);
    handles.vid.FrameGrabInterval = 3;    
catch
    msgbox('No hay cámara conectada')
end
guidata(hObject,handles)


