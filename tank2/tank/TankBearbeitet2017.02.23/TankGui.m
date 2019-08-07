function varargout = TankGui(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TankGui_OpeningFcn, ...
                   'gui_OutputFcn',  @TankGui_OutputFcn, ...
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

function handles = addSliderEdit(slider, edit, eventdata, handles)
    handles.sliders = [handles.sliders slider];
    handles.edits = [handles.edits edit];

    addlistener(slider,'ContinuousValueChange', @(hObject, event) slider_Callback(slider, eventdata, handles));
    addlistener(edit,'String', 'PostSet', @(hObject, event) edit_Callback(edit, eventdata, handles));
    
    %val = get(slider, 'Min');
    val = get(slider, 'Value');
    
    set(edit, 'String', num2str(val));
    set(slider, 'Value', val);
    
    %styling
    if isequal(get(slider,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(slider,'BackgroundColor',[.9 .9 .9]);
    end
    if ispc && isequal(get(edit,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(edit,'BackgroundColor','white');
    end

% --- Executes just before TankGui is made visible.
function TankGui_OpeningFcn(hObject, eventdata, handles, varargin)
    global cellsTime;
    global cellsHohe;
    global legendsHohe;
    global legendsTemp;
    global cellsSize;
    global cellsTemp;

% Choose default command line output for TankGui
clc

cellsTime=cell(10,1);
cellsHohe=cell(10,1);
legendsHohe=cell(10,1);
legendsTemp=cell(10,1);
cellsSize=0;
cellsTemp=cell(10,1);

handles.output = hObject;

handles.sliders = [];
handles.edits = [];
handles.t = timer('StartDelay', 0.1, 'TimerFcn', {@timer_callback,handles});

assignin('base', 'updating', 0)

handles=addSliderEdit(handles.slider_Tsoll, handles.edit_Tsoll, eventdata, handles);
handles=addSliderEdit(handles.slider_Vzu, handles.edit_Vzu, eventdata, handles);
handles=addSliderEdit(handles.slider_Pel, handles.edit_Pel, eventdata, handles);
handles=addSliderEdit(handles.slider_Tzu, handles.edit_Tzu, eventdata, handles);
handles=addSliderEdit(handles.slider_Tu, handles.edit_Tu, eventdata, handles);

handles=addSliderEdit(handles.slider_alpha, handles.edit_alpha, eventdata, handles);
handles=addSliderEdit(handles.slider_stufe1, handles.edit_stufe1, eventdata, handles);
handles=addSliderEdit(handles.slider_stufe2, handles.edit_stufe2, eventdata, handles);
handles=addSliderEdit(handles.slider_stufe3, handles.edit_stufe3, eventdata, handles);
handles=addSliderEdit(handles.slider_hysterese, handles.edit_hysterese, eventdata, handles);

handles=addSliderEdit(handles.slider_Ar, handles.edit_Ar, eventdata, handles);
handles=addSliderEdit(handles.slider_cp, handles.edit_cp, eventdata, handles);
handles=addSliderEdit(handles.slider_Kw, handles.edit_Kw, eventdata, handles);
handles=addSliderEdit(handles.slider_Kl, handles.edit_Kl, eventdata, handles);
handles=addSliderEdit(handles.slider_rho, handles.edit_rho, eventdata, handles);
handles=addSliderEdit(handles.slider_schrittweite, handles.edit_schrittweite, eventdata, handles);
handles=addSliderEdit(handles.slider_simTime, handles.edit_simTime, eventdata, handles);

handles.f1 = figure(1);
handles.f2 = figure(2);

set(handles.f1, 'visible', 'off');
set(handles.f2, 'visible', 'off');

set(handles.text_simulink, 'Visible', 'off');
set(handles.pushbutton_export, 'Enable', 'off');



guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = TankGui_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;

function disableControls(handles)
    set(findall(handles.uipanel_controls, '-property', 'Enable'), 'Enable', 'off');

function enableControls(handles)
    global cellsSize;

    set(findall(handles.uipanel_controls, '-property', 'Enable'), 'Enable', 'on');

    if (cellsSize > 0)
        set(handles.pushbutton_export, 'Enable', 'on');
    else
        set(handles.pushbutton_export, 'Enable', 'off');
    end

function setEdit(handles, edit, val)
    handles.thisEdit = edit;
    handles.val = val;

    stop(handles.t);

    handles.t = timer('StartDelay', 0.1, 'TimerFcn', {@timer_callback,handles});

    start(handles.t);

function setSlider(handles, slider, val)
    set(slider, 'Value', val);

    edit = [];
    
    for i=1:1:length(handles.sliders)
        if (slider == handles.sliders(i))
            edit = handles.edits(i);
        end
    end
    
    editVal = num2str(val);
    
    if (strcmp(get(edit, 'String'), editVal) == 0)
        setEdit(handles, edit, editVal);
    end
    
    update(handles);

function slider_Callback(hObject, eventdata, handles)
    setSlider(handles, hObject, get(hObject, 'Value'));
    
function timer_callback(obj, event, handles)
    newVal = num2str(handles.val);

    if (strcmp(get(handles.thisEdit, 'String'), newVal) == 0)
        assignin('base', 'updating', 1);
    
        set(handles.thisEdit, 'String', newVal);
        assignin('base', 'updating', 0);
    end
    
function edit_Callback(hObject, eventdata, handles)
    if (evalin('base', 'updating') == 1)
        return
    end

    thisEdit = hObject;
    
    val = get(thisEdit, 'String');
    
    thisSlider = [];

    for i=1:1:length(handles.edits)
        if (thisEdit == handles.edits(i))
            thisSlider = handles.sliders(i);
        end
    end
    
    if (length(val) == 0)
        val = 0;
    else
        val = str2double(val);
    end
    
    if (isnan(val))
        val = 0;
    end
    
    minSliderVal = get(thisSlider, 'Min');
    maxSliderVal = get(thisSlider, 'Max');

    if (val > maxSliderVal)
        val = maxSliderVal;
    end
    if (val < minSliderVal)
        val = minSliderVal;
    end

    handles.thisEdit = thisEdit;
    handles.val = val;

    stop(handles.t);

    handles.t = timer('StartDelay', 0.1, 'TimerFcn', {@timer_callback,handles});

    start(handles.t);
    
    if (get(thisSlider, 'Value') ~= val)
        set(thisSlider, 'Value', val);
    end
    
    update(handles)

function setConfig1(handles)
    setSlider(handles, handles.slider_Tsoll, 45);
    setSlider(handles, handles.slider_Tzu, 20);
    setSlider(handles, handles.slider_Vzu, 20);
    setSlider(handles, handles.slider_Pel, 1000);
    setSlider(handles, handles.slider_Tu, 25);
    
    setSlider(handles, handles.slider_alpha, 30);
    setSlider(handles, handles.slider_stufe1, 0.33);
    setSlider(handles, handles.slider_stufe2, 0.66);
    setSlider(handles, handles.slider_stufe3, 1.0);
    setSlider(handles, handles.slider_hysterese, 0.05);
    
    setSlider(handles, handles.slider_Ar, 12);
    setSlider(handles, handles.slider_cp, 4.19);
    setSlider(handles, handles.slider_Kw, 15);
    setSlider(handles, handles.slider_Kl, 7);
    setSlider(handles, handles.slider_rho, 1);
    
function setConfig2(handles)
    setSlider(handles, handles.slider_Tsoll, 40);
    setSlider(handles, handles.slider_Tzu, 20);
    setSlider(handles, handles.slider_Vzu, 20);
    setSlider(handles, handles.slider_Pel, 1000);
    setSlider(handles, handles.slider_Tu, 25);
    
    setSlider(handles, handles.slider_alpha, 30);
    setSlider(handles, handles.slider_stufe1, 0.33);
    setSlider(handles, handles.slider_stufe2, 0.66);
    setSlider(handles, handles.slider_stufe3, 1.0);
    setSlider(handles, handles.slider_hysterese, 0.05);
    
    setSlider(handles, handles.slider_Ar, 12);
    setSlider(handles, handles.slider_cp, 4.19);
    setSlider(handles, handles.slider_Kw, 15);
    setSlider(handles, handles.slider_Kl, 7);
    setSlider(handles, handles.slider_rho, 1);
    
    
function setConfig3(handles)
    setSlider(handles, handles.slider_Tsoll, 30);
    setSlider(handles, handles.slider_Tzu, 20);
    setSlider(handles, handles.slider_Vzu, 19);
    setSlider(handles, handles.slider_Pel, 1000);
    setSlider(handles, handles.slider_Tu, 25);
    
    setSlider(handles, handles.slider_alpha, 30);
    setSlider(handles, handles.slider_stufe1, 0.33);
    setSlider(handles, handles.slider_stufe2, 0.66);
    setSlider(handles, handles.slider_stufe3, 1.0);
    setSlider(handles, handles.slider_hysterese, 0.05);
    
    setSlider(handles, handles.slider_Ar, 12);
    setSlider(handles, handles.slider_cp, 4.19);
    setSlider(handles, handles.slider_Kw, 15);
    setSlider(handles, handles.slider_Kl, 7);
    setSlider(handles, handles.slider_rho, 1);
    
    
function update(handles)
      Vzu=get(handles.slider_Vzu,'Value')/3600;
      Ar=get(handles.slider_Ar,'Value')/10000;
      g=9.81;
      maxFullstand=Vzu^2/Ar^2/(2*g)*100;
      set(handles.txt_fA,'String',num2str(maxFullstand));

function execSim(handles)
    global cellsSize;
    
    if (cellsSize >= 5)
        msgbox('max 5 plots, reset please');
        
        return
    end

    %%
    global stufe0factor stufe1factor stufe2factor stufe3factor hysterese out_letzt;

    out_letzt = -1;
    
    %%
    thetaSoll=get(handles.slider_Tsoll, 'Value');
    thetaZu=get(handles.slider_Tzu, 'Value');
    Vzu=get(handles.slider_Vzu, 'Value')/3600;
    Pel=get(handles.slider_Pel, 'Value');
    thetaUm=get(handles.slider_Tu, 'Value');
    
    alpha = get(handles.slider_alpha, 'Value')*2*pi/360;
    stufe1factor = get(handles.slider_stufe1, 'Value');
    stufe2factor = get(handles.slider_stufe2, 'Value');
    stufe3factor = get(handles.slider_stufe3, 'Value');
    hysterese = get(handles.slider_hysterese, 'Value');
    
    if (stufe1factor < stufe2factor && stufe2factor < stufe3factor && stufe1factor < stufe3factor)
        Ar=get(handles.slider_Ar, 'Value')/10000;
        cp=get(handles.slider_cp, 'Value')*1000;
        Kw=get(handles.slider_Kw, 'Value');
        Kl=get(handles.slider_Kl, 'Value');
        rho=get(handles.slider_rho, 'Value');
        
        %%
        htank=1.5;
        g=9.81;
        stufe0 = 0.1;

        %%    
        minHohe=0.9*Vzu^2/Ar^2/(2*g);
        maxFullstand=Vzu^2/Ar^2/(2*g);
        
        if (maxFullstand < 0.6)
             msgbox('Max Füllstand sollte mindestens 60 cm sein');
             
             return
        end
        
        assignin('base', 'maxFullstand', maxFullstand);

        assignin('base', 'thetaSoll', thetaSoll);
        assignin('base', 'thetaZu', thetaZu);
        assignin('base', 'Vzu', Vzu);
        assignin('base', 'Pel', Pel);
        assignin('base', 'ThetaUm', thetaUm);

        assignin('base', 'Alpha', alpha);
        assignin('base', 'stufe1factor', stufe1factor);
        assignin('base', 'stufe2factor', stufe2factor);
        assignin('base', 'stufe3factor', stufe3factor);
        assignin('base', 'Hysterese', hysterese);

        assignin('base', 'Ar', Ar);
        assignin('base', 'cp', cp);
        assignin('base', 'Kw', Kw);
        assignin('base', 'Kl', Kl);
        assignin('base', 'rho', rho);

        stufe0factor = 0.1;
        hoheStart = 0.0001;
        thetaStart = thetaZu;

        assignin('base', 'MinHohe', minHohe);
        assignin('base', 'hoheStart', hoheStart);
        assignin('base', 'thetaStart', thetaStart);
        assignin('base', 'g', g);
        assignin('base', 'stufe0factor', stufe0factor);
        assignin('base', 'htank', htank);

        tic
        
        schrittweite = get(handles.slider_schrittweite, 'Value');
        simTime = get(handles.slider_simTime, 'Value');

        sim('TankSimulink_modell_deg2',0:schrittweite:simTime);

        toc

        hohe = simout.signals.values(:,1) * 100;
        temp = simout.signals.values(:,2);
        time = simout.time;

        %tempLegends = cellstr(sprintf('%.2f °C', thetaSoll));
        tempLegends = cellstr(sprintf('%.2f °C alpha=%.2f°, V_z_u=%.2fm^3/h', thetaSoll, alpha*360/(2*pi), Vzu*3600));
        
        hold (handles.plotter_fullstand,'on')
        hold (handles.plotter_temp,'on')
        
        global cellsTime;
        global cellsHohe;
        global legendsHohe;
        global legendsTemp;
        global cellsTemp;
       
        cellsSize = cellsSize + 1;
        
        cellsTime{cellsSize} = time;
        cellsHohe{cellsSize} = hohe;
        cellsTemp{cellsSize} = temp;
        legendsHohe{cellsSize} = tempLegends;
        legendsTemp{cellsSize} = tempLegends;

        allLegendTemp = [];
        allLegendHohe = [];
        
        for i=1:1:cellsSize
            time = cellsTime{i};
            hohe = cellsHohe{i};
            temp = cellsTemp{i};
            
            allLegendTemp = [allLegendTemp; legendsTemp{i}];
            allLegendHohe = [allLegendHohe; legendsHohe{i}];
        end
        
        if (cellsSize == 1)
            pTemp = plot(handles.plotter_temp,cellsTime{1},cellsTemp{1});
            pHohe = plot(handles.plotter_fullstand,cellsTime{1},cellsHohe{1});
        elseif (cellsSize == 2)
            pTemp = plot(handles.plotter_temp,cellsTime{1},cellsTemp{1},cellsTime{2},cellsTemp{2});
            pHohe = plot(handles.plotter_fullstand,cellsTime{1},cellsHohe{1},cellsTime{2},cellsHohe{2});
        elseif (cellsSize == 3)
            pTemp = plot(handles.plotter_temp,cellsTime{1},cellsTemp{1},cellsTime{2},cellsTemp{2},cellsTime{3},cellsTemp{3});
            pHohe = plot(handles.plotter_fullstand,cellsTime{1},cellsHohe{1},cellsTime{2},cellsHohe{2},cellsTime{3},cellsHohe{3});
        elseif (cellsSize == 4)
            pTemp = plot(handles.plotter_temp,cellsTime{1},cellsTemp{1},cellsTime{2},cellsTemp{2},cellsTime{3},cellsTemp{3},cellsTime{4},cellsTemp{4});
            pHohe = plot(handles.plotter_fullstand,cellsTime{1},cellsHohe{1},cellsTime{2},cellsHohe{2},cellsTime{3},cellsHohe{3},cellsTime{4},cellsHohe{4});
        elseif (cellsSize == 5)
            pTemp = plot(handles.plotter_temp,cellsTime{1},cellsTemp{1},cellsTime{2},cellsTemp{2},cellsTime{3},cellsTemp{3},cellsTime{4},cellsTemp{4},cellsTime{5},cellsTemp{5});
            pHohe = plot(handles.plotter_fullstand,cellsTime{1},cellsHohe{1},cellsTime{2},cellsHohe{2},cellsTime{3},cellsHohe{3},cellsTime{4},cellsHohe{4},cellsTime{5},cellsHohe{5});
        end
        
        legend(pTemp, allLegendTemp, 'Location', 'southeast');
        title(handles.plotter_temp, 'Temperatur');
        xlabel(handles.plotter_temp, 'Zeit [s]')
        ylabel(handles.plotter_temp, 'Temp [°C]')
        
        legend(pHohe, allLegendHohe, 'Location', 'southeast');
        title(handles.plotter_fullstand, 'Füllstand');
        xlabel(handles.plotter_fullstand, 'Zeit [s]')
        ylabel(handles.plotter_fullstand, 'Höhe [cm]')
        %zoom(handles.plotter_fullstand, 'on');
        
        if get(handles.checkbox_zoom, 'Value')
            zoom(handles.plotter_temp, 'on');
            datacursormode(gcf, 'off');
        else
            zoom(handles.plotter_temp, 'off');
            datacursormode(gcf, 'on');
        end
        %zoom(gcf, 'on');

        %repeat plot in figure for export
        f1 = figure(1);
        set(f1, 'visible', 'off');
        
        if (cellsSize == 1)
            pHohe = plot(cellsTime{1},cellsHohe{1});
        elseif (cellsSize == 2)
            pHohe = plot(cellsTime{1},cellsHohe{1},cellsTime{2},cellsHohe{2});
        elseif (cellsSize == 3)
            pHohe = plot(cellsTime{1},cellsHohe{1},cellsTime{2},cellsHohe{2},cellsTime{3},cellsHohe{3});
        elseif (cellsSize == 4)
            pHohe = plot(cellsTime{1},cellsHohe{1},cellsTime{2},cellsHohe{2},cellsTime{3},cellsHohe{3},cellsTime{4},cellsHohe{4});
        elseif (cellsSize == 5)
            pHohe = plot(cellsTime{1},cellsHohe{1},cellsTime{2},cellsHohe{2},cellsTime{3},cellsHohe{3},cellsTime{4},cellsHohe{4},cellsTime{5},cellsHohe{5});
        end
        
        %sprintf('Füllstand - alpha=%.2f°, V_z_u=%.2fm^3/h', alpha*360/(2*pi), Vzu*3600)
        title('Füllstand')
        xlabel('Zeit [s]')
        ylabel('Höhe [cm]')
        legend(allLegendHohe, 'Location', 'southeast')
        grid();

        %repeat plot in figure for export
        f2 = figure(2);
        set(f2, 'visible', 'off');
        
        if (cellsSize == 1)
            pTemp = plot(cellsTime{1},cellsTemp{1});
        elseif (cellsSize == 2)
            pTemp = plot(cellsTime{1},cellsTemp{1},cellsTime{2},cellsTemp{2});
        elseif (cellsSize == 3)
            pTemp = plot(cellsTime{1},cellsTemp{1},cellsTime{2},cellsTemp{2},cellsTime{3},cellsTemp{3});
        elseif (cellsSize == 4)
            pTemp = plot(cellsTime{1},cellsTemp{1},cellsTime{2},cellsTemp{2},cellsTime{3},cellsTemp{3},cellsTime{4},cellsTemp{4});
        elseif (cellsSize == 5)
            pTemp = plot(cellsTime{1},cellsTemp{1},cellsTime{2},cellsTemp{2},cellsTime{3},cellsTemp{3},cellsTime{4},cellsTemp{4},cellsTime{5},cellsTemp{5});
        end

        title('Temperatur')
        xlabel('Zeit [s]')
        ylabel('Temp [°C]')
        legend(allLegendTemp, 'Location', 'southeast')
        grid();
    else
        msgbox('stufe1 < stufe2 < stufe3 required');
    end
      
function pushbutton_start_Callback(hObject, eventdata, handles)
    clc

    disableControls(handles);
    set(handles.text_simulink, 'Visible', 'on')
    
    pause(0.1)
    
    execSim(handles);

    %re-enable pushbutton_start button
    set(handles.text_simulink, 'Visible', 'off')
    enableControls(handles);

% --- Executes on button press in pushbutton_export.
function pushbutton_export_Callback(hObject, eventdata, handles)

    disableControls(handles);
    print(handles.f1,'tank_Vzu1_gui.pdf', '-dpdf')
    print(handles.f2,'tank_Vzu2_gui.pdf', '-dpdf')

    append_pdfs('tank_gui.pdf', 'tank_Vzu1_gui.pdf', 'tank_Vzu2_gui.pdf')
    
    msgbox('exported to tank_gui.pdf');
    
    enableControls(handles);

% --- Executes on button press in pushbutton_config1.
function pushbutton_config1_Callback(hObject, eventdata, handles)

    disableControls(handles);

    setConfig1(handles);
    
    enableControls(handles);

% --- Executes on button press in pushbutton_config2.
function pushbutton_config2_Callback(hObject, eventdata, handles)

    disableControls(handles);

    setConfig2(handles);
    
    enableControls(handles);

% --- Executes on button press in pushbutton_config3.
function pushbutton_config3_Callback(hObject, eventdata, handles)

    disableControls(handles);

    setConfig3(handles);
    
    enableControls(handles);

% --- Executes on button press in checkbox_grid.
function checkbox_grid_Callback(hObject, eventdata, handles)

grid(handles.plotter_fullstand);
grid(handles.plotter_temp);


% --- Executes on button press in pushbutton_reset.
function pushbutton_reset_Callback(hObject, eventdata, handles)

    global cellsSize;
    
    cellsSize = 0;

    cla(handles.plotter_fullstand);
    cla(handles.plotter_temp);
    
    legend(handles.plotter_fullstand, []);
    legend(handles.plotter_temp, []);
    
    set(handles.pushbutton_export, 'Enable', 'off');
    

% --- Executes on button press in checkbox_zoom.
function checkbox_zoom_Callback(hObject, eventdata, handles)

    if get(handles.checkbox_zoom, 'Value')
        zoom(handles.plotter_temp, 'on');
        datacursormode(gcf, 'off');
    else
        zoom(handles.plotter_temp, 'off');
        datacursormode(gcf, 'on');
    end



function edit_schrittweite_Callback(hObject, eventdata, handles)
% hObject    handle to edit_schrittweite (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_schrittweite as text
%        str2double(get(hObject,'String')) returns contents of edit_schrittweite as a double


% --- Executes during object creation, after setting all properties.
function edit_schrittweite_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_schrittweite (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider_schrittweite_Callback(hObject, eventdata, handles)
% hObject    handle to slider_schrittweite (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider_schrittweite_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_schrittweite (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit_simTime_Callback(hObject, eventdata, handles)
% hObject    handle to edit_simTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_simTime as text
%        str2double(get(hObject,'String')) returns contents of edit_simTime as a double


% --- Executes during object creation, after setting all properties.
function edit_simTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_simTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider_simTime_Callback(hObject, eventdata, handles)
% hObject    handle to slider_simTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider_simTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_simTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
