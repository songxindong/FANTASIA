function varargout = CtrlPointGreyCams(varargin)
% This is the control part of pointgrey cameras
 
%% For Standarized SubFunction Callback Control
if nargin==0                % INITIATION
    InitializeTASKS
elseif ischar(varargin{1})  % INVOKE NAMED SUBFUNCTION OR CALLBACK?
    try
        if (nargout)                        
            [varargout{1:nargout}] = feval(varargin{:});
                            % FEVAL switchyard, w/ output
        else
            feval(varargin{:}); 
                            % FEVAL switchyard, w/o output  
        end
                            % feval('GUI_xxx', varargin);
                            % feval(@GUI_xxx, varargin); 
    catch MException
        rethrow(MException);
    end
end
   
function InitializeTASKS

%% INITIALIZATION
 


%% CALLBACK FUNCTIONS
function msg = InitializeCallbacks(N)
global Xin
% set(Xin.UI.FigPGC(N).hFig,	'CloseRequestFcn',	[mfilename, '(@Cam_CleanUp,', num2str(N),')']);
set(Xin.UI.FigPGC(N).CP.hSys_CamShutter_PotenSlider,	'Callback',	[mfilename, '(''Cam_Shutter'')']);
set(Xin.UI.FigPGC(N).CP.hSys_CamShutter_PotenEdit,    	'Callback',	[mfilename, '(''Cam_Shutter'')']);
set(Xin.UI.FigPGC(N).CP.hSys_CamGain_PotenSlider,     	'Callback',	[mfilename, '(''Cam_Gain'')']);
set(Xin.UI.FigPGC(N).CP.hSys_CamGain_PotenEdit,      	'Callback',	[mfilename, '(''Cam_Gain'')']);
set(Xin.UI.FigPGC(N).CP.hExp_RefImage_Momentary,        'Callback',	[mfilename, '(''Ref_Image'')']);
set(Xin.UI.FigPGC(N).CP.hMon_PreviewSwitch_Rocker,	'SelectionChangeFcn',	[mfilename, '(''Preview_Switch'')']);
set(Xin.UI.FigPGC(N).CP.hMon_DispGain_PotenSlider,      'Callback',	[mfilename, '(''Disp_Gain'')']);
set(Xin.UI.FigPGC(N).CP.hMon_DispGain_PotenEdit,        'Callback',	[mfilename, '(''Disp_Gain'')']);
msg = 'done';

function Cam_Shutter(varargin)
    global Xin
	%% get the numbers
    if nargin==0
        % called by GUI: 
        N =                 get(gcbo, 'UserData');
      	uictrlstyle =       get(gcbo, 'Style');
        switch uictrlstyle
            case 'slider';  Shutter = get(gcbo, 'value');
            case 'edit';    Shutter = str2double(get(gcbo,'string'));	
            otherwise;      errordlg('What''s the hell?');
                            return;
        end
    else
        % called by general update: e.g. Cam_Shutter(20.00)
        N =                 varargin(1); 
        Shutter =           varargin(2); 
    end
    %% check the constraints
    pSrc = propinfo(Xin.HW.PointGrey.Cam(N).hSrc);
    if isnan(Shutter) || Shutter<pSrc.Shutter.ConstraintValue(1) || Shutter>pSrc.Shutter.ConstraintValue(2)
        Shutter =                           Xin.D.Sys.PointGreyCam(N).Shutter;
        warndlg('Input Shutter value is out of the device constraits')        
    else
        Xin.D.Sys.PointGreyCam(N).Shutter =	Shutter;
    end
    Xin.HW.PointGrey.Cam(N).hSrc.Shutter = 	Xin.D.Sys.PointGreyCam(N).Shutter; 
    s = sprintf('%05.2f',Shutter);
    set(Xin.UI.FigPGC(N).CP.hSys_CamShutter_PotenSlider,	'value',	Shutter);    
    set(Xin.UI.FigPGC(N).CP.hSys_CamShutter_PotenEdit,      'string',   s);
	%% LOG MSG
    msg = [datestr(now) '\tCam_Shutter\tSetup the PointGrey Camera #' ...
        num2str(N), '''s Shutter as: ' s ' (ms)\r\n'];
    try
        fprintf(Xin.D.Sys.hLog, msg);
    catch
        disp(msg);
    end
    
function Cam_Gain(varargin)
    global Xin
	%% get the numbers
    if nargin==0
        % called by GUI: 
        N =                 get(gcbo, 'UserData');
      	uictrlstyle =       get(gcbo, 'Style');
        switch uictrlstyle
            case 'slider';  Gain =  get(gcbo, 'value');
            case 'edit';    Gain =  str2double(get(gcbo,'string'));	
            otherwise;      errordlg('What''s the hell?');
                            return;
        end
    else
        % called by general update: e.g. Cam_Gain(18.00)
        N =                 varargin(1); 
        Gain =              varargin{2}; 
    end
    
    %% check the constraints
    pSrc = propinfo(Xin.HW.PointGrey.Cam(N).hSrc);
    if isnan(Gain) || Gain<pSrc.Gain.ConstraintValue(1) || Gain>pSrc.Gain.ConstraintValue(2)
        Gain =                              Xin.D.Sys.PointGreyCam(N).Gain;
        warndlg('Input Gain value is out of the device constraits')        
    else
        Xin.D.Sys.PointGreyCam(N).Gain =    Gain;
    end 
    Xin.HW.PointGrey.Cam(N).hSrc.Gain = 	Xin.D.Sys.PointGreyCam(N).Gain; 
    s = sprintf('%05.2f', Gain);
    set(Xin.UI.FigPGC(N).CP.hSys_CamGain_PotenSlider,	'value',	Gain);    
    set(Xin.UI.FigPGC(N).CP.hSys_CamGain_PotenEdit, 	'string',   s);
  	%% LOG MSG
    msg = [datestr(now) '\tCam_Gain\tSetup the PointGrey Camera #' ...
        num2str(N), '''s gain as: ' s ' (dB)\r\n'];
    try
        fprintf(Xin.D.Sys.hLog, msg);
    catch
        disp(msg);
    end

function Preview_Switch(varargin)
    global Xin
  	%% where the call is from      
    if nargin==0
        % called by GUI:            Camera_Preview
        N =         get(get(get(gcbo, 'SelectedObject'), 'Parent'), 'UserData');
        val =       get(get(gcbo,'SelectedObject'),'string');
        [~, val] =  strtok(val, ' ');
        val =       val(2:end);
    else
        % called by general update: Prreview_Switch('ON') or Prreview_Switch('OFF')
        N =         varargin(1); 
        val =       varargin(2); 
    end

	hc =   get(Xin.UI.FigPGC(N).CP.hMon_PreviewSwitch_Rocker, 'Children');
    for j = 1:3
        switch j
            case 1
            case 2  % OFF 
                    if  strcmp(val, 'OFF')
                        set(hc(j),	'backgroundcolor', Xin.UI.C.SelectB);
                        stoppreview(Xin.HW.PointGrey.Cam(N).hVid);  
                        Xin.D.Sys.PointGreyCam(N).DispImg = ...
                            uint8(0*Xin.D.Sys.PointGreyCam(N).DispImg);
                    	set(Xin.UI.FigPGC(N).hImage, 'CData',...
                            Xin.D.Sys.PointGreyCam(N).DispImg);
                    else                
                        set(hc(j),	'backgroundcolor', Xin.UI.C.TextBG);
                    end
            case 3  % ON
                    if  strcmp(val, 'ON')
                        set(hc(j),	'backgroundcolor', Xin.UI.C.SelectB);
                        setappdata(Xin.UI.FigPGC(N).hImageHide,...
                            'UpdatePreviewWindowFcn',...
                            Xin.D.Sys.PointGreyCam(N).UpdatePreviewWindowFcn);
                        preview(Xin.HW.PointGrey.Cam(N).hVid,...
                            Xin.UI.FigPGC(N).hImageHide);  
                    else                
                        set(hc(j),	'backgroundcolor', Xin.UI.C.TextBG);
                    end
            otherwise
        end
    end
    %% LOG MSG
    msg = [datestr(now) '\tMon_PreviewSwitch\PointGrey Camera #' ...
        num2str(N), ' switched to ', val, '\r\n'];
    try
        fprintf(Xin.D.Sys.hLog, msg);
    catch
        disp(msg);
    end
    
function Ref_Image(varargin)
    global Xin TP
	%% Get the Inputs
    if nargin==0
        % called by GUI: 
        N =                 get(gcbo, 'UserData');
    else
        % called by general update:	e.g. Ref_Image(2)
        N =                 varargin(1); 
    end
    %% Questdlg the information
  	imageinfo = {...
        ['System Cam Shutter:',         sprintf('%5.2f',Xin.D.Sys.PointGreyCam(N).Shutter),  ' (ms); '],...
        ['System Cam Gain:',            sprintf('%5.2f',Xin.D.Sys.PointGreyCam(N).Gain),     ' (dB); ']
        };
    promptinfo = [...
        imageinfo,...
        {''},...
        {'Are these settings correct?'}];
    choice = questdlg(promptinfo,...
        'Imaging conditions:',...
        'No, Cancel and Reset', 'Yes, Take an Image',...
        'No, Cancel and Reset');
   	switch choice
        case 'No, Cancel and Reset';    return;
        case 'Yes, Take an Image'
    end
    %% Camera Trigger Settings   
    Trigger_Mode(N, 'SoftwareGrab');
	Xin.HW.PointGrey.PointGreyCam(N).hVid.TriggerRepeat = 1;
    %% Capturing Images
	start(          Xin.HW.PointGrey.Cam(N).hVid);
    if Xin.HW.PointGrey.Cam(N).hVid.TriggerRepeat ~= 0
        wait(Xin.HW.PointGrey.Cam(N).hVid,   Xin.HW.PointGrey.Cam(N).hVid.TriggerRepeat);  
    end
    [idata,~,~] = getdata(Xin.HW.PointGrey.Cam(N).hVid,...
        Xin.HW.PointGrey.Cam(N).hVid.TriggerRepeat+1,'uint16', 'numeric');
	%% ROTATE
%     try
        Xin.D.Exp.SurfaceImagePGC{N} =	uint16( rot90(squeeze(sum(idata,4)), ...
                                        	(360-Xin.D.Sys.PointGreyCam(N).PreviewRot)/90) );
%     catch
%         Xin.D.Exp.SurfaceImagePGC(N) =	uint16(squeeze(sum(idata,4)));
%         disp('Preview Rotation Angle Not Support');
%     end
    %% Save the Image
    datestrfull =	datestr(now, 30);
    dataname =      [datestrfull(3:end)];    
    figure;
    imshow(Xin.D.Exp.SurfaceImagePGC{N});
    imagedescription = strjoin(imageinfo);
    imwrite(Xin.D.Exp.SurfaceImagePGC{N}, [TP.D.Sys.PC.Data_Dir, dataname, '.tif'],...
        'Compression',          'deflate',...
        'Description',          imagedescription);
    %% LOG MSG
    msg = [datestr(now) '\tExp_SurRef\tExperiment surface picture took for the experiment\r\n'];
    try
        fprintf(Xin.D.Sys.hLog, msg);
    catch
        disp(msg);
    end
    
function Disp_Gain(varargin)
    global Xin
    %% get the numbers
    if nargin==0
        % called by GUI: 
        N =                 get(gcbo, 'UserData');
      	uictrlstyle =       get(gcbo, 'Style');
        switch uictrlstyle
            case 'slider';  DispGainBit = get(gcbo, 'value');
                            DispGainNum = 2^DispGainBit;
            case 'edit';    DispGainNum = str2double(get(gcbo,'string'));	
                            DispGainBit = log2(DispGainNum);
            otherwise;      errordlg('What''s the hell?');
                            return;
        end
    else
        % called by general update: e.g. Disp_Gain(16)
        N =                 varargin{1};
        DispGainNum =       varargin{2};
        DispGainBit =       log2(DispGainNum); 
    end
    %% Check whether the number is valid to update  
    if  ismember(DispGainBit, Xin.D.Sys.PointGreyCam(N).DispGainBitRange)
        Xin.D.Sys.PointGreyCam(N).DispGainBit =	DispGainBit;
        Xin.D.Sys.PointGreyCam(N).DispGainNum =	DispGainNum;
    end
    s = sprintf(' %d', Xin.D.Sys.PointGreyCam(N).DispGainNum);
    set(Xin.UI.FigPGC(N).CP.hMon_DispGain_PotenSlider,	'value',	Xin.D.Sys.PointGreyCam(N).DispGainBit);    
    set(Xin.UI.FigPGC(N).CP.hMon_DispGain_PotenEdit,	'string',   s);   
    %% LOG MSG
    msg = [datestr(now) '\tDisp_Gain\tSetup the PointGrey Camera #' ...
        num2str(N), '''s DISP gain as: ' s '\r\n'];
    try
        fprintf(Xin.D.Sys.hLog, msg);
    catch
        disp(msg);
    end
    
function Trigger_Mode(N, Mode)
    global Xin    
    %% Search & allocate the mode
    for i = 1: length(Xin.D.Sys.PointGreyCam(N).TriggerMode)
        if strcmp(Xin.D.Sys.PointGreyCam(N).TriggerMode(i).Name, Mode)
            ic = i;
        end
    end     
    Xin.D.Sys.PointGreyCam(N).TriggerName =      Xin.D.Sys.PointGreyCam(N).TriggerMode(ic).Name;  
    Xin.D.Sys.PointGreyCam(N).TriggerType =      Xin.D.Sys.PointGreyCam(N).TriggerMode(ic).TriggerType;         
    Xin.D.Sys.PointGreyCam(N).TriggerCondition = Xin.D.Sys.PointGreyCam(N).TriggerMode(ic).TriggerCondition; 
    Xin.D.Sys.PointGreyCam(N).TriggerSource =    Xin.D.Sys.PointGreyCam(N).TriggerMode(ic).TriggerSource;
    %% Update Trigger GUI
%     a = get(Xin.UI.FigPGC(N).hSes_CamTrigger_Rocker, 'Children');
%   	set(Xin.UI.H.hSes_CamTrigger_Rocker, 'SelectedObject', a(ic));
%     for j = 1:3
%         if j == ic
%             set(a(j),	'backgroundcolor', Xin.UI.C.SelectB); 
%         else                
%             set(a(j),	'backgroundcolor', Xin.UI.C.TextBG);
%         end
%     end
    %% Set the VideoInput object
    triggerconfig(Xin.HW.PointGrey.Cam(N).hVid, ...
        Xin.D.Sys.PointGreyCam(N).TriggerType,...
        Xin.D.Sys.PointGreyCam(N).TriggerCondition,...
        Xin.D.Sys.PointGreyCam(N).TriggerSource);     
    %% LOG MSG
    msg = [datestr(now) '\tTrigger_Mode\tTrigger mode selected as: "' ...
         Xin.D.Sys.PointGreyCam(N).TriggerName '"\r\n'];
    try
        fprintf(Xin.D.Sys.hLog, msg);
    catch
        disp(msg);
    end