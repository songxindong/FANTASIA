function varargout = FANTASIA(varargin)

%% For Standarized SubFunction Callback Control
if nargin==0                % INITIATION
    InitializeTASKS
elseif ischar(varargin{1})  % INVOKE NAMED SUBFUNCTION OR CALLBACK
    try
        if (nargout)                        
            [varargout{1:nargout}] = feval(varargin{:});
                            % FEVAL switchyard, w/ output
        else
            feval(varargin{:}); 
                            % FEVAL switchyard, w/o output  
        end
    catch MException
        rethrow(MException);
    end
end

function InitializeTASKS

%% CHECK WHETHER LAST PROGRAM IS STILL RUNNING
if CheckRunning
    return;
end

%% CLEAN AND RECREATE THE WORKSPACE
clc;
clear global;
global TP;

%% INITIALIZATION
TP.D.Sys.Name =         mfilename;          % Grab the current script's name
SetupD;                                     % Initiate parameters
SetupFigure;                    set(TP.UI.H0.hFigTP,    'Visible',  'off');	
SetupThorlabsPowerMeter;
SetupThorlabsMotor;
SetupNIDAQ;
SetupPointGreyCams;
%     TP.D.Mon.Power.CalibFlag = 1;
    GUI_Rocker('hSes_ScanScheme_Rocker', 'Search');  
  	GUI_PresetCfg(13);
                                set(TP.UI.H0.hFigTP,    'Visible',  'on');
    
%% SETUP GUI CALLBACKS
% Sys Registrations %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(TP.UI.H.hSys_PowerCalib_Momentary,      'callback',             'SetupPowerCalibration');

% Mky / Exp Registrations %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Parameter Input
set(TP.UI.H.hMky_ID_Edit,                   'callback',             [TP.D.Sys.Name,'(''GUI_MkyExp'')']);
set(TP.UI.H.hExp_Mech_EstX_Edit,         	'callback',             [TP.D.Sys.Name,'(''GUI_MkyExp'')']);
set(TP.UI.H.hExp_Mech_EstY_Edit,         	'callback',             [TP.D.Sys.Name,'(''GUI_MkyExp'')']);
set(TP.UI.H.hExp_Mech_Z0_SM1Z_Edit,       	'callback',             [TP.D.Sys.Name,'(''GUI_MkyExp'')']);
set(TP.UI.H.hExp_Mech_Zs_SM1Z_Edit,        	'callback',             [TP.D.Sys.Name,'(''GUI_MkyExp'')']);
set(TP.UI.H.hMky_Side_Edit,                 'callback',             [TP.D.Sys.Name,'(''GUI_MkyExp'')']);
set(TP.UI.H.hExp_AngleArm_Edit,             'callback',             [TP.D.Sys.Name,'(''GUI_MkyExp'')']);
    % Wide Field
set(TP.UI.H.hExp_WF1_Momentary,            	'callback',             [TP.D.Sys.Name,'(''SetupFigurePointGrey'')']);
set(TP.UI.H.hExp_WF2_Momentary,            	'callback',             [TP.D.Sys.Name,'(''SetupFigurePointGrey'')']);

% Exp.BCD Scanning Pattern %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Preset Modes
for i =1:length(TP.D.Sys.Scan.PresetGroup)
set(TP.UI.H.hSys_Scan_PresetCfg_Toggle{i},  'SelectionChangeFcn',   [TP.D.Sys.Name,'(''GUI_PresetCfg'')']);
end
    % Scan Pattern
set(TP.UI.H.hSys_AOD_FreqBW_Edit,               'callback',             [TP.D.Sys.Name,'(''GUI_ScanParameters'')']);
set(TP.UI.H.hSys_AOD_FreqCF_Edit,               'callback',             [TP.D.Sys.Name,'(''GUI_ScanParameters'')']);
set(TP.UI.H.hExp_BCD_Scan_Mode_Rocker,          'SelectionChangeFcn',   [TP.D.Sys.Name,'(''GUI_ScanParameters'')']);
set(TP.UI.H.hExp_BCD_Image_NumSmplPerPixl_Edit,	'callback',             [TP.D.Sys.Name,'(''GUI_ScanParameters'')']);
set(TP.UI.H.hExp_BCD_Scan_NumPixlPerAxis_Edit,	'callback',             [TP.D.Sys.Name,'(''GUI_ScanParameters'')']);
set(TP.UI.H.hExp_BCD_Scan_NumLayrPerVlme_Edit,	'callback',             [TP.D.Sys.Name,'(''GUI_ScanParameters'')']);
set(TP.UI.H.hExp_BCD_Scan_LayrSpacingInZ_Edit, 	'callback',             [TP.D.Sys.Name,'(''GUI_ScanParameters'')']);
set(TP.UI.H.hExp_BCD_Image_NumUpdtPerVlme_Edit,	'callback',             [TP.D.Sys.Name,'(''GUI_ScanParameters'')']);
set(TP.UI.H.hExp_BCD_Image_NumVlmePerUpdt_Edit,	'callback',             [TP.D.Sys.Name,'(''GUI_ScanParameters'')']);
set(TP.UI.H.hExp_BCD_ImageEnable_Rocker,        'SelectionChangeFcn',   [TP.D.Sys.Name,'(''GUI_Rocker'')']);
set(TP.UI.H.hExp_BCD_Commit_Rocker,             'SelectionChangeFcn', 	[TP.D.Sys.Name,'(''GUI_Rocker'')']);     

% Session Control %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(TP.UI.H.hSes_ScanScheme_Rocker,      	'SelectionChangeFcn',  	[TP.D.Sys.Name, '(''GUI_Rocker'')']);
set(TP.UI.H.hSes_CycleNumTotal_Edit,        'Callback',             [TP.D.Sys.Name, '(''GUI_Edit'')']);
set(TP.UI.H.hSes_AddAtts_Edit,              'Callback',             [TP.D.Sys.Name, '(''GUI_Edit'')']);
set(TP.UI.H.hSes_TrlOrder_Rocker,           'SelectionChangeFcn',   [TP.D.Sys.Name, '(''GUI_Rocker'')']);
set(TP.UI.H.hSes_Load_Momentary,            'callback',             [TP.D.Sys.Name, '(''Ses_Load'')']);
set(TP.UI.H.hSes_StartStop_Momentary,       'callback',             [TP.D.Sys.Name, '(''Ses_StartStop'')']);

% Trial Control %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% House Keeping Tasks %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % AO 6115 control
set(TP.UI.H.hMon_PMT_CtrlGainValue_PotenSlider,     'callback',     [TP.D.Sys.Name,'(''GUI_AO_6115'')']);
set(TP.UI.H.hMon_PMT_CtrlGainValue_PotenEdit,       'callback',     [TP.D.Sys.Name,'(''GUI_AO_6115'')']);
set(TP.UI.H.hMon_Power_AOD_CtrlAmpValue_PotenSlider,'callback',     [TP.D.Sys.Name,'(''GUI_AO_6115'')']);
set(TP.UI.H.hMon_Power_AOD_CtrlAmpValue_PotenEdit,  'callback',    	[TP.D.Sys.Name,'(''GUI_AO_6115'')']);
    % DO 6115 control
set(TP.UI.H.hMon_PMT_PMTctrl_Rocker,        'SelectionChangeFcn',	[TP.D.Sys.Name,'(''GUI_DO_6115'')']);
set(TP.UI.H.hMon_PMT_FANctrl_Toggle,        'SelectionChangeFcn',   [TP.D.Sys.Name,'(''GUI_DO_6115'')']);
set(TP.UI.H.hMon_PMT_PELctrl_Toggle,        'SelectionChangeFcn',   [TP.D.Sys.Name,'(''GUI_DO_6115'')']);
    % Display State
set(TP.UI.H.hMon_Image_DisplayMode_Rocker,  'SelectionChangeFcn',   [TP.D.Sys.Name,'(''GUI_Rocker'')']);
    % Power
set(TP.UI.H.hMon_Power_HWP_CtrlAglValue_PotenEdit,  'callback',     [TP.D.Sys.Name,'(''GUI_PowerHWP'')']);
set(TP.UI.H.hMon_Power_HWP_CtrlAglValue_PotenSlider,'callback',     [TP.D.Sys.Name,'(''GUI_PowerHWP'')']);
set(TP.UI.H.hMon_Power_PmaxCtxAllowed_Edit,         'callback',     [TP.D.Sys.Name,'(''GUI_Edit'')']);     
    % CLEANUP
set(TP.UI.H0.hFigTP,                        'CloseRequestFcn',      [TP.D.Sys.Name,'(''GUI_CleanUp'')']);

%% CALLBACK FUNCTIONS
function flag = CheckRunning
    global TP
    if ~isempty(TP)
        errordlg('Last Program is still running');
        flag = 1;
    else
        flag = 0;
    end
            
function GUI_MkyExp(varargin)
    global TP 	
        % notes by 10/24/2014
        % need to prepare Mky-Exp DATABASE etc

    %% Where the Call is from   
    if nargin ==0
        % called by GUI:            GUI_MkyExp
     	switch get(gcbo, 'tag')
            case 'hMky_Side_Edit';       	t = 0;
            case 'hExp_AngleArm_Edit';      t = 0;
            case 'hMky_ID_Edit';            t = 1;
            case 'hExp_Mech_EstX_Edit';     t = 1;
            case 'hExp_Mech_EstY_Edit';     t = 1;
            case 'hExp_Mech_Z0_SM1Z_Edit';  t = 2;
            case 'hExp_Mech_Zs_SM1Z_Edit';  t = 2;
            otherwise
                errordlg ('What button did you press?');
        end
        switch t
            case 0  % Need to update Angel Panel
                TP.D.Mky.Side =         get(TP.UI.H.hMky_Side_Edit,'String');
                TP.D.Exp.AngleArm = 	str2double(get(TP.UI.H.hExp_AngleArm_Edit,'String'));
                SetupDispAngle(TP.UI.H0.hAxesAngle);
            case 1  % Just update numbers
                TP.D.Mky.ID =           get(TP.UI.H.hMky_ID_Edit,'String');
                TP.D.Exp.Mech.EstX =    str2double(get(TP.UI.H.hExp_Mech_EstX_Edit,'String'));
                TP.D.Exp.Mech.EstY =    str2double(get(TP.UI.H.hExp_Mech_EstX_Edit,'String'));
            case 2  % Update Z and Estimated Z                
                TP.D.Exp.Mech.Z0_SM1Z = str2double(get(TP.UI.H.hExp_Mech_Z0_SM1Z_Edit,'String'));
                TP.D.Exp.Mech.Zs_SM1Z = str2double(get(TP.UI.H.hExp_Mech_Zs_SM1Z_Edit,'String'));
                TP.D.Exp.Mech.EstZ = TP.D.Exp.Mech.Zs_SM1Z - TP.D.Exp.Mech.Z0_SM1Z;
                set(TP.UI.H.hExp_Mech_EstZ_Edit, 'string', num2str(TP.D.Exp.Mech.EstZ) );
        end
    else
        % called by general update: GUI_MkyExp('Right', 30) 
        %                       or  GUI_MkyExp('Left', 0)   style
        % TP.D.Image.ArmSide =     varargin{1};
        % TP.D.Image.ArmAngle =    varargin{2};
    end
        
	%% MSG LOG
    msg = [datestr(now, 'yy/mm/dd HH:MM:SS.FFF') '\tGUI_MkyExp\tUpdated','\r\n'];
    updateMsg(TP.D.Exp.hLog, msg);  
    
function GUI_Edit(varargin)
    global TP
    %% Where the Call is from   
    if nargin == 0      % from GUI 
        tag =   get(gcbo,   'tag');
        s =     get(gcbo,   'string');
           
    else                % from Program
        tag =   varargin{1};
        s =     varargin{2};
    end
    %% Update D and GUI
    switch tag
        case 'hSes_CycleNumTotal_Edit'
            try 
                t = round(str2double(s));
                TP.D.Ses.Load.CycleNumTotal = t;
            catch
                errordlg('Cycle Number Total input is not valid');
                return
            end
            %% Setup Session Loading
            SetupSesLoad('TP', 'CycleNumTotal'); 
        case 'hSes_AddAtts_Edit'
            try
                eval(['TP.D.Ses.Load.AddAtts = [', s, '];']);
                TP.D.Ses.Load.AddAttString = s;
            catch
                errordlg('Additonal attenuations input is not valid');
                return
            end            
            %% Setup Session Loading
            SetupSesLoad('TP', 'AddAtts');     
        case 'hMon_Power_PmaxCtxAllowed_Edit'
            try 
                Pmax = str2double(s);
                TP.D.Mon.Power.PmaxCtxAllowed = min(round(Pmax), 300);
                set(TP.UI.H.hMon_Power_PmaxCtxAllowed_Edit,...
                    'string',   sprintf('%5.1f',   TP.D.Mon.Power.PmaxCtxAllowed));               
            catch
                errordlg('Power Max @ Cortex Allowed not set right');
                return
            end
        otherwise
    end
	%% MSG LOG
    msg = [datestr(now, 'yy/mm/dd HH:MM:SS.FFF') '\tGUI_Edit\t' tag ' updated to ' s '\r\n'];
    updateMsg(TP.D.Exp.hLog, msg);

function GUI_Rocker(varargin)
    global TP
  	%% where the call is from      
    if nargin==0
        % called by GUI:            GUI_Rocker
        label =     get(gcbo,'Tag'); 
        val =       get(get(gcbo,'SelectedObject'),'string');
    else
        % called by general update: GUI_Rocker('hMky_Side_Rocker', 'LEFT')
        label =     varargin{1};
        val =       varargin{2};
    end   
    %% Update GUI
    eval(['h = TP.UI.H.', label ';'])
    hc = get(h,     'Children');
    for j = 1:3
        if strcmp( get(hc(j), 'string'), val )
            set(hc(j),	'backgroundcolor', TP.UI.C.SelectB);
            set(h,      'SelectedObject',  hc(j));
            k = j;  % for later reference
        else                
            set(hc(j),	'backgroundcolor', TP.UI.C.TextBG);
        end
    end
    %% Update D & Log
    switch label
        case 'hMky_Side_Rocker'
            TP.D.Mky.Side = val;
            msg = [datestr(now, 'yy/mm/dd HH:MM:SS.FFF') '\t', label, '\tSetup the Monkey Side as: '...
                TP.D.Mky.Side '\r\n'];
        case 'hExp_BCD_ImageEnable_Rocker'
            switch val
                case 'ON'
                    TP.D.Exp.BCD.ImageEnable =  1;
                    set(TP.UI.H.hSes_Load_Momentary, 'Enable', 'on');
                case 'OFF'
                    TP.D.Exp.BCD.ImageEnable =  0;
                    set(TP.UI.H.hSes_Load_Momentary, 'Enable', 'off');
                otherwise
            end
            msg = [datestr(now, 'yy/mm/dd HH:MM:SS.FFF') '\t', label, '\tExp BCD ImageEnable set as: '...
                val '\r\n'];            
        case 'hExp_BCD_Commit_Rocker'
            hc = get(TP.UI.H.hSes_ScanScheme_Rocker,	'Children');
            switch val
                case 'Commit'
                    TP.D.Exp.BCD.Committed =	1;
                    BCD_Commit;
                    set(hc(1),  'Enable',   'on');
                    set(hc(2),  'Enable',   'on');
                    set(hc(3),  'Enable',   'on');
                case 'Uncommit'
                    TP.D.Exp.BCD.Committed =	0;
                    set(hc(1),  'Enable',   'inactive');
                    set(hc(2),  'Enable',   'inactive');
                    set(hc(3),  'Enable',   'inactive');
                otherwise
            end
            GUI_Rocker('hSes_ScanScheme_Rocker', 'Search');
            msg = [datestr(now, 'yy/mm/dd HH:MM:SS.FFF') '\t', label, '\tExp BCD Commit set as: '...
                val '\r\n'];               
        case 'hSes_TrlOrder_Rocker'
            TP.D.Ses.Load.TrlOrder = val;
            msg = [datestr(now, 'yy/mm/dd HH:MM:SS.FFF') '\t', label, '\tSession trial order selected as: '...
                TP.D.Ses.Load.TrlOrder '\r\n']; 
            SetupSesLoad('TP', 'TrlOrder');
        case 'hSes_ScanScheme_Rocker'
                    TP.D.Ses.ScanScheme =       val;
            switch val
                case 'Search'
                    TP.D.Ses.ScanTrigType =         'internal';
                    TP.D.Ses.Load.CycleNumTotal = 	1;
                    TP.D.Ses.Load.AddAtts =         0;
                    TP.D.Ses.Load.AddAttString = 	'0';
                    set(TP.UI.H.hSes_Load_Momentary,'enable',	'inactive');
                    if TP.D.Exp.BCD.ImageEnable
                        Ses_Load([pwd, '\=SoundVirtual_ScanScheme_Search_ImageEnable_ON.wav']);
                    else
                        Ses_Load([pwd, '\=SoundVirtual_ScanScheme_Search_ImageEnable_OFF.wav']);
                    end                      
                case 'Record'
                    TP.D.Ses.ScanTrigType =         'internal';
                    TP.D.Ses.Load.CycleNumTotal = 	2;
                    TP.D.Ses.Load.AddAtts =         [0 10];
                    TP.D.Ses.Load.AddAttString = 	'[0 10]';
                    set(TP.UI.H.hSes_Load_Momentary,'enable',	'on');
                        Ses_Load([pwd, '\=SoundVirtual_ScanScheme_Record.wav']);
                case 'XBlaster'
                    TP.D.Ses.ScanTrigType =         'external'; 
                    TP.D.Ses.Load.CycleNumTotal = 	Inf;
                    TP.D.Ses.Load.AddAtts =         0;
                    TP.D.Ses.Load.AddAttString = 	'0';
                    set(TP.UI.H.hSes_Load_Momentary,'enable',	'inactive');                    
                        Ses_Load([pwd, '\=SoundVirtual_ScanScheme_XBlaster.wav']);
                otherwise
            end
            NIDAQ_TrigConnection;
            msg = [datestr(now, 'yy/mm/dd HH:MM:SS.FFF') '\t', label, '\tSesScanScheme is selected as: '...
                TP.D.Ses.ScanScheme, ''' and Start Trigger as ''', TP.D.Ses.ScanTrigType ,'''\r\n'];
        case 'hTrl_StartTrigStop_Rocker'
            % just update the GUI            
            msg = [datestr(now, 'yy/mm/dd HH:MM:SS.FFF') '\t', label, '\tTrl_StartTrigStop is selected as: '...
                val ,'''\r\n'];
        case 'hMon_Image_DisplayMode_Rocker'
            switch val
                case 'Absolute'
                    TP.D.Mon.Image.DisplayMode =    val;
                    TP.D.Mon.Image.DisplayModeNum = 1;
                case 'Relative'
                    TP.D.Mon.Image.DisplayMode =    val;
                    TP.D.Mon.Image.DisplayModeNum = 2;                    
                otherwise
            end
            msg = [datestr(now, 'yy/mm/dd HH:MM:SS.FFF') '\t', label, '\tMon Image Display Mode selected as ''',...
                TP.D.Mon.Image.DisplayMode, '''\r\n'];
        otherwise
            errordlg('Rocker tag unrecognizable!');
    end
    updateMsg(TP.D.Exp.hLog, msg);
     
function GUI_PresetCfg(varargin)  
    global TP
    
    %% Where the call is from
    if nargin==0
        % called from GUI:      GUI_PresetCfg
        ScanCfg = get(get(gcbo,'SelectedObject'),'string');        
        ScanCfgNum = str2double(get(get(gcbo,'SelectedObject'),'tag'));
        ScanCfgGroup = ceil(ScanCfgNum/3);        
    else
        % called from program:  GUI_PresetCfg(x), x = 1~18; 
        ScanCfgNum = varargin{1};
        ScanCfgGroup = ceil(ScanCfgNum/3); 
        ScanCfg = TP.D.Sys.Scan.PresetCfg{ScanCfgNum}.name;
        % select the button, update GUI
        h = get(TP.UI.H.hSys_Scan_PresetCfg_Toggle{ScanCfgGroup}, 'Children');
        d = 3 - mod(ScanCfgNum-1,3);
        set(TP.UI.H.hSys_Scan_PresetCfg_Toggle{ScanCfgGroup}, 'SelectedObject', h(d));
    end
    %% exclusive choice update
    for i=1:length(TP.D.Sys.Scan.PresetGroup)
        % deselect other buttongroups
        if i ~= ScanCfgGroup
            set(TP.UI.H.hSys_Scan_PresetCfg_Toggle{i}, 'SelectedObject', []);
        end
        % label & delabel the button backgroundcolor
     	h = get(TP.UI.H.hSys_Scan_PresetCfg_Toggle{i}, 'children');
        for j = 1:length(h)
            if str2double(get(h(j), 'tag'))==ScanCfgNum
                set(h(j), 'backgroundcolor', TP.UI.C.SelectB);
            else
                set(h(j), 'backgroundcolor', TP.UI.C.TextBG);
            end
        end
    end
    %% Read the Preset ScanCfg out   
    Cfg = TP.D.Sys.Scan.PresetCfg{ScanCfgNum};
    %% Update further GUI elements 
    h1 = get(TP.UI.H.hExp_BCD_Scan_Mode_Rocker,             'children');
  	switch Cfg.ScanMode
        case '2D random';  	Cfg.ScanModeChild = 3;
        case '2D raster'; 	Cfg.ScanModeChild = 2;
        case '3D raster';  	Cfg.ScanModeChild = 1;
    end
    set(TP.UI.H.hExp_BCD_Scan_Mode_Rocker,              'SelectedObject',   h1(Cfg.ScanModeChild));
        for j = 1:length(h1)
            if j==Cfg.ScanModeChild;    set(h1(j),  'backgroundcolor',  TP.UI.C.SelectB);
            else                        set(h1(j),  'backgroundcolor',  TP.UI.C.TextBG);     end
        end
    set(TP.UI.H.hExp_BCD_Image_NumSmplPerPixl_Edit,   	'string',   num2str(Cfg.NumSmplPerPixl6115));
    set(TP.UI.H.hExp_BCD_Scan_NumPixlPerAxis_Edit,      'string',   num2str(Cfg.NumPixlPerAxis));
    set(TP.UI.H.hExp_BCD_Scan_NumLayrPerVlme_Edit,      'string',   num2str(Cfg.NumLayrPerVlme));
    set(TP.UI.H.hExp_BCD_Scan_LayrSpacingInZ_Edit,      'string',   num2str(Cfg.LayrSpacingInZ));
    set(TP.UI.H.hExp_BCD_Image_NumUpdtPerVlme_Edit,     'string',   num2str(Cfg.NumUpdtPerVlme));
    set(TP.UI.H.hExp_BCD_Image_NumVlmePerUpdt_Edit,     'string',   num2str(1/Cfg.NumUpdtPerVlme));    
    %% Update TP.D, and Generate ScanSeq
    TP.D.Exp.BCD.ScanGenFunc = Cfg.GenFunc;
    TP.D.Exp.BCD.ImageEnable = Cfg.ImagingEnable;
        if Cfg.ImagingEnable;   IE = 'ON';  else IE = 'OFF';    end
    GUI_Rocker('hExp_BCD_ImageEnable_Rocker', IE);
    GUI_ScanParameters(0);

    %% LOG MSG
    msg = [datestr(now, 'yy/mm/dd HH:MM:SS.FFF') '\tGUI_ScanCfg\tScanCfg ''',ScanCfg,''' is selected\r\n'];
    updateMsg(TP.D.Exp.hLog, msg);
       
function GUI_ScanParameters(varargin)
    global TP
    
    %% LOG MSG
    if nargin==0
        % called by button down: 	GUI_ScanParameters 
        tag = get(gcbo,'tag');
      	str = ['h = TP.UI.H.' tag ';'];
        eval(str);
        try
            tagmsg = get(h,'string');
        catch 
            tagmsg = get(get(h,'SelectedObject'),'string');
        end
        msg = [datestr(now, 'yy/mm/dd HH:MM:SS.FFF') '\tGUI_ScanParameters\t''',...
            tag ,''' is updated to ''',tagmsg,'''\r\n'];
        updateMsg(TP.D.Exp.hLog, msg);
    else
        % called by general update:	GUI_ScanParameters(0)
        % do not have log msg output to the file
        msg = '';
    end
    
    %% Update TP.D
    TP.D.Sys.AOD.FreqBW =   1e6 * str2double(get(TP.UI.H.hSys_AOD_FreqBW_Edit, 'string'));
    TP.D.Sys.AOD.FreqCF =   1e6 * str2double(get(TP.UI.H.hSys_AOD_FreqCF_Edit, 'string')); 
    % According to Scan.Mode, Change UI components availability, and TP.D
   	TP.D.Exp.BCD.ScanMode =    get(get(TP.UI.H.hExp_BCD_Scan_Mode_Rocker,'SelectedObject'),'string');         
    switch TP.D.Exp.BCD.ScanMode
        case '2D random'  
            TP.D.Exp.BCD.ScanModeNum = 1;
            TP.D.Exp.BCD.ImageNumSmplPerPixl = round(str2double(get(TP.UI.H.hExp_BCD_Image_NumSmplPerPixl_Edit, 'string'))/2)*2;
            set(TP.UI.H.hExp_BCD_Scan_NumLayrPerVlme_Edit,  'enable', 'inactive',   'Foregroundcolor', TP.UI.C.FG,	'String', '1');
            set(TP.UI.H.hExp_BCD_Scan_LayrSpacingInZ_Edit, 	'enable', 'inactive',	'Foregroundcolor', TP.UI.C.FG,	'String', 'NaN');
            set(TP.UI.H.hExp_BCD_Image_NumUpdtPerVlme_Edit, 'enable', 'on',       	'Foregroundcolor', TP.UI.C.SelectT);
            set(TP.UI.H.hExp_BCD_Image_NumVlmePerUpdt_Edit, 'enable', 'inactive',  	'Foregroundcolor', TP.UI.C.FG);
            TP.D.Exp.BCD.ImageNumUpdtPerVlme = round(str2double(get(TP.UI.H.hExp_BCD_Image_NumUpdtPerVlme_Edit, 'string')));
            TP.D.Exp.BCD.ImageNumVlmePerUpdt = 1/TP.D.Exp.BCD.ImageNumUpdtPerVlme;
        case '2D raster'
            TP.D.Exp.BCD.ScanModeNum = 2;
            TP.D.Exp.BCD.ImageNumSmplPerPixl = round(str2double(get(TP.UI.H.hExp_BCD_Image_NumSmplPerPixl_Edit, 'string'))/1)*1;
            set(TP.UI.H.hExp_BCD_Scan_NumLayrPerVlme_Edit,  'enable', 'inactive',   'Foregroundcolor', TP.UI.C.FG,  'String', '1');
            set(TP.UI.H.hExp_BCD_Scan_LayrSpacingInZ_Edit, 	'enable', 'inactive',	'Foregroundcolor', TP.UI.C.FG,	'String', 'NaN');
            set(TP.UI.H.hExp_BCD_Image_NumUpdtPerVlme_Edit,	'enable', 'inactive',   'Foregroundcolor', TP.UI.C.FG);
            set(TP.UI.H.hExp_BCD_Image_NumVlmePerUpdt_Edit,	'enable', 'on',         'Foregroundcolor', TP.UI.C.SelectT);
            TP.D.Exp.BCD.ImageNumVlmePerUpdt = round(str2double(get(TP.UI.H.hExp_BCD_Image_NumVlmePerUpdt_Edit, 'string')));
            TP.D.Exp.BCD.ImageNumUpdtPerVlme = 1/TP.D.Exp.BCD.ImageNumVlmePerUpdt;
      	case '3D raster'
            TP.D.Exp.BCD.ScanModeNum = 3;
         	TP.D.Exp.BCD.ImageNumSmplPerPixl = round(str2double(get(TP.UI.H.hExp_BCD_Image_NumSmplPerPixl_Edit, 'string'))/1)*1;
            set(TP.UI.H.hExp_BCD_Scan_NumLayrPerVlme_Edit,  'enable', 'on',         'Foregroundcolor', TP.UI.C.SelectT);
            set(TP.UI.H.hExp_BCD_Scan_LayrSpacingInZ_Edit,	'enable', 'on',         'Foregroundcolor', TP.UI.C.SelectT);
            set(TP.UI.H.hExp_BCD_Image_NumUpdtPerVlme_Edit,	'enable', 'inactive',   'Foregroundcolor', TP.UI.C.FG);
            set(TP.UI.H.hExp_BCD_Image_NumVlmePerUpdt_Edit, 'enable', 'inactive',  	'Foregroundcolor', TP.UI.C.FG);
            TP.D.Exp.BCD.ImageNumVlmePerUpdt = round(str2double(get(TP.UI.H.hExp_BCD_Image_NumVlmePerUpdt_Edit, 'string')));
            TP.D.Exp.BCD.ImageNumUpdtPerVlme = 1/TP.D.Exp.BCD.ImageNumVlmePerUpdt;
        otherwise
    end
    % Change Scan.Mode Button Color
    h = get(TP.UI.H.hExp_BCD_Scan_Mode_Rocker, 'children');
    for i = 1:3
        if i ==TP.D.Exp.BCD.ScanModeNum; 	set(h(4-i), 'backgroundcolor', TP.UI.C.SelectB);
        else                            set(h(4-i), 'backgroundcolor', TP.UI.C.TextBG);    end
    end
    % Update rounded TP.D
    TP.D.Exp.BCD.ScanNumSmplPerPixl =  TP.D.Exp.BCD.ImageNumSmplPerPixl * TP.D.Sys.NI.Task_DO_6536_SR / TP.D.Sys.NI.Task_AI_6115_SR;          
    TP.D.Exp.BCD.ScanNumPixlPerAxis =  round(str2double(get(TP.UI.H.hExp_BCD_Scan_NumPixlPerAxis_Edit, 'string')));
    TP.D.Exp.BCD.ScanNumLayrPerVlme =  round(str2double(get(TP.UI.H.hExp_BCD_Scan_NumLayrPerVlme_Edit, 'string'))/2)*2-1;  % must be odd number 2->1
    TP.D.Exp.BCD.ScanLayrSpacingInZ =  round(str2double(get(TP.UI.H.hExp_BCD_Scan_LayrSpacingInZ_Edit, 'string')));

    TP.D.Exp.BCD.ScanNumSmplPerVlme =  NaN;
    TP.D.Exp.BCD.ScanVolumeRate =      NaN;
    TP.D.Exp.BCD.ScanVolumeTime =      NaN;
    TP.D.Exp.BCD.ImageNumPixlPerUpdt = NaN;                                        
    TP.D.Exp.BCD.ImageNumSmplPerUpdt = NaN;
    TP.D.Exp.BCD.ImageUpdateRate =     NaN;
    TP.D.Exp.BCD.ImageUpdateTime =     NaN;    
    
    %% Update GUI
 	set(TP.UI.H.hExp_BCD_Image_NumSmplPerPixl_Edit,	'string', num2str(TP.D.Exp.BCD.ImageNumSmplPerPixl));
    set(TP.UI.H.hExp_BCD_Scan_NumPixlPerAxis_Edit, 	'string', num2str(TP.D.Exp.BCD.ScanNumPixlPerAxis));
   	set(TP.UI.H.hExp_BCD_Scan_NumLayrPerVlme_Edit, 	'string', num2str(TP.D.Exp.BCD.ScanNumLayrPerVlme));
   	set(TP.UI.H.hExp_BCD_Scan_LayrSpacingInZ_Edit, 	'string', num2str(TP.D.Exp.BCD.ScanLayrSpacingInZ));
  	set(TP.UI.H.hExp_BCD_Image_NumUpdtPerVlme_Edit,	'string', num2str(TP.D.Exp.BCD.ImageNumUpdtPerVlme));
    set(TP.UI.H.hExp_BCD_Image_NumVlmePerUpdt_Edit,	'string', num2str(TP.D.Exp.BCD.ImageNumVlmePerUpdt));    

    set(TP.UI.H.hExp_BCD_Scan_VolumeRate_Edit,	'string',   sprintf('%5.2f',TP.D.Exp.BCD.ScanVolumeRate));
  	set(TP.UI.H.hExp_BCD_Scan_VolumeTime_Edit,  'string',   sprintf('%5.7f',TP.D.Exp.BCD.ScanVolumeTime));
  	set(TP.UI.H.hExp_BCD_Image_UpdateRate_Edit,	'string',   sprintf('%5.2f',TP.D.Exp.BCD.ImageUpdateRate));
  	set(TP.UI.H.hExp_BCD_Image_UpdateTime_Edit, 'string',   sprintf('%5.7f',TP.D.Exp.BCD.ImageUpdateTime));

    %% Uncommit the Exp.BCD
    GUI_Rocker('hExp_BCD_Commit_Rocker', 'Uncommit');

function BCD_Commit
    global TP
    %% Generate Scanning Pattern: ScanSeq and ScanLUT
 	[TP.D.Exp.BCD.ScanScanSeq, TP.D.Exp.BCD.ScanScanInd] = feval(...
        TP.D.Exp.BCD.ScanGenFunc, ...
        TP.D.Exp.BCD.ScanNumSmplPerPixl,	TP.D.Exp.BCD.ImageNumSmplPerPixl, ...
    	TP.D.Exp.BCD.ScanNumPixlPerAxis, ...
		TP.D.Exp.BCD.ScanNumLayrPerVlme,	TP.D.Exp.BCD.ScanLayrSpacingInZ, ...
        TP.D.Sys.AOD.FreqCF,            TP.D.Sys.AOD.FreqBW );
    
    %% Exp.BCD parameters: Calculate & GUI Updates
	TP.D.Exp.BCD.Committed =            1;
    TP.D.Exp.BCD.CommitedTimeStamp =	datestr(now, 'yy/mm/dd HH:MM:SS.FFF');
    TP.D.Exp.BCD.CommitedFileName =	[   datestr( datenum(TP.D.Exp.BCD.CommitedTimeStamp), 'yymmddTHHMMSS'),...
                                        '_BCD_', replace(TP.D.Exp.BCD.ScanMode, ' ', '_')];
    TP.D.Exp.BCD.ScanNumSmplPerVlme =  length(TP.D.Exp.BCD.ScanScanSeq);
    TP.D.Exp.BCD.ScanVolumeRate = TP.D.Sys.NI.Task_DO_6536_SR / TP.D.Exp.BCD.ScanNumSmplPerVlme;
    TP.D.Exp.BCD.ScanVolumeTime = TP.D.Exp.BCD.ScanNumSmplPerVlme / TP.D.Sys.NI.Task_DO_6536_SR;
    TP.D.Exp.BCD.ImageNumPixlPerUpdt = TP.D.Exp.BCD.ScanNumSmplPerVlme / TP.D.Exp.BCD.ScanNumSmplPerPixl / TP.D.Exp.BCD.ImageNumUpdtPerVlme;                                    
    TP.D.Exp.BCD.ImageNumSmplPerUpdt = TP.D.Exp.BCD.ImageNumSmplPerPixl * TP.D.Exp.BCD.ImageNumPixlPerUpdt;
    TP.D.Exp.BCD.ImageUpdateRate = TP.D.Sys.NI.Task_AI_6115_SR / TP.D.Exp.BCD.ImageNumSmplPerUpdt;
    TP.D.Exp.BCD.ImageUpdateTime = TP.D.Exp.BCD.ImageNumSmplPerUpdt / TP.D.Sys.NI.Task_AI_6115_SR;
    set(TP.UI.H.hExp_BCD_Scan_VolumeRate_Edit,	'string',   sprintf('%5.2f',TP.D.Exp.BCD.ScanVolumeRate));
  	set(TP.UI.H.hExp_BCD_Scan_VolumeTime_Edit,  'string',   sprintf('%5.7f',TP.D.Exp.BCD.ScanVolumeTime));
 	set(TP.UI.H.hExp_BCD_Image_UpdateRate_Edit,	'string',   sprintf('%5.2f',TP.D.Exp.BCD.ImageUpdateRate));
  	set(TP.UI.H.hExp_BCD_Image_UpdateTime_Edit, 'string',   sprintf('%5.7f',TP.D.Exp.BCD.ImageUpdateTime));

	%% Image Enabled
    if TP.D.Exp.BCD.ImageEnable   
        if ~exist(TP.D.Exp.DataDir, 'dir')
            mkdir(TP.D.Exp.DataDir);
        end
        save([TP.D.Exp.DataDir, TP.D.Exp.BCD.CommitedFileName, '.mat'],...
            '-struct','TP','D');
            % Save BCD Data
            % this save along takes 1.27s on T5810 @2015/1/4
        SetupImageD;    
            % Setup TP.D.Vol 
        TP.UI.H0.hImage = image(...
                TP.D.Vol.LayerDisp{ (TP.D.Exp.BCD.ScanNumLayrPerVlme+1)/2 },...
                'parent',           TP.UI.H0.hAxesImage);
        axis off image; box on;                
            % Display Image
    end
    
    %% NI-DAQ: Unreserved & Committed   
    % hTask_DO_6536
    try TP.HW.NI.T.hTask_DO_6536.control('DAQmx_Val_Task_Unreserve');   catch;	end
    TP.HW.NI.T.hTask_DO_6536.cfgSampClkTiming(...
        TP.D.Sys.NI.Task_DO_6536_SR,    'DAQmx_Val_ContSamps',  TP.D.Exp.BCD.ScanNumSmplPerVlme);
    TP.HW.NI.T.hTask_DO_6536.set(...
        'sampClkTimebaseRate',          TP.D.Sys.NI.Sys_TimingRate,...
        'sampClkTimebaseSrc',           TP.D.Sys.NI.Sys_TimingBridge{2});  
    TP.HW.NI.T.hTask_DO_6536.cfgDigEdgeStartTrig(...
        TP.D.Sys.NI.Sys_TrigBridge{2},  'DAQmx_Val_Rising');
    TP.HW.NI.T.hTask_DO_6536.writeDigitalData(TP.D.Exp.BCD.ScanScanSeq);
        
    % hTask_AI_6115
    try TP.HW.NI.T.hTask_AI_6115.control('DAQmx_Val_Task_Unreserve');   catch;  end
    TP.HW.NI.T.hTask_AI_6115.cfgSampClkTiming(...
        TP.D.Sys.NI.Task_AI_6115_SR,    'DAQmx_Val_ContSamps',  TP.D.Exp.BCD.ImageNumSmplPerUpdt*8);
    TP.HW.NI.T.hTask_AI_6115.cfgDigEdgeStartTrig(...
        TP.D.Sys.NI.Sys_TrigBridge{2},  'DAQmx_Val_Rising');
    TP.HW.NI.T.hTask_AI_6115.registerEveryNSamplesEvent(...
        @updateScanKeeper,              TP.D.Exp.BCD.ImageNumSmplPerUpdt,...
        true,                           'native');

    %% Turn Laser Power ON
        
    %% MSG LOG
    msg = [datestr(now, 'yy/mm/dd HH:MM:SS.FFF') '\tBCD_Commit\tExp.BCD is committed\r\n'];
    updateMsg(TP.D.Exp.hLog, msg);  

function Ses_Load(varargin)
    global TP;

    %% where the call is from     
    if nargin==0
        % called by GUI:      
            % FANTASIA Specific: Check Whether Proceed
            % BCD commit ?
            if ~TP.D.Exp.BCD.Committed
                    errordlg('Exp BCD not committed yet!');
                    return
            end
            % Load sound only when ScanScheme == "Record"
            switch TP.D.Ses.ScanScheme
                case 'Search'                    
                    errordlg('"Search" Session scanning Mode does not support manually loading sounds!');
                    return
                case 'Record'
                case 'XBlaster'                    
                    errordlg('"XBlaster" not supported yet!');
                    return
                otherwise
                    errordlg('What is this?');
                    return
            end
        [TP.D.Ses.Load.SoundFile, TP.D.Ses.Load.SoundDir, FilterIndex] = ...
            uigetfile('.wav','Select a Sound File',...
            [TP.D.Sys.SoundDir, 'test.wav']);
        if FilterIndex == 0
            return
        end
    else
        % called by general update: SetupSoundLoad('D:\Sound.wav')
        filestr = varargin{1};
        [filepath,name,ext] = fileparts(filestr);
        TP.D.Ses.Load.SoundDir =        [filepath '\'];
        TP.D.Ses.Load.SoundFile =       [name ext];
    end

    %% Setup Session Loading
    SetupSesLoad('TP', 'Sound');

    %% FANTASIA Specific Updates
    TP.D.Sys.FigureTitle =                 [    TP.D.Sys.FullName ...
                                                TP.D.Ses.Load.SoundFigureTitle];
        set(TP.UI.H0.hFigTP,                    'Name',      TP.D.Sys.FigureTitle);
    if ~isnan(TP.D.Trl.Load.DurTotal) && TP.D.Exp.BCD.Committed
        set(TP.UI.H.hSes_StartStop_Momentary,	'Enable',	'on');
    else
        set(TP.UI.H.hSes_StartStop_Momentary,	'Enable',	'off');
    end

    %% LOG MSG
    msg = [datestr(now, 'yy/mm/dd HH:MM:SS.FFF') '\tSetupSoundLoad\tSession sound loaded as from file: "' ...
        TP.D.Ses.Load.SoundFile '"\r\n'];
    updateMsg(TP.D.Exp.hLog, msg);
        
function Ses_StartStop(varargin)
	global TP
    persistent Ses
    %% SESSION STATE: Switching Logic
    if nargin==0
        % Called W/O specifying a state number
        switch TP.D.Ses.State
            %   0   Session Stopped
            %   1   Session Started
            %   -4  Session Stopping by THE END of current CYCLE
            %   -3  Session Stopping by THE END of current TRIAL
            %   -2  Session Stopping by ENDING the current TRIAL NOW (after finishing the current VOL)
            %   -1  Session Stopping by CANCELLING the current TRIAL before TRIGGERED in 'XBlaster'
            case 0  % Session currently stopped,    so session START
                            TP.D.Ses.State = 1;
            case 1  % Session currently started,	so session STOPPING
                switch TP.D.Ses.ScanScheme
                    case 'Search'
                            TP.D.Ses.State = -2;    % Stopping by ENDING the current TRIAL NOW (after finishing the current VOL)
                    case 'Record'
                            TP.D.Ses.State = -4;    % Stopping by THE END of current CYCLE
                    case 'XBlaster'
                        if TP.D.Trl.State == 1 
                            TP.D.Ses.State = -1;	% Stopping by CANCELLING the current TRIAL before TRIGGERED in 'XBlaster'                           
                        else
                            TP.D.Ses.State = -3;	% Stopping by THE END of current TRIAL
                        end                            
                    otherwise                    
                end 
            case -4 % session currently Stopping by THE END of current CYCLE, 
                            TP.D.Ses.State = -3;    % Stopping by THE END of current TRIAL
            case -3 % session currently Stopping by THE END of current TRIAL, 
                            TP.D.Ses.State = -2;    % Stopping by ENDING the current TRIAL NOW (after finishing the current VOL)
            otherwise
        end
    else
        % Called W/ specifying a state number
                        TP.D.Ses.State = varargin{1};
    end
    %%  SESSION STATE: Execution
    switch TP.D.Ses.State
        %   0   Session Stopped
        %   1   Session Started
        %   -4  Session Stopping by THE END of current CYCLE
        %   -3  Session Stopping by THE END of current TRIAL
        %   -2  Session Stopping by ENDING the current TRIAL NOW
        %   -1  Session Stopping by CANCELLING the current TRIAL before TRIGGERED in 'XBlaster'
        case 1      % Session Started
            % Session TIMING information
            TP.D.Ses.TimeStampStart =           datestr(now, 'yy/mm/dd HH:MM:SS.FFF');
            TP.D.Ses.TargetedCycleNumTotal =	TP.D.Ses.Load.CycleNumTotal; 
            TP.D.Ses.TargetedTrlNumTotal =      TP.D.Ses.TargetedCycleNumTotal * ...
                                                TP.D.Trl.Load.NumTotal; 
            TP.D.Trl.TargetedTrlDurTotal =      TP.D.Trl.Load.DurTotal;  
            TP.D.Ses.TargetedTrlNumCurrent =    0;                              
            % Save Session Data if Image Enabled
            if TP.D.Exp.BCD.ImageEnable   
                TP.D.Ses.FileName =             [datestr(TP.D.Ses.TimeStampStart, 'yymmddTHHMMSS'),...
                                                '_Ses_', TP.D.Ses.ScanScheme];
                if ~exist(TP.D.Exp.DataDir, 'dir')
                    mkdir(TP.D.Exp.DataDir);
                end
                Ses = TP.D.Ses;
                save([TP.D.Exp.DataDir, TP.D.Ses.FileName, '.mat'],...
                    '-struct','Ses');
            end 
            
            % Release Overloaded
            TP.D.Ses.OverloadLasser =           0;
            TP.D.Ses.OverloadPMT =              0;
            
            % GUI Enable/Inactive
            
            % Turn Laser Shutter
            
            % Turn PMT switches            
            feval(TP.D.Sys.Name, 'GUI_DO_6115',...
                TP.D.Exp.BCD.ImageEnable *	[   1;      1;      0]);
                                            %   PMTon,  FANoff, PELoff               
            % Turn TDT (if not XBlaster) 
            if ~strcmp(TP.D.Ses.ScanScheme, 'XBlaster')
                TP.HW.TDT.PA5 = actxcontrol('PA5.x',[0 0 1 1]);
                pause(1);
                invoke(TP.HW.TDT.PA5,'ConnectPA5','USB',1);
            end  
            % Start the current (first) trial
            scanStarted;
        case -4     % Session Stopping by THE END of current CYCLE        
            TP.D.Ses.TargetedCycleNumTotal =	TP.D.Ses.Load.CycleNumCurrent; 
            TP.D.Ses.TargetedTrlNumTotal =      TP.D.Ses.TargetedCycleNumTotal * ...
                                                    TP.D.Trl.Load.NumTotal; 
            TP.D.Trl.TargetedTrlDurTotal =      TP.D.Trl.TargetedTrlDurTotal; 
        case -3     % Session Stopping by THE END of current TRIAL
            TP.D.Ses.TargetedCycleNumTotal =	TP.D.Ses.Load.CycleNumCurrent; 
            TP.D.Ses.TargetedTrlNumTotal =      TP.D.Ses.TargetedTrlNumCurrent;
            TP.D.Trl.TargetedTrlDurTotal =      TP.D.Trl.TargetedTrlDurTotal; 
        case -2     % Session Stopping by ENDING the current TRIAL NOW (after finishing the current VOL)
            TP.D.Ses.TargetedCycleNumTotal =	TP.D.Ses.Load.CycleNumCurrent; 
            TP.D.Ses.TargetedTrlNumTotal =      TP.D.Ses.TargetedTrlNumCurrent; 
            TP.D.Trl.TargetedTrlDurTotal =      TP.D.Trl.Load.DurCurrent; 
        case -1     % Session Stopping by CANCELLING the current TRIAL before TRIGGERED in 'XBlaster'
            TP.D.Ses.TargetedTrlNumCurrent =    TP.D.Ses.TargetedTrlNumCurrent - 1; 
            TP.D.Ses.TargetedTrlNumTotal =      TP.D.Ses.TargetedTrlNumCurrent; 
            TP.D.Trl.TargetedTrlDurTotal =      0; 
            scanStopped;
        case 0      % Session Stopped    
            % Session TIMING information    
            TP.D.Ses.TimeStampStop =            datestr(now, 'yy/mm/dd HH:MM:SS.FFF');                                             
            % Save Session Data if Image Enabled
            if TP.D.Exp.BCD.ImageEnable   
                TP.D.Ses.FileName =             [datestr(TP.D.Ses.TimeStampStart, 'yymmddTHHMMSS'),...
                                                '_Ses_', TP.D.Ses.ScanScheme];
                Ses = TP.D.Ses;
                save([TP.D.Exp.DataDir, TP.D.Ses.FileName, '.mat'],...
                    '-struct','Ses');
            end 
            % GUI Enable/Inactive
            
            % Turn Laser Shutter
            
            % Turn PMT switches 
            feval(TP.D.Sys.Name, 'GUI_DO_6115',...
                TP.D.Exp.BCD.ImageEnable *	[   0;      0;      0]);
                                            %   PMTon,  FANoff, PELoff  
            % Turn TDT (if not XBlaster)
            invoke(TP.HW.TDT.PA5,   'SetAtten', 120);
            set(TP.UI.H.hTrl_AttCurrent_Edit,	'String',	'Max');
        otherwise                            
    end
	%% MSG LOG
    msg = [datestr(now, 'yy/mm/dd HH:MM:SS.FFF') '\tSes_StartTrigStop Called\r\n'];
    updateMsg(TP.D.Exp.hLog, msg);  
       
%% GUI Inputs w/ Updating Housekeeing NI-DAQ Tasks 
function msg = GUI_AO_6115(varargin)
    global TP;
    
   	%% get the numbers
    if nargin==0
        % called by GUI:            GUI_AO_6115 
      	uictrlstyle = get(gcbo, 'Style');
        switch uictrlstyle
            case 'slider'
                AO1 = get(TP.UI.H.hMon_PMT_CtrlGainValue_PotenSlider,'value');
                AO2 = get(TP.UI.H.hMon_Power_AOD_CtrlAmpValue_PotenSlider,'value');
            case 'edit'
                AO1 = str2double(get(TP.UI.H.hMon_PMT_CtrlGainValue_PotenEdit,'string'));
                AO2 = str2double(get(TP.UI.H.hMon_Power_AOD_CtrlAmpValue_PotenEdit,'string'));
            otherwise
                errordlg('What''s the hell is this?');
                return;
        end
    else
        % called by general update:	GUI_AO_6115([AO1 AO2])
        AO = varargin{1};   AO1 = AO(1);    AO2 = AO(2);
    end
    
    %% prepare numbers as x.xx Volts
    AO1 = round(AO1*100)/100;
    AO2 = round(AO2*100)/100;  
    
    %% whether it's out of the range, then output
    if      AO1 >= TP.D.Sys.PMT.CtrlGainRange(1)...
        &&  AO1 <= TP.D.Sys.PMT.CtrlGainRange(2)...
        &&  AO2 >= TP.D.Sys.Power.AOD_CtrlAmpRange(1)...
        &&  AO2 <= TP.D.Sys.Power.AOD_CtrlAmpRange(2)   
    
        TP.D.Mon.PMT.CtrlGainValue =        AO1;
        TP.D.Mon.Power.AOD_CtrlAmpValue =   AO2;
        TP.HW.NI.T.hTask_AO_6115.writeAnalogData(...
            [AO1    AO2*(   TP.D.Trl.State==2   )]);
                            % 0 = Stop:         Only update PMT_Gain.    
                            % 1 = Start:        Only update PMT_Gain
                            % 2 = Triggered:    update both PMT_Gain and AOD_Amp
        %% MSG LOG
        msg = [datestr(now, 'yy/mm/dd HH:MM:SS.FFF') '\tGUI_AO_6115\tAO_6115 is updated to ''',...
            num2str(AO1),', ',num2str(AO2),''' Volt\r\n'];
        updateMsg(TP.D.Exp.hLog, msg);        
    else
        errordlg('Analog output level is out of range');
        AO1 = TP.D.Mon.PMT.CtrlGainValue;
        AO2 = TP.D.Mon.Power.AOD_CtrlAmpValue;  
    end
    %% update GUI
    set(TP.UI.H.hMon_PMT_CtrlGainValue_PotenSlider,         'value',AO1);
    set(TP.UI.H.hMon_Power_AOD_CtrlAmpValue_PotenSlider,	'value',AO2);
    set(TP.UI.H.hMon_PMT_CtrlGainValue_PotenEdit,       'string',sprintf('%1.2f',AO1));       
    set(TP.UI.H.hMon_Power_AOD_CtrlAmpValue_PotenEdit,	'string',sprintf('%1.2f',AO2));
    
function msg = GUI_DO_6115(varargin)
    global TP
    
  	%% where the call is from
    
  	h{1} = get(TP.UI.H.hMon_PMT_PMTctrl_Rocker, 'Children');        
	h{2} = get(TP.UI.H.hMon_PMT_FANctrl_Toggle, 'Children');        
  	h{3} = get(TP.UI.H.hMon_PMT_PELctrl_Toggle, 'Children');
    if nargin==0
        % called by GUI:            GUI_DO_6115 
      	% read values from the UI Control Panel
        DO = [ 	get(get(TP.UI.H.hMon_PMT_PMTctrl_Rocker,'SelectedObject'),'UserData');...                  
                get(get(TP.UI.H.hMon_PMT_FANctrl_Toggle,'SelectedObject'),'UserData');... 
                get(get(TP.UI.H.hMon_PMT_PELctrl_Toggle,'SelectedObject'),'UserData')...
                               ]>0;
    else
        % called by general update:	GUI_DO_6115([PMTctrl; FANctrl; PELctrl])
        DO = logical(varargin{1}); 
        % update GUI
        set(TP.UI.H.hMon_PMT_PMTctrl_Rocker, 'SelectedObject', h{1}(DO(1)+2));
        set(TP.UI.H.hMon_PMT_FANctrl_Toggle, 'SelectedObject', h{2}(DO(2)+2));
        set(TP.UI.H.hMon_PMT_PELctrl_Toggle, 'SelectedObject', h{3}(DO(3)+2));
    end
    %% update TP.D
    for i = 1:length(TP.D.Sys.NI.Chan_DO_PMT_Switch{3})
    	eval(['PMT_Ctrl(i,1)=logical(', TP.D.Sys.NI.Chan_DO_PMT_Switch{3}{i},');']);
    end 
    %% Write Data to the Task
    TP.HW.NI.T.hTask_DO_6115.writeDigitalData(DO);
    %% Change color
    for i = 1:3
        for j = 2:3
            if j ==DO(i)+2  set(h{i}(j),    'backgroundcolor', TP.UI.C.SelectB);
            else         	set(h{i}(j),    'backgroundcolor', TP.UI.C.TextBG);    end
        end
    end
    %% MSG LOG
    msg = [datestr(now, 'yy/mm/dd HH:MM:SS.FFF') '\tGUI_DO_6115\tDO_6115 is updated to [',...
        num2str(DO'),']\r\n'];
    updateMsg(TP.D.Exp.hLog, msg);       

function msg = GUI_PowerHWP(varargin)
    global TP;
    
   	%% get the numbers
    if nargin==0
        % called by GUI:            GUI_PowerHWP 
      	uictrlstyle = get(gcbo, 'Style');
        switch uictrlstyle
            case 'slider'
                angle = get(TP.UI.H.hMon_Power_HWP_CtrlAglValue_PotenSlider,'value');
            case 'edit'
                angle = str2double(get(TP.UI.H.hMon_Power_HWP_CtrlAglValue_PotenEdit,'string'));            otherwise
                errordlg('What''s the hell is this?');
                return;
        end
    else
        % called by general update:	GUI_PowerHWP(34.2)
        angle = varargin{1};
    end
    
    %% prepare numbers as xxx.x Angles and 0 < angle < 90
    angle = mod(angle, 360);
    angle = round(angle*10)/10;
    
    %% update GUI & temporarily inactivate them
    set(TP.UI.H.hMon_Power_HWP_CtrlAglValue_PotenSlider,'value',	angle);
    set(TP.UI.H.hMon_Power_HWP_CtrlAglValue_PotenSlider,'enable',	'inactive');
    set(TP.UI.H.hMon_Power_HWP_CtrlAglValue_PotenEdit,	'string',   sprintf('%5.1f',angle)); 
    set(TP.UI.H.hMon_Power_HWP_CtrlAglValue_PotenEdit,	'enable',	'inactive');    
    set(TP.UI.H.hMon_Power_HWP_CtrlAglValue_PotenEdit,	'Foregroundcolor', TP.UI.C.FG);
    
    %% do motors and check, update angles
    updatePowerRotMove( TP.HW.Thorlabs.hPRM1Z8,	angle,  40);
    updatePowerRotCheck(TP.HW.Thorlabs.hPRM1Z8,	angle,  0.003);
    
    %% update GUI & reactivate them
    set(TP.UI.H.hMon_Power_HWP_CtrlAglValue_PotenSlider,'enable',	'on');
    set(TP.UI.H.hMon_Power_HWP_CtrlAglValue_PotenEdit,	'enable',	'on'); 
    set(TP.UI.H.hMon_Power_HWP_CtrlAglValue_PotenEdit,	'Foregroundcolor', TP.UI.C.SelectT);
    
    %% MSG LOG
    msg = [datestr(now, 'yy/mm/dd HH:MM:SS.FFF'), '\tGUI_PowerHWP\tHWP Motor is updated to ',...
        sprintf('%5.1f',angle), ' Degree.\r\n'];
    updateMsg(TP.D.Exp.hLog, msg);          
           
function GUI_CleanUp
    global TP
    
    choice = questdlg (...
        'Stop & Clean Up Everything?',...
        'Clean Up',...
        'Yes, Clean Up', 'Do Nothing',...
        'Yes, Clean Up'...
        );
    switch choice
        case 'Yes, Clean Up'
            %% Reset Home Values
            try     
                GUI_AO_6115([0 0]);  
            catch
                warndlg('Can not reset NI AO values');
            end
            try     
                GUI_DO_6115([0; 1; 1]); 
            catch
                warndlg('Can not reset NI DO values','Close up error');
            end
            pause(0.5);

            %% Stop & Delete NI-DAQ tasks
            try
                TaskNames = fieldnames(TP.HW.NI.T);
                for i = 1:length(TaskNames)
                    TaskName = strcat('TP.HW.NI.T.',TaskNames{i});
                    eval(strcat('try;',TaskName,'.abort(); end;'));
                    eval(strcat('try;',TaskName,'.delete(); end;'));
                end
            catch
                warndlg('Can not delete NI-DAQ tasks');
            end

            %% Stop & Delete Thorlabs Power Meters
            try 
                for i =1:size(TP.D.Sys.Power.Meter.ID,1)                    
                    fprintf(    TP.HW.Thorlabs.PM100{i}.h,'*RST');
                    fclose(     TP.HW.Thorlabs.PM100{i}.h);
                end
            catch
                warndlg('Can not close Thorlabs Power Meters');
            end

            %% Stop & Delete Thorlabs Motors
            try 
                % Move the PRM1Z8 Motor back to 0
                GUI_PowerHWP(0);
%                 updatePowerRotMove(	TP.HW.Thorlabs.hPRM1Z8, 0,  40);
                updatePowerRotCheck(TP.HW.Thorlabs.hPRM1Z8, 0,  0.003);
                delete(TP.UI.H0.hFigPRM1Z8);
            catch
                warndlg('The PRM1Z8 Motor may not return to the Home position');
            end            

            %% MSG LOG and close log file
            try
                msg = [datestr(now, 'yy/mm/dd HH:MM:SS.FFF') '\t' TP.D.Sys.Name '\tProgram Closed, Two Photon ROCKS! \r\n'];
                updateMsg(  TP.D.Exp.hLog, msg);
                fclose(     TP.D.Exp.hLog);
                if exist(TP.D.Exp.DataDir, 'dir')   
                    movefile(   [TP.D.Sys.DataDir, TP.D.Exp.LogFileName],...
                                [TP.D.Exp.DataDir, TP.D.Exp.LogFileName]); 
                end
                
            catch
                warndlg('Can not write log file');
            end

            %% Clean Up Figure and Data
            try
                delete(TP.UI.H0.hFigTP);
            catch
                warndlg('Can not delete the UI Figure');
            end
            clear all;
        case 'Do Nothing'
        otherwise
    end
