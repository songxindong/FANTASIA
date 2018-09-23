function msg = SetupFigure
% Initiate the display scale parameters
% TP.UI.S = Two Photon Laser Scanning Microscope. User Interface. Scale
%   S.Screen
%       S.Fig
%           S.Panel
%               S.Panellete
%               S.Axes
%           S.Panel

global TP

%% Turn the JAVA LookAndFeel Scheme "Windows" on
% lafs = javax.swing.UIManager.getInstalledLookAndFeels; 
% for lafIdx = 1:length(lafs),  disp(lafs(lafIdx));  end
% javax.swing.UIManager.setLookAndFeel('javax.swing.plaf.metal.MetalLookAndFeel');
% javax.swing.UIManager.setLookAndFeel('javax.swing.plaf.nimbus.NimbusLookAndFeel');
% javax.swing.UIManager.setLookAndFeel('com.sun.java.swing.plaf.motif.MotifLookAndFeel');
% javax.swing.UIManager.setLookAndFeel('com.sun.java.swing.plaf.windows.WindowsLookAndFeel');
% javax.swing.UIManager.setLookAndFeel('com.sun.java.swing.plaf.windows.WindowsClassicLookAndFeel');
javax.swing.UIManager.setLookAndFeel(TP.UI.LookAndFeel);

%% Global Spacer Scale
S.SP = 10;          % Panelette Side Spacer
S.SD =4;            % Double Spacer
S.S = 2;            % Small Spacer 

%% create Figure in the Screen 
    % Screen scale, get the ends of multiple monitors
        % should be checked again for duplicated mode
    MonitorPositions = get(0,'MonitorPositions');
    S.ScreenEnds = [min(MonitorPositions(:,1)) min(MonitorPositions(:,2)) ...
                    max(MonitorPositions(:,3)) max(MonitorPositions(:,4))];
    S.ScreenWidth =     S.ScreenEnds(3) - S.ScreenEnds(1) +1;
    S.ScreenHeight =    S.ScreenEnds(4) - S.ScreenEnds(2) +1;

    % Figure scale
    S.FigSideTitleHeight =  25; 
    S.FigSideWidth =        2;

    S.FigWidth =    S.ScreenWidth - 2*S.FigSideWidth;
    S.FigHeight =   S.ScreenHeight - S.FigSideTitleHeight - S.FigSideWidth;

    S.FigCurrentW = S.ScreenEnds(1) + S.FigSideWidth;
    S.FigCurrentH = S.ScreenEnds(2) + S.FigSideWidth;
    
    % create the UI figure 
    TP.UI.H0.hFigTP = figure(...
                'Name',             [   TP.D.Sys.Name,...
                                        '  -  ',...
                                        TP.D.Sys.FullName],...
                'NumberTitle',      'off',...
                'Resize',           'off',...
                'color',         	TP.UI.C.BG,...
                'position',         [   S.FigCurrentW,  S.FigCurrentH,...
                                        S.FigWidth,     S.FigHeight],...
                'menubar',          'none');

%% create Panel:Control &   Panelettes 
    % Panelette Scale
    S.PaneletteWidth = 100;     S.PaneletteHeight = 150;    
    S.PaneletteTitle = 18;

    % Panelette, Total #s of rows and columns
    S.PaneletteRowNum = 7;      S.PaneletteColumnNum = 8;

    % Panelette, layout of rows    
    S.PnltSys.row =         7;    S.PnltSys.column =        1;
    S.PnltMech.row =        6;    S.PnltMech.column =       1;
    S.PnltBCD.row =         5;    S.PnltBCD.column =        1;
    S.PnltSes.row =         4;    S.PnltSes.column =        1;
    S.PnltTrl.row =         3;    S.PnltTrl.column =        1;
    S.PnltMonImage.row =    2;    S.PnltMonImage.column	=   1;
    S.PnltMonPower.row =    1;    S.PnltMonPower.column =   1;

    % Control Panel Scale 
    S.PanelCtrlWidth =  S.PaneletteColumnNum *(S.PaneletteWidth+S.S) + 3*(2*S.S);
    S.PanelCtrlHeight = S.PaneletteRowNum *(S.PaneletteHeight+S.S) + S.PaneletteTitle;

    % current Position
	S.PanelCurrentW = S.SD + 0;
    S.PanelCurrentH = S.SD;
    
    % create Panel:Control
    TP.UI.H0.hPanelCtrl = uipanel(...
                'parent',           TP.UI.H0.hFigTP,...
                'BackgroundColor', 	TP.UI.C.BG,...
                'Highlightcolor',  	TP.UI.C.HL,...
                'ForegroundColor',	TP.UI.C.FG,...
                'units',            'pixels',...
                'Title',            'CONTROL PANEL',...
                'Position',         [   S.PanelCurrentW     S.PanelCurrentH     	...
                                        S.PanelCtrlWidth    S.PanelCtrlHeight]);
                
      	% create Panelettes                     
        for i = 1:S.PaneletteRowNum
            for j = 1:S.PaneletteColumnNum
                TP.UI.H0.Panelette{i,j}.hPanelette = uipanel(...
                'parent',           TP.UI.H0.hPanelCtrl,...
                'BackgroundColor', 	TP.UI.C.BG,...
                'Highlightcolor',  	TP.UI.C.HL,...
                'ForegroundColor',	TP.UI.C.FG,...
                'units',            'pixels',...
                'Title',            ' ',...
                'Position',         [   2*S.S+(S.S+S.PaneletteWidth)*(j-1),...
                                        2*S.S+(S.S+S.PaneletteHeight)*(i-1),...
                                        S.PaneletteWidth, S.PaneletteHeight]    );
                        % edge is 2*S.S
            end
        end
        createPanelettes(S);
        
%% create Panel:Image &     Axes:Image
    % Axes scale
    S.PanelImageAxesWH =    653;

    % Image Panel Scale
    S.PanelImageWidth =     S.PanelImageAxesWH + 2*S.SD;
    S.PanelImageHeight =    S.PanelImageAxesWH + 1*S.SD + S.PaneletteTitle;
    
    % current Position
    S.PanelCurrentW = S.SD + S.PanelCtrlWidth + S.SD;
    S.PanelCurrentH = S.SD;
    % S.PanelCurrentH = S.PanelCurrentH + S.PanelCtrlHeight + 2*S.S;
    
    % create Panel:Image
    TP.UI.H0.hPanelImage = uipanel(...
        'parent', TP.UI.H0.hFigTP,...
                'BackgroundColor', 	TP.UI.C.BG,...
                'Highlightcolor',  	TP.UI.C.HL,...
                'ForegroundColor',	TP.UI.C.FG,...
        'units','pixels',...
        'Title', 'IMAGE PANEL',...
        'Position',[S.PanelCurrentW         S.PanelCurrentH     	...
                    S.PanelImageWidth    S.PanelImageHeight]);
                
        % create Axes:Image
        TP.UI.H0.hAxesImage = axes(...
            'parent', TP.UI.H0.hPanelImage,...
            'units','pixels',...
            'Position',[S.SD                S.SD                    ...              
                        S.PanelImageAxesWH  S.PanelImageAxesWH]);
            
            % crreate Image:Disp
            TP.UI.H0.hImageDisp = image(TP.D.Vol.LayerDisp{1},...
                'parent',TP.UI.H0.hAxesImage);
            axis off
            axis image
            box on  
                    
%% create Panel:Angle &     Axes:Angle
    % Axes Scale
    S.PanelAngleAxesWH = 200;

    % Angle Panel Scale
    S.PanelAngleWidth =     S.PanelAngleAxesWH + S.S + S.SD;
    S.PanelAngleHeight =    S.PanelAngleAxesWH + S.SD + S.PaneletteTitle;

    % create the Image Panel
    S.PanelCurrentW = S.PanelCurrentW ;
    S.PanelCurrentH = S.PanelCurrentH + S.PanelImageHeight + S.SD;
    TP.UI.H0.hPanelAngle = uipanel(...
        'parent', TP.UI.H0.hFigTP,...
                'BackgroundColor', 	TP.UI.C.BG,...
                'Highlightcolor',  	TP.UI.C.HL,...
                'ForegroundColor',	TP.UI.C.FG,...
        'units','pixels',...
        'Title', 'ANGLE PANEL',...
        'Position',[S.PanelCurrentW     S.PanelCurrentH     	...
                    S.PanelAngleWidth	S.PanelAngleHeight]);
                        
        % create the Axes
        TP.UI.H0.hAxesAngle = axes(...
            'parent', TP.UI.H0.hPanelAngle,...
            'units','pixels',...
            'Position',[0                   S.S   ...              
                        S.PanelAngleAxesWH  S.PanelAngleAxesWH]);   
        SetupDispAngle(TP.UI.H0.hAxesAngle);      
        
%% create Panel:Hist &      Axes:Hist, HistCM
    % Image Scale
    S.PanelHistAxesWidth = 410;
    S.PanelHistAxesHeight = 200;

    % Image Panel Scale
    S.PanelHistWidth =     S.PanelHistAxesWidth + 2*(S.SD);
    S.PanelHistHeight =    S.PanelHistAxesHeight + 1*(S.SD) + S.PaneletteTitle;

    % create the Image Panel
    S.PanelCurrentW = S.PanelCurrentW + S.PanelAngleWidth + S.SD;
    S.PanelCurrentH = S.PanelCurrentH;
    TP.UI.H0.hPanelHist = uipanel(...
        'parent', TP.UI.H0.hFigTP,...
                'BackgroundColor', 	TP.UI.C.BG,...
                'Highlightcolor',  	TP.UI.C.HL,...
                'ForegroundColor',	TP.UI.C.FG,...
        'units','pixels',...
        'Title', 'HISTOGRAM PANEL',...
        'Position',[S.PanelCurrentW     S.PanelCurrentH     	...
                    S.PanelHistWidth	S.PanelHistHeight]);
                        
        % create the Axes:Hist
        TP.UI.H0.hAxesHist = axes(...
            'parent', TP.UI.H0.hPanelHist,...
            'units', 'pixels', ...
            'Position', [   25	35	380 170]);
                
            % create Bar:Hist
        
            TP.UI.H0.Hist0.hBarHist  = ...
                bar(    (1:1:300)', TP.D.Vol.PixelHist,...
                        'parent', TP.UI.H0.hAxesHist,...
                        'FaceColor', [.5 .5 .5]);    
            set(TP.UI.H0.Hist0.hBarHist,...
                'Ydata', TP.D.Vol.PixelHist);
            
        set(TP.UI.H0.hAxesHist,...
            'FontSize', 6,          'color',        TP.UI.C.BG,...
            'YTick',    [0 1],      'YTickLabel',   {'0'; 'peak'},...
            'YLim',     [0 1.1],    'YColor',       TP.UI.C.FG,...
            'XTick',    [44 300],   'XTickLabel',   {'0'; 'max'},...
            'XLim',     [1 380],    'XColor',       TP.UI.C.FG,...
            'NextPlot', 'add');
                    
            % create Text:
            text(305, 1.000, 'max', 'color', TP.UI.C.FG, 'parent', TP.UI.H0.hAxesHist);
            text(305, 0.750, 'min', 'color', TP.UI.C.FG, 'parent', TP.UI.H0.hAxesHist);
            text(305, 0.500, 'peak', 'color', TP.UI.C.FG, 'parent', TP.UI.H0.hAxesHist);
            text(305, 0.250, 'mean', 'color', TP.UI.C.FG, 'parent', TP.UI.H0.hAxesHist);
            TP.UI.H0.Hist0.hTextMax = ...
                text(310, 0.875, 'MAX', 'color', [0 .5 0], 'parent', TP.UI.H0.hAxesHist);
            TP.UI.H0.Hist0.hTextMin = ...
                text(310, 0.625, 'MIN', 'color', [0 .5 0], 'parent', TP.UI.H0.hAxesHist);
            TP.UI.H0.Hist0.hTextPeak = ...
                text(310, 0.375, 'PEAK', 'color', [0 .5 0], 'parent', TP.UI.H0.hAxesHist);
            TP.UI.H0.Hist0.hTextMean = ...
                text(310, 0.125, 'MEAN', 'color', [0 .5 0], 'parent', TP.UI.H0.hAxesHist);
            
            % create Mark:
            TP.UI.H0.Hist0.hMarkMax = ...
                plot(44, 1.05, 'g.', 'parent', TP.UI.H0.hAxesHist);
            TP.UI.H0.Hist0.hMarkMin = ...
                plot(44, 1.05, 'g.', 'parent', TP.UI.H0.hAxesHist);
            TP.UI.H0.Hist0.hMarkPeak = ...
                plot(44, 1.05, 'g.', 'parent', TP.UI.H0.hAxesHist);
                    
        % create Axes:HistCM
        TP.UI.H0.hAxesHistCM = axes(...
            'parent',   TP.UI.H0.hPanelHist,...
            'units',    'pixels',...
            'Position', [25   2   300 20]);

            imagecontrast = zeros(20,300,3);
            % 300 bins
            imagecontrast(:,44:end-1,2) = repmat(0:1/255:1,20,1);
            imagecontrast(:,end,2)      = 1;
            % 44-300 column, 256 +1
            
            imagesc(imagecontrast, 'parent', TP.UI.H0.hAxesHistCM);
    	set(TP.UI.H0.hAxesHistCM, 'Ytick', [], 'Xtick', []);        
  
%% Adjust Figure Size
        S.FigWidth =    S.SD*2 + S.PanelCtrlWidth + ...
                        max(S.PanelImageWidth,(S.PanelAngleWidth+S.SD+S.PanelHistWidth));
        S.FigHeight =   S.SD*2 + ...
                        max(S.PanelCtrlHeight,(S.PanelImageHeight+S.SD+S.PanelAngleHeight));
        set(TP.UI.H0.hFigTP, ...
          'position',	[   S.FigCurrentW,  S.FigCurrentH,...
                        	S.FigWidth,     S.FigHeight]);
                        
TP.UI.S = S;

%% LOG MSG
    msg = [datestr(now, 'yy/mm/dd HH:MM:SS.FFF') '\tSetupFigure\tGUI initialized\r\n'];
    updateMsg(TP.D.Exp.hLog, msg);

function createPanelettes(S)
%% create panelettes
global TP

%% Sys
for disp=1
    S.PnltCurrent.row       = S.PnltSys.row;
    S.PnltCurrent.column    = S.PnltSys.column;
	for i = 1:ceil(length(TP.D.Sys.Scan.PresetGroup)/2)
        % create Toggle Switch panels 'Scan Preset #1~?'
        WP.name =       strcat('Sys Preset #',num2str(i));
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type =       'ToggleSwitch';	
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text = { TP.D.Sys.Scan.PresetGroup{i*2-1}.title,...
                    TP.D.Sys.Scan.PresetGroup{i*2-0}.title};    
        WP.tip = {  TP.D.Sys.Scan.PresetGroup{i*2-1}.tip,...
                    TP.D.Sys.Scan.PresetGroup{i*2-0}.tip};
        WP.inputOptions = { TP.D.Sys.Scan.PresetCfg{i*6-5}.name,...
                            TP.D.Sys.Scan.PresetCfg{i*6-4}.name,...
                            TP.D.Sys.Scan.PresetCfg{i*6-3}.name;...
                            TP.D.Sys.Scan.PresetCfg{i*6-2}.name,...
                            TP.D.Sys.Scan.PresetCfg{i*6-1}.name,...
                            TP.D.Sys.Scan.PresetCfg{i*6-0}.name};
        WP.inputDefault = [ TP.D.Sys.Scan.PresetGroup{i*2-1}.default...
                            TP.D.Sys.Scan.PresetGroup{i*2-0}.default];
        WP.enable = [   TP.D.Sys.Scan.PresetCfg{i*6-5}.SelectEnable,...
                     	TP.D.Sys.Scan.PresetCfg{i*6-4}.SelectEnable,...
                     	TP.D.Sys.Scan.PresetCfg{i*6-3}.SelectEnable;...
                      	TP.D.Sys.Scan.PresetCfg{i*6-2}.SelectEnable,...
                      	TP.D.Sys.Scan.PresetCfg{i*6-1}.SelectEnable,...
                      	TP.D.Sys.Scan.PresetCfg{i*6-0}.SelectEnable];
        Panelette(S, WP, 'TP'); 
        TP.UI.H.hSys_Scan_PresetCfg_Toggle{i*2-1} = TP.UI.H0.Panelette{WP.row,WP.column}.hToggle{1};
        TP.UI.H.hSys_Scan_PresetCfg_Toggle{i*2-0} = TP.UI.H0.Panelette{WP.row,WP.column}.hToggle{2};    
        clear WP; 
            
        % set tag of each button to be 1~?
        for j =1:2
            htemp = get(TP.UI.H.hSys_Scan_PresetCfg_Toggle{i*2-2+j}, 'children');
            for k = 1:length(htemp)
                set(htemp(k),'tag',num2str( (i-1)*6 + j*3 - k + 1));
            end
        end
	end
    
	WP.name = 'Sys AOD Freq';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type = 'Edit';           
        WP.row      = S.PnltCurrent.row;
        WP.column   = S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;     
        WP.text = {	'Scan Frequency Bandwidth (MHz)',...
                    'Central Drive Frequency (MHz)'};
        WP.tip = {	'Scan Frequency Bandwidth (MHz)',...
                    'Central Drive Frequency (MHz)'};
        WP.inputValue = {   TP.D.Sys.AOD.FreqBW / 1e6,...
                            TP.D.Sys.AOD.FreqCF / 1e6};
        WP.inputFormat = {'%5.1f','%5.1f'};    
        WP.inputEnable = {'on','on'};
        Panelette(S, WP, 'TP');    
        TP.UI.H.hSys_AOD_FreqBW_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};
        TP.UI.H.hSys_AOD_FreqCF_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
        set(TP.UI.H.hSys_AOD_FreqBW_Edit, 'tag', 'hSys_AOD_FreqBW_Edit');
        set(TP.UI.H.hSys_AOD_FreqCF_Edit, 'tag', 'hSys_AOD_FreqC_Edit');
        clear WP;
        
	WP.name = 'Sys PowerCalib';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type = 'MomentarySwitch'; 
        WP.row =        S.PnltCurrent.row;         
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text = { 'Power Calibration',...
                    ''};
        WP.tip = {[ 'Before press, make sure S170C is connected on PM100A (PM100{2}),\n',...
                    'and PM100A is powered on before launching FANTASIA program, \n',...
                    'The function will calibrate 4 things:\n',...
                    '   1. HWP: Power@S121C vs HWP Angle;\n',... 
                    '   2. ARM: Power@S170C vs Power@S121C;\n',...
                    '   3. AMP: X*Y Voltage vs AOD Ctrrl Voltage;\n',...
                    '   4. AOD: Power@S121C vs Power@S121C;\n',...
                    'Juat follow the instructions in the Matlab command window.\n'],...
                    ''  };
        WP.inputEnable = {'on','inactive'};
        Panelette(S, WP, 'TP');
        TP.UI.H.hSys_PowerCalib_Momentary = TP.UI.H0.Panelette{WP.row,WP.column}.hMomentary{1}; 
        set(TP.UI.H.hSys_PowerCalib_Momentary, 'tag', 'hSys_CalibPowerIn_Momentary');
        clear WP;        
        
	WP.name = 'Sys PowerParam';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type =       'Edit';         	
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;  
        WP.text =   {   'Dichroic Ratio ~= power@Cortex / power@S121C',...
                        'HWP/PRM1Z8 angle when output laser maximizes'};
        WP.tip =    {   '',...
                        ''};
        WP.inputValue = {	TP.D.Sys.Power.C.ARM_p1,...
                            TP.D.Sys.Power.C.HWP_pmaxAngle};
        WP.inputFormat = {'%5.2f','%5.2f'};
        WP.inputEnable = {'inactive','inactive'};
        Panelette(S, WP, 'TP');
        TP.UI.H.hSys_Power_LaserDichRatio_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};  
        TP.UI.H.hSys_Power_LaserMaxAglHWP_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
        clear WP;
        
end

%% Mky / Exp 
for disp=1
    
    S.PnltCurrent.row       = S.PnltMech.row;
    S.PnltCurrent.column    = S.PnltMech.column;
   
    %%%%%%%%%%%%%%%%%%%%%%% Mky
	WP.name = 'Mky Monkey#';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type =       'Edit';          
        WP.row =        S.PnltCurrent.row;         
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text = {	'RIHGT or LEFT hemesphere',...
                    'Animal ID'};
        WP.tip = WP.text; 
        WP.inputValue = {   TP.D.Mky.Side,...
                            TP.D.Mky.ID};    
        WP.inputFormat = {'%s','%s'};
        WP.inputEnable = {'on','on'};
        Panelette(S, WP, 'TP');    
        TP.UI.H.hMky_Side_Edit =    TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};
        TP.UI.H.hMky_ID_Edit =      TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
        set(TP.UI.H.hMky_Side_Edit,	'tag', 'hMky_Side_Edit');
        set(TP.UI.H.hMky_ID_Edit,   'tag', 'hMky_ID_Edit');
        clear WP;    
        
	WP.name = 'Exp AngleArm';
        WP.handleseed = 'TP.UI.H0.Panelette';   
        WP.type =       'Edit';           
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text = {	'',...
                    'obj arm turned ?? degree counter-clockwise from upright orientation'};
        WP.tip = {	'',...
                    'obj arm turned ?? degree counter-clockwise from upright orientation'}; 
        WP.inputValue = {   NaN,...
                            TP.D.Exp.AngleArm};    
        WP.inputFormat = {'','%2.0f'};
        WP.inputEnable = {'inactive','on'};
        Panelette(S, WP, 'TP');    
        TP.UI.H.hExp_AngleArm_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
        set(TP.UI.H.hExp_AngleArm_Edit,	'tag', 'hExp_AngleArm_Edit');
        clear WP;        

    %%%%%%%%%%%%%%%%%%%%%%% Exp
	WP.name = 'Exp Est X&Y';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type =       'Edit';           
        WP.row =        S.PnltCurrent.row;         
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text =   {	'Estimated Y position, (um), rostral-caudal',...
                        'Estimated X position, (um), dorsal-ventral'};
        WP.tip =    {	'Estimated Y position, define as rostral-caudal direction, in um',...
                        'Estimated X position, define as dorsal-ventral direction, in um'}; 
        WP.inputValue = {   TP.D.Exp.Mech.EstY,...
                            TP.D.Exp.Mech.EstX};    
        WP.inputFormat = {'%4.0f','%4.0f'};
        WP.inputEnable = {'on','on'};
        Panelette(S, WP, 'TP');    
        TP.UI.H.hExp_Mech_EstY_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};
        TP.UI.H.hExp_Mech_EstX_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
        set(TP.UI.H.hExp_Mech_EstY_Edit,	'tag', 'hExp_Mech_EstY_Edit');
        set(TP.UI.H.hExp_Mech_EstX_Edit,	'tag', 'hExp_Mech_EstX_Edit');
        clear WP;
        
%    	WP.name = 'Exp LensCfg';
%         WP.handleseed = 'TP.UI.H0.Panelette';
%         WP.type = 'RockerSwitch';
%         WP.row      = S.PnltCurrent.row;
%         WP.column   = S.PnltCurrent.column;
%             S.PnltCurrent.column = S.PnltCurrent.column + 1;
%         WP.text = { 'Obj & Comp Lens Configuration'};
%         WP.tip = {'\n2D raster = 2D diagonal raster scanning\n3D sweep = 3D diagonal raster scanning across multi-layers'};
%         WP.inputOptions = {'10x + 1000mm','25x + 1000mm', '25x + 500mm'};
%         WP.inputDefault = 1; % TP.D.Exp.BCD.ScanModeNum; unfinished
%         Panelette(S, WP, 'TP'); 
%         TP.UI.H.hExp_Mech_LensCfg_Rocker = TP.UI.H0.Panelette{WP.row,WP.column}.hRocker{1};
%         htemp = get(TP.UI.H.hExp_Mech_LensCfg_Rocker,'children');
%         for j = 1:length(htemp)
%             set(htemp(j),'tag','hExp_BCD_Scan_Mode_Rocker');
%         end
%         clear WP;
        
   WP.name = 'Exp Cameras';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type = 'MomentarySwitch'; 
        WP.row =        S.PnltCurrent.row;         
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text = { 'Animnal monitoring',   'Wide field surface image from the CCD'};
        WP.tip = {   'Monitor animal''s condition', 'To Capture the Cortical Surface Image for current "Exp"'};
        WP.inputEnable = {'on','on'};
        Panelette(S, WP, 'TP');
        TP.UI.H.hExp_WF1_Momentary = TP.UI.H0.Panelette{WP.row,WP.column}.hMomentary{1}; 
        TP.UI.H.hExp_WF2_Momentary = TP.UI.H0.Panelette{WP.row,WP.column}.hMomentary{2}; 
        set(TP.UI.H.hExp_WF1_Momentary,	'Tag',      'hExp_WF1_Momentary');
        set(TP.UI.H.hExp_WF2_Momentary,	'Tag',      'hExp_WF2_Momentary');
        set(TP.UI.H.hExp_WF1_Momentary,	'UserData', 1);
        set(TP.UI.H.hExp_WF2_Momentary,	'UserData', 2);
        clear WP;
        
	WP.name = 'Exp Z0_SM1Z';
        WP.handleseed = 'TP.UI.H0.Panelette';   
        WP.type =       'Edit';           
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text = {	''...
                    'Z reading # on SM1Z @ the cortex surface level'};
        WP.tip = {	''...
                    'Z reading # on SM1Z @ the cortex surface level'};
        WP.inputValue = {   NaN,...
                            TP.D.Exp.Mech.Z0_SM1Z};    
        WP.inputFormat = {'','%3.0f'};
        WP.inputEnable = {'inactive','on'};
        Panelette(S, WP, 'TP');    
        TP.UI.H.hExp_Mech_Z0_SM1Z_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
        set(TP.UI.H.hExp_Mech_Z0_SM1Z_Edit,	'tag', 'hExp_Mech_Z0_SM1Z_Edit');
        clear WP;
        
	WP.name = 'Exp Zs_SM1Z';
        WP.handleseed = 'TP.UI.H0.Panelette';   
        WP.type =       'Edit';           
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text = {	'Estimated Z depth, (um), superfacial-deep',...
                    'Z reading # on SM1Z @ this recording level'};
        WP.tip = {	'Estimated Z depth, (um), define as superfacial-deep direction, in um',...
                    'Z reading # on SM1Z @ this recording level'}; 
        WP.inputValue = {   TP.D.Exp.Mech.EstZ,...
                            TP.D.Exp.Mech.Zs_SM1Z};    
        WP.inputFormat = {'%4.0f','%2.0f'};
        WP.inputEnable = {'inactive','on'};
        Panelette(S, WP, 'TP');    
        TP.UI.H.hExp_Mech_EstZ_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};
        TP.UI.H.hExp_Mech_Zs_SM1Z_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
        set(TP.UI.H.hExp_Mech_EstZ_Edit,	'tag', 'hExp_Mech_EstZ_Edit');
     	set(TP.UI.H.hExp_Mech_Zs_SM1Z_Edit,	'tag', 'hExp_Mech_Zs_SM1Z_Edit');
        clear WP;         
end

%% Exp.BCD
for disp=1

    S.PnltCurrent.row       = S.PnltBCD.row;
    S.PnltCurrent.column    = S.PnltBCD.column;
           
 	WP.name = 'BCD Scan.Mode';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type = 'RockerSwitch';
        WP.row      = S.PnltCurrent.row;
        WP.column   = S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text = { '2D or 3D,Random Access or Raster'};
        WP.tip = {'2D random = 2D random access jumping scanning among pixels\n2D raster = 2D diagonal raster scanning\n3D sweep = 3D diagonal raster scanning across multi-layers'};
        WP.inputOptions = { '2D random',    '2D raster',    '3D raster'};
        WP.inputEnable = {  'inactive',     'inactive',     'inactive'};
        WP.inputDefault = TP.D.Exp.BCD.ScanModeNum;
        Panelette(S, WP, 'TP'); 
        TP.UI.H.hExp_BCD_Scan_Mode_Rocker = TP.UI.H0.Panelette{WP.row,WP.column}.hRocker{1};
       
        set(TP.UI.H.hExp_BCD_Scan_Mode_Rocker, 'tag', 'hExp_BCD_Scan_Mode_Rocker');
%         htemp = get(TP.UI.H.hExp_BCD_Scan_Mode_Rocker,'children'); 
%         for j = 1:length(htemp)
%             set(htemp(j),'tag','hExp_BCD_Scan_Mode_Rocker');
%         end;
        clear WP;
    
	WP.name = 'BCD Scan.Scale1';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type = 'Edit';           
        WP.row      = S.PnltCurrent.row;
        WP.column   = S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text = {	'# of PIXELS scanned per axis (pixels)',...
                    '# of SAMPLES on 6115 per pixel (1sample = .1us)'};
        WP.tip = {	'# of PIXELS scanned per axis (pixels)',...
                    '# of SAMPLES on 6115 per pixel (1sample = .1us)'};
        WP.inputValue = {   TP.D.Exp.BCD.ScanNumPixlPerAxis,...
                            TP.D.Exp.BCD.ImageNumSmplPerPixl}; 
        WP.inputFormat = {'%d','%d'};
        WP.inputEnable = {'on','on'};
        Panelette(S, WP, 'TP');
        TP.UI.H.hExp_BCD_Scan_NumPixlPerAxis_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};
        TP.UI.H.hExp_BCD_Image_NumSmplPerPixl_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
        set(TP.UI.H.hExp_BCD_Scan_NumPixlPerAxis_Edit, 'tag', 'hExp_BCD_Scan_NumPixlPerAxis_Edit');
        set(TP.UI.H.hExp_BCD_Image_NumSmplPerPixl_Edit, 'tag', 'hExp_BCD_Scan_NumSmplPerPixl_Edit');
        clear WP;
    
	WP.name = 'BCD Scan.Scale2';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type = 'Edit';           
        WP.row      = S.PnltCurrent.row;
        WP.column   = S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;  
        WP.text = {	'Layer spacing, in um, within z+-50um',...
                    '# of LAYERS per volume scan (layers)'};
        WP.tip = {	'Layer spacing, in um, within z+-50um',...
                    '# of LAYERS per volume scan (layers)'};
        WP.inputValue = {   TP.D.Exp.BCD.ScanLayrSpacingInZ,...
                            TP.D.Exp.BCD.ScanNumLayrPerVlme};
        WP.inputFormat = {'%d','%d'};
        WP.inputEnable = {'inactive','inactive'};
        Panelette(S, WP, 'TP');          
        TP.UI.H.hExp_BCD_Scan_LayrSpacingInZ_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};  
        TP.UI.H.hExp_BCD_Scan_NumLayrPerVlme_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
        set(TP.UI.H.hExp_BCD_Scan_LayrSpacingInZ_Edit, 'tag', 'hExp_BCD_Scan_LayrSpacingInZ_Edit');
        set(TP.UI.H.hExp_BCD_Scan_NumLayrPerVlme_Edit, 'tag', 'hExp_BCD_Scan_NumLayrPerVlme_Edit');
        clear WP;
    
	WP.name = 'BCD Scan.Speed';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type = 'Edit';           
        WP.row      = S.PnltCurrent.row;
        WP.column   = S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;    
        WP.text = {	'Volume Time \n(in Sec)',...
                    'Volume Rate \n(in Hz)'};
        WP.tip = {	'Update Time \n(in 6115 samples, 1sample = 0.1us)',...
                    'Volume Rate \n(in Hz)'};
        WP.inputValue = {   TP.D.Exp.BCD.ScanVolumeTime,...
                            TP.D.Exp.BCD.ScanVolumeRate};
        WP.inputFormat = {'%d','%d'};    
        WP.inputEnable = {'inactive','inactive'};
        Panelette(S, WP, 'TP');            
        TP.UI.H.hExp_BCD_Scan_VolumeTime_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};
        TP.UI.H.hExp_BCD_Scan_VolumeRate_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
        set(TP.UI.H.hExp_BCD_Scan_VolumeTime_Edit, 'tag', 'hExp_BCD_Scan_VolumeTime_Edit');
        set(TP.UI.H.hExp_BCD_Scan_VolumeRate_Edit, 'tag', 'hExp_BCD_Scan_VolumeRate_Edit');
        clear WP;   

	WP.name = 'BCD Updt.Scale1';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type = 'Edit';           
        WP.row      = S.PnltCurrent.row;
        WP.column   = S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text = {	'# of VOLUMES per update',...
                    '# of UPDATES per volume scanned'};
        WP.tip = {	'# of VOLUMES per update',...
                    '# of UPDATES per volume scanned'};
        WP.inputValue = {   TP.D.Exp.BCD.ImageNumVlmePerUpdt,...
                            TP.D.Exp.BCD.ImageNumUpdtPerVlme};
        WP.inputFormat = {'%d','%d'};
        WP.inputEnable = {'inactive','on'};
        Panelette(S, WP, 'TP');          
        TP.UI.H.hExp_BCD_Image_NumVlmePerUpdt_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};
        TP.UI.H.hExp_BCD_Image_NumUpdtPerVlme_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
        set(TP.UI.H.hExp_BCD_Image_NumUpdtPerVlme_Edit, 'tag', 'hExp_BCD_Image_NumUpdtPerVlme_Edit');
        set(TP.UI.H.hExp_BCD_Image_NumVlmePerUpdt_Edit, 'tag', 'hExp_BCD_Image_NumUpdtPerVlme_Edit');
        clear WP;
    
    WP.name = 'BCD Updt.Speed';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type = 'Edit';           
        WP.row      = S.PnltCurrent.row;
        WP.column   = S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;    
        WP.text = {	'Update Time \n(in Sec)',...
                    'Update Rate \n(in Hz)'};
        WP.tip = {	'Update Time \n(in Sec)',...
                    'Update Rate \n(in Hz)'};
        WP.inputValue = {   TP.D.Exp.BCD.ImageUpdateTime,...
                            TP.D.Exp.BCD.ImageUpdateRate};
        WP.inputFormat = {'%d','%d'};    
        WP.inputEnable = {'inactive','inactive'};
        Panelette(S, WP, 'TP');            
        TP.UI.H.hExp_BCD_Image_UpdateTime_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};
        TP.UI.H.hExp_BCD_Image_UpdateRate_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
        set(TP.UI.H.hExp_BCD_Image_UpdateTime_Edit, 'tag', 'hExp_BCD_Image_UpdateTime_Edit');
        set(TP.UI.H.hExp_BCD_Image_UpdateRate_Edit, 'tag', 'hExp_BCD_Image_UpdateRate_Edit');
        clear WP;      
        
	WP.name = 'BCD ImageEnable';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type = 'RockerSwitch';	
        WP.row      = S.PnltCurrent.row;
        WP.column   = S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text = { 'Image Enable & Data Logging'};
        WP.tip = {  'Image Enable & Data Logging ON/OFF'};
        WP.inputOptions = { 'ON',       'OFF',      ''};
        WP.inputEnable = {  'inactive',	'inactive',	'off'};
        WP.inputDefault = 2-TP.D.Exp.BCD.ImageEnable;
        Panelette(S, WP, 'TP');
        TP.UI.H.hExp_BCD_ImageEnable_Rocker = TP.UI.H0.Panelette{WP.row,WP.column}.hRocker{1};
        set(TP.UI.H.hExp_BCD_ImageEnable_Rocker,	'tag', 'hExp_BCD_ImageEnable_Rocker');
        clear WP; 
        
  	WP.name = 'BCD Commit';  
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type =       'RockerSwitch';	
        WP.row =        S.PnltCurrent.row;         
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text = {     'Commit the BCD & NI-DAQ'};
        WP.tip = {[     'Commit BCD & scanning parameters\n',...
                        'Generate the scan pattern\n',...
                        'Allocate memories for D.Trl\n',...
                        'Commit NI-DAQ tasks']};
        WP.inputOptions = { 'Commit',   'Uncommit',     ''};        
        WP.inputEnable = {  'on',       'inactive',     'inactive'};
        WP.inputDefault = 2-TP.D.Exp.BCD.Committed;
        Panelette(S, WP, 'TP');
        TP.UI.H.hExp_BCD_Commit_Rocker = TP.UI.H0.Panelette{WP.row,WP.column}.hRocker{1}; 
        set(TP.UI.H.hExp_BCD_Commit_Rocker,	'tag', 'hExp_BCD_Commit_Rocker');
        clear WP;
end

%% Ses
for disp=1

    S.PnltCurrent.row       = S.PnltSes.row;
    S.PnltCurrent.column    = S.PnltSes.column;
    	
    WP.name = 'Ses Load&Start';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type =       'MomentarySwitch'; 
        WP.row =        S.PnltCurrent.row;         
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text = { 'Load SOUND for the session',...
                    'START / STOP the session'};
        WP.tip = {	'This will load a sound file and setup an AO_6323 Task to play that sound,\n',...
                    'START / STOP the session' };
        WP.inputEnable = {'off', 'off'};
        Panelette(S, WP, 'TP');
        TP.UI.H.hSes_Load_Momentary =       TP.UI.H0.Panelette{WP.row,WP.column}.hMomentary{1}; 
        TP.UI.H.hSes_StartStop_Momentary =	TP.UI.H0.Panelette{WP.row,WP.column}.hMomentary{2};
        set(TP.UI.H.hSes_Load_Momentary,        'Tag', 'hSes_Load_Momentary');
        set(TP.UI.H.hSes_StartStop_Momentary,	'Tag', 'hSes_Start_Momentary');
        clear WP; 
        
 	WP.name = 'Ses TrlOrder';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type =       'RockerSwitch';	
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text = { 'Trial Order'};
        WP.tip = {  'Trial Order'};
        WP.inputOptions = {'Sequential',    'Randomized',   ''};
        WP.inputEnable = {  'on',           'on',           'off'};
        WP.inputDefault = 1;
        Panelette(S, WP, 'TP');
        TP.UI.H.hSes_TrlOrder_Rocker =      TP.UI.H0.Panelette{WP.row,WP.column}.hRocker{1};
        set(TP.UI.H.hSes_TrlOrder_Rocker,	'Tag',  'hSes_TrlOrder_Rocker');
        clear WP;        
        
  	WP.name = 'Ses CycleNum';
        WP.handleseed =	'TP.UI.H0.Panelette';
        WP.type =       'Edit';           
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;     
        WP.text = {	'Cycle Num Current (cycle)',...
                    'Cycle Num Total (cycle)'};
        WP.tip = {	'Cycle Num Current (cycle)',...
                    'Cycle Num Total (cycle)'};
        WP.inputValue = {   TP.D.Ses.Load.CycleNumCurrent,...
                            TP.D.Ses.Load.CycleNumTotal};
        WP.inputFormat = {'%d','%d'};    
        WP.inputEnable = {'inactive','on'};
        Panelette(S, WP, 'TP');    
        TP.UI.H.hSes_CycleNumCurrent_Edit =	TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};
        TP.UI.H.hSes_CycleNumTotal_Edit =	TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
        set(TP.UI.H.hSes_CycleNumCurrent_Edit,	'Tag', 'hSes_CycleNumCurrent_Edit');
        set(TP.UI.H.hSes_CycleNumTotal_Edit,	'Tag', 'hSes_CycleNumTotal_Edit');
        clear WP;      
    
	WP.name = 'Ses AddAtt';
        WP.handleseed =	'TP.UI.H0.Panelette';
        WP.type =       'Edit';           
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;     
        WP.text = {	'Additional Attenuations (dB)',...
                    'Additional Attenuation Number Total'};
        WP.tip = {	'Additional Attenuations (dB)',...
                    'Additional Attenuation Number Total'};
        WP.inputValue = {   TP.D.Ses.Load.AddAtts,...
                            TP.D.Ses.Load.AddAttNumTotal};
        WP.inputFormat = {'%d','%d'};    
        WP.inputEnable = {'on','inactive'};
        Panelette(S, WP, 'TP');    
        TP.UI.H.hSes_AddAtts_Edit =         TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};
        TP.UI.H.hSes_AddAttNumTotal_Edit =	TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
        set(TP.UI.H.hSes_AddAtts_Edit,          'Tag', 'hSes_AddAtts_Edit');
        set(TP.UI.H.hSes_AddAttNumTotal_Edit,	'Tag', 'hSes_AddAttNumTotal_Edit');
        clear WP;    	

	WP.name = 'Ses SoundTime';
        WP.handleseed =	'TP.UI.H0.Panelette';
        WP.type =       'Edit';           
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;     
        WP.text = {	'',...
                    'Sound Duration Total (s)'};
        WP.tip = {	'',...
                    'Cycle Duration Total (s)'};
        WP.inputValue = {   0,...
                            TP.D.Ses.Load.SoundDurTotal};
        WP.inputFormat = {'','%5.1f'};    
        WP.inputEnable = {'inactive','inactive'};
        Panelette(S, WP, 'TP');    
        TP.UI.H.hSes_SoundDurTotal_Edit =	TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2}; 
        set(TP.UI.H.hSes_SoundDurTotal_Edit,	'Tag', 'hSes_SoundDurTotal_Edit');
        clear WP;   
        
    WP.name = 'Ses CycleTime';
        WP.handleseed =	'TP.UI.H0.Panelette';
        WP.type =       'Edit';           
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;     
        WP.text = {	'Cycle Duration Current (s)',...
                    'Cycle Duration Total (s)'};
        WP.tip = {	'Cycle Duration Current (s)',...
                    'Cycle Duration Total (s)'};
        WP.inputValue = {   TP.D.Ses.Load.CycleDurCurrent,...
                            TP.D.Ses.Load.CycleDurTotal};
        WP.inputFormat = {'%5.1f','%5.1f'};    
        WP.inputEnable = {'inactive','inactive'};
        Panelette(S, WP, 'TP');    
        TP.UI.H.hSes_CycleDurCurrent_Edit =	TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};
        TP.UI.H.hSes_CycleDurTotal_Edit =	TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2}; 
        set(TP.UI.H.hSes_CycleDurCurrent_Edit,	'Tag', 'hSes_CycleDurCurrent_Edit');
        set(TP.UI.H.hSes_CycleDurTotal_Edit,	'Tag', 'hSes_CycleDurTotal_Edit');
        clear WP;   
        
  	WP.name = 'Ses Time';
        WP.handleseed =	'TP.UI.H0.Panelette';
        WP.type =       'Edit';           
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;     
        WP.text = {	'Session Current Time (s)',...
                    'Session Duraion (s)'};
        WP.tip = {	'Session Current Time (s)',...
                    'Session Duraion (s)'};
        WP.inputValue = {   TP.D.Ses.Load.DurCurrent,...
                            TP.D.Ses.Load.DurTotal};
        WP.inputFormat = {'%d','%d'};    
        WP.inputEnable = {'inactive','inactive'};
        Panelette(S, WP, 'TP');    
        TP.UI.H.hSes_DurCurrent_Edit =	TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};
        TP.UI.H.hSes_DurTotal_Edit =	TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
        set(TP.UI.H.hSes_DurCurrent_Edit,	'Tag', 'hSes_DurCurrent_Edit');
        set(TP.UI.H.hSes_DurTotal_Edit,     'Tag', 'hSes_DurTotal_Edit');        
        clear WP; 
        
	WP.name = 'Ses ScanScheme'; 
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type =       'RockerSwitch';   
        WP.row =        S.PnltCurrent.row;         
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text =   {   'Search / Record / XBlaster'};
        WP.tip =    {[  'Search: "FOCUS i" as in ScanImage = \n'...
                        '   Started and \n'...
                        '   Triggered Immediately with GUI "Start" & the Internal trigger, \n'...
                        '   Stopped with GUI "Stop" (no auto timeout) \n\n',...
                        'Record: "GRAB i" as in ScanImage  =  \n'...
                        '   Started with GUI "Start", should be following sound loading first, \n'...
                        '   Triggered Immediately with GUI "Start" & the Internal trigger, \n'....
                        '       Triggered together with the AO_6323 task for playing sounds \n'...
                        '   Stopped with either GUI "stop" or PC counted time out\n\n',...
                        'XBlaster: "LOOP e" as in ScanImage =  \n',...
                        '   Start with GUI "Start", and then wait for XBlaster3 control \n'...
                        '   Triggered with real External trigger rising edge, \n'...
                        '       Stopped, and re-Started with real external trigger falling edge or auto time out, \n'... 
                        '   Fully Stopped or Cancelled with GUI "Stop"']};
        WP.inputOptions = { 'Search',   'Record',   'XBlaster'};
        WP.inputEnable = {  'on',       'on',       'inactive'};
        WP.inputDefault = 1;
        Panelette(S, WP, 'TP');
        TP.UI.H.hSes_ScanScheme_Rocker = TP.UI.H0.Panelette{WP.row,WP.column}.hRocker{1};
        set(TP.UI.H.hSes_ScanScheme_Rocker,	'Tag',  'hSes_ScanScheme_Rocker');
        clear WP;         
end

%% Trl
for disp=1

    S.PnltCurrent.row       = S.PnltTrl.row;
    S.PnltCurrent.column    = S.PnltTrl.column;
    
      	WP.name = 'Trl Number';
        WP.handleseed =	'TP.UI.H0.Panelette';
        WP.type =       'Edit';           
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;     
        WP.text = {	'Current Trial Number',...
                    'Total Trial Number / Cycle'};
        WP.tip = {	'Current Trial Number',...
                    'Total Trial Number / Cycle'};
        WP.inputValue = {   TP.D.Trl.Load.NumCurrent,...
                            TP.D.Trl.Load.NumTotal};
        WP.inputFormat = {'%d','%d'};    
        WP.inputEnable = {'inactive','inactive'};
        Panelette(S, WP, 'TP');    
        TP.UI.H.hTrl_NumCurrent_Edit =	TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};
        TP.UI.H.hTrl_NumTotal_Edit =	TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
        set(TP.UI.H.hTrl_NumCurrent_Edit,	'Tag', 'hTrl_NumCurrent_Edit');
        set(TP.UI.H.hTrl_NumTotal_Edit,     'Tag', 'hTrl_NumTotal_Edit');
        clear WP;  
        
	WP.name = 'Trl Stim #';
        WP.handleseed =	'TP.UI.H0.Panelette';
        WP.type =       'Edit';           
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;     
        WP.text = {	'CURRENT Trial Stim #',...
                    'NEXT Trial Stim #'};
        WP.tip = {	'CURRENT Trial Stim #',...
                    'NEXT Trial Stim #'};
        WP.inputValue = {   TP.D.Trl.Load.StimNumCurrent,...
                            TP.D.Trl.Load.StimNumNext};
        WP.inputFormat = {'%d','%d'};    
        WP.inputEnable = {'inactive','inactive'};
        Panelette(S, WP, 'TP');    
        TP.UI.H.hTrl_StimNumCurrent_Edit =	TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};
        TP.UI.H.hTrl_StimNumNext_Edit =     TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
        set(TP.UI.H.hTrl_StimNumCurrent_Edit,	'Tag', 'hTrl_StimNumCurrent_Edit');
        set(TP.UI.H.hTrl_StimNumNext_Edit,      'Tag', 'hTrl_StimNumNext_Edit');
        clear WP;  
        
	WP.name = 'Trl Sound #';
        WP.handleseed =	'TP.UI.H0.Panelette';
        WP.type =       'Edit';           
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;     
        WP.text = {	'Current Sound #',...
                    'Total Sound #'};
        WP.tip = {	'Current Sound #',...
                    'Total Sound #'};
        WP.inputValue = {   TP.D.Trl.Load.SoundNumCurrent,...
                            TP.D.Trl.Load.SoundNumTotal};
        WP.inputFormat = {'%s','%d'};    
        WP.inputEnable = {'inactive','inactive'};
        Panelette(S, WP, 'TP');    
        TP.UI.H.hTrl_SoundNumCurrent_Edit =	TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};
        TP.UI.H.hTrl_SoundNumTotal_Edit =	TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
        set(TP.UI.H.hTrl_SoundNumCurrent_Edit,	'Tag', 'hTrl_SoundNumCurrent_Edit');
        set(TP.UI.H.hTrl_SoundNumTotal_Edit,	'Tag', 'hTrl_SoundNumTotal_Edit');
        clear WP;  	
        
    WP.name = 'Trl SoundFeature';
        WP.handleseed =	'TP.UI.H0.Panelette';
        WP.type =       'Edit';           
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;     
        WP.text = {	'Sound Design Attenuation (dB)',...
                    'CURRENT Sound Name'};
        WP.tip = {	'Sound Design Attenuation (dB)',...
                    'CURRENT Sound Name'};
        WP.inputValue = {   TP.D.Trl.Load.AttDesignCurrent,...
                            TP.D.Trl.Load.SoundNameCurrent};
        WP.inputFormat = {'%5.1f','%d'};    
        WP.inputEnable = {'inactive','inactive'};
        Panelette(S, WP, 'TP');    
        TP.UI.H.hTrl_AttDesignCurrent_Edit =	TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};
        TP.UI.H.hTrl_SoundNameCurrent_Edit =	TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
        set(TP.UI.H.hTrl_SoundNameCurrent_Edit, 'FontSize', 9);
        set(TP.UI.H.hTrl_AttDesignCurrent_Edit,	'Tag', 'hTrl_AttDesignCurrent_Edit');
        set(TP.UI.H.hTrl_SoundNameCurrent_Edit,	'Tag', 'hTrl_SoundNameCurrent_Edit');
        clear WP; 
        
	WP.name = 'Trl Attenuation';
        WP.handleseed =	'TP.UI.H0.Panelette';
        WP.type =       'Edit';           
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;     
        WP.text = {	'Additional Attenuation (dB)',...
                    'Total Attenuation (dB)'};
        WP.tip = {	'Additional Attenuation (dB)',...
                    'Total Attenuation (dB)'};
        WP.inputValue = {  	TP.D.Trl.Load.AttAddCurrent,...
                            TP.D.Trl.Load.AttCurrent};
        WP.inputFormat = {'%5.1f','%5.1f'};    
        WP.inputEnable = {'inactive','inactive'};
        Panelette(S, WP, 'TP');    
        TP.UI.H.hTrl_AttAddCurrent_Edit =	TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};
        TP.UI.H.hTrl_AttCurrent_Edit =      TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
        set(TP.UI.H.hTrl_AttAddCurrent_Edit,	'Tag', 'hTrl_AttAddCurrent_Edit');
        set(TP.UI.H.hTrl_AttCurrent_Edit,       'Tag', 'hTrl_AttCurrent_Edit');
        clear WP;  
        
  	WP.name = 'Trl Time';
        WP.handleseed =	'TP.UI.H0.Panelette';
        WP.type =       'Edit';           
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;     
        WP.text = {	'Trial Current Time',...
                    'Trial Duraion'};
        WP.tip = {	'Trial Current Time',...
                    'Trial Duraion'};
        WP.inputValue = {   TP.D.Trl.Load.DurCurrent,...
                            TP.D.Trl.Load.DurTotal};
        WP.inputFormat = {'%d','%d'};    
        WP.inputEnable = {'inactive','inactive'};
        Panelette(S, WP, 'TP');    
        TP.UI.H.hTrl_DurCurrent_Edit =	TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};
        TP.UI.H.hTrl_DurTotal_Edit =	TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
        set(TP.UI.H.hTrl_DurCurrent_Edit,	'Tag', 'hTrl_DurCurrent_Edit');
        set(TP.UI.H.hTrl_DurTotal_Edit,     'Tag', 'hTrl_DurTotal_Edit');
        clear WP;   
        
 	WP.name = 'Trl Start/Stop';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type =       'RockerSwitch';   
        WP.row =        S.PnltCurrent.row;         
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text =   {   'Scan Start/Stop  Switch'};
        WP.tip =    {   'Start / Stop the Scanning & Imaging Task'};
        WP.inputOptions = { 'Triggered',    'Started',    'Stopped'};
        WP.inputEnable = {  'inactive',     'inactive', 'inactive'};
        WP.inputDefault = 3 - TP.D.Trl.State;
        Panelette(S, WP, 'TP');
        TP.UI.H.hTrl_StartTrigStop_Rocker = TP.UI.H0.Panelette{WP.row,WP.column}.hRocker{1};
        set(TP.UI.H.hTrl_StartTrigStop_Rocker,	'Tag',  'hTrl_StartTrigStop_Rocker');
        clear WP; 
        
end

%% Mon.Image
for disp=1
    
    S.PnltCurrent.row       = S.PnltMonImage.row;
    S.PnltCurrent.column    = S.PnltMonImage.column;
    
	WP.name = 'Mon PMT.HV';
        WP.handleseed =	'TP.UI.H0.Panelette';
        WP.type =       'RockerSwitch';   
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text =       {'PMT High Voltage ON/OFF'};
        WP.tip =        {  'H = Turn the PMT HV ON\nL = Turn the PMT HV ON'};
        WP.inputOptions = { 'ON',   'OFF',  ''};
        WP.inputEnable = {  'on',   'on',   'off'};
        WP.inputDefault =   2 - TP.D.Mon.PMT.PMTctrl;
        Panelette(S, WP, 'TP');
        TP.UI.H.hMon_PMT_PMTctrl_Rocker = TP.UI.H0.Panelette{WP.row,WP.column}.hRocker{1};
        clear WP;
    
	WP.name = 'Mon PMT.Cooling';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type =       'ToggleSwitch';   
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1; 
        WP.text =   {'Fan\nOFF/ON','Peltier\nOFF/ON'};
        WP.tip =    {   'H = Turn the fan OFF\nL = Turn the fan ON',...
                        'H = Turn the cooling ON\nL = Turn the cooling OFF'};
        WP.inputOptions =   {'OFF','ON','';'OFF','ON',''};
        WP.inputDefault =   [   2 - TP.D.Mon.PMT.FANctrl,...
                                2 - TP.D.Mon.PMT.PELctrl];
        Panelette(S, WP, 'TP'); 
        TP.UI.H.hMon_PMT_FANctrl_Toggle = TP.UI.H0.Panelette{WP.row,WP.column}.hToggle{1};
        TP.UI.H.hMon_PMT_PELctrl_Toggle = TP.UI.H0.Panelette{WP.row,WP.column}.hToggle{2};
        clear WP;
    
	WP.name = 'Mon PMT.Status';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type =       'LED';            
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;  
        WP.text =   { 'PMT','','M9012',''};
        WP.tip =    {   'H = PMT HV is ON\nFast Flashing (2Hz) = PMT HV OFF & Cooled\nSlow Flashing (1/2Hz) = PMT HV OFF & Cooling\nL = Both PMT HV and Cooling are OFF',...
                        '',...
                        'H = M9012 Power Supply is ON\nL = M9012 Power Supply is OFF',...
                        ''};
        Panelette(S, WP, 'TP');        
        TP.UI.H.hMon_PMT_M9012_LED =        TP.UI.H0.Panelette{WP.row,WP.column}.hLED{3};
        TP.UI.H.hMon_PMT_Status_LED =       TP.UI.H0.Panelette{WP.row,WP.column}.hLED{1};
        clear WP;
    
	WP.name = 'Mon PMT.Error';
        WP.handleseed =	'TP.UI.H0.Panelette';
        WP.type =       'LED';          	
        WP.row =        S.PnltCurrent.row;
        WP.column   = S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text =   {   '2 bright','2 hot','Error',''};
        WP.tip =    {   'H = Too bright, overload protection is on\nL = No overload error',...
                        'H = Too hot, overheat protection is on\nL = No overheat error',...
                        'H = PMT Overload Protection is ON\nF =  PMT Cooling Error\nL = No error\n Tip: overload, turn off M9012 power and start again\n Tip: overheat, eliminate the heat cause, turn off M9012 power and start again',...
                        ''};
        Panelette(S, WP, 'TP');    
        TP.UI.H.hMon_PMT_Error_LED =        TP.UI.H0.Panelette{WP.row,WP.column}.hLED{3};
        TP.UI.H.hMon_PMT_2Bright_LED =    TP.UI.H0.Panelette{WP.row,WP.column}.hLED{1};
        TP.UI.H.hMon_PMT_2Hot_LED =       TP.UI.H0.Panelette{WP.row,WP.column}.hLED{2};
    
        % prepare D's line names and handles 
        for i = 1:TP.D.Sys.NI.Chan_DI_PMT_Status{6}
            str = strcat(   'TP.D.Sys.NI.Chan_DI_PMT_Status{7}{i}= TP.UI.H.hMon_PMT_',...
                            TP.D.Sys.NI.Chan_DI_PMT_Status{3}{i},'_LED;');
            eval(str);
        end
        clear WP;
    
	WP.name = 'Mon PMT.GainCtrl';
        WP.handleseed =	'TP.UI.H0.Panelette';
        WP.type =       'Potentiometer';	
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;  
        WP.text = 	{   'PMT Gain Control\n(0-0.9V)'};
        WP.tip =    {   'PMT Gain Control\n(0-0.9V)'};
        WP.inputValue =     TP.D.Mon.PMT.CtrlGainValue;
        WP.inputRange =     TP.D.Sys.PMT.CtrlGainRange;
        WP.inputSlideStep=  TP.D.Sys.PMT.CtrlGainSteps/...
            (TP.D.Sys.PMT.CtrlGainRange(2)-TP.D.Sys.PMT.CtrlGainRange(1));
        Panelette(S, WP, 'TP');
        TP.UI.H.hMon_PMT_CtrlGainValue_PotenSlider = TP.UI.H0.Panelette{WP.row,WP.column}.hSlider{1};
        TP.UI.H.hMon_PMT_CtrlGainValue_PotenEdit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};
        clear WP;
       
	WP.name = 'Mon PMT.GainMont';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type =       'Edit';           
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;   
        WP.text =   {   'PMT #1 Gain Noise (mV)', 'PMT #1 Gain Monitor (Volt)'};
        WP.tip =    {   'PMT #1 Gain Noise (mV)', 'PMT #1 Gain Monitor (Volt)'};
        WP.inputValue =     {   TP.D.Mon.PMT.MontGainNoise,...
                                TP.D.Mon.PMT.MontGainValue};    
        WP.inputFormat =    {'%5.0f','%5.2f'};
        WP.inputEnable =    {'inactive','inactive'};
        Panelette(S, WP, 'TP');
        TP.UI.H.hMon_PMT_MontGainNoise_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};
        TP.UI.H.hMon_PMT_MontGainValue_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
        clear WP;
        
   	WP.name = 'Mon Display';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type =       'RockerSwitch';	
        WP.row      = S.PnltCurrent.row;
        WP.column   = S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text = { 'Display Mode'};
        WP.tip = {  'Image Display Mode'};
        WP.inputOptions = {	'Absolute', 'Relative', ''};
        WP.inputEnable = {  'on',       'on',       'inactive'};
        WP.inputDefault =   TP.D.Mon.Image.DisplayModeNum;
        Panelette(S, WP, 'TP');
        TP.UI.H.hMon_Image_DisplayMode_Rocker = TP.UI.H0.Panelette{WP.row,WP.column}.hRocker{1};
        set(TP.UI.H.hMon_Image_DisplayMode_Rocker,	'Tag',  'hMon_Image_DisplayMode_Rocker');
        clear WP;
        
end

%% Mon.Power
for disp=1
    
    S.PnltCurrent.row       = S.PnltMonPower.row;
    S.PnltCurrent.column    = S.PnltMonPower.column;
    
	WP.name = 'Power AOD Ctrl';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type =       'Potentiometer';  
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text =   {   'AOD X&Y Scanning Amp Ctrl\n(0-5V)'};
        WP.tip =    {   'AOD X&Y Scanning Amp Ctrl\n(0-5V)'};  
        WP.inputValue =     TP.D.Mon.Power.AOD_CtrlAmpValue;
        WP.inputRange =     TP.D.Sys.Power.AOD_CtrlAmpRange;
        WP.inputSlideStep=  TP.D.Sys.Power.AOD_CtrlAmpSteps/...
            (TP.D.Sys.Power.AOD_CtrlAmpRange(2)-TP.D.Sys.Power.AOD_CtrlAmpRange(1));
        Panelette(S, WP, 'TP');
        TP.UI.H.hMon_Power_AOD_CtrlAmpValue_PotenSlider = TP.UI.H0.Panelette{WP.row,WP.column}.hSlider{1};
        TP.UI.H.hMon_Power_AOD_CtrlAmpValue_PotenEdit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};
        clear WP;
       
	WP.name = 'Power X Monitor';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type =       'Edit';           
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text =   {   'AOD X Axis Scanning Noise (mV)','AOD X Axis Scanning Amplitude (Volt)'};
        WP.tip =    {   'AOD X Axis Scanning Noise (mV)','AOD X Axis Scanning Amplitude (Volt)'};
        WP.inputValue = {   TP.D.Mon.Power.AOD_MontAmpNoise(1),...
                            TP.D.Mon.Power.AOD_MontAmpValue(1)};
        WP.inputFormat = {'%5.0f','%5.2f'};
        WP.inputEnable = {'inactive','inactive'};
        Panelette(S, WP, 'TP');
        TP.UI.H.hMon_Power_AOD_MontAmpNoiseX_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};  
        TP.UI.H.hMon_Power_AOD_MontAmpValueX_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
        clear WP;

	WP.name = 'Power Y Monitor';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type =       'Edit';           
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text =   {   'AOD Y Axis Scanning Noise (mV)','AOD Y Axis Scanning Amplitude (Volt)'};
        WP.tip =    {   'AOD Y Axis Scanning Noise (mV)','AOD Y Axis Scanning Amplitude (Volt)'};
        WP.inputValue = {	TP.D.Mon.Power.AOD_MontAmpNoise(2),...
                            TP.D.Mon.Power.AOD_MontAmpValue(2)};
        WP.inputFormat = {'%5.0f','%5.2f'};
        WP.inputEnable = {'inactive','inactive'};
        Panelette(S, WP, 'TP');
        TP.UI.H.hMon_Power_AOD_MontAmpNoiseY_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};  
        TP.UI.H.hMon_Power_AOD_MontAmpValueY_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
        clear WP;    

	WP.name = 'Power Predicted';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type =       'Edit';         	
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1; 
        WP.text =   {   'Laser Power \nMax Allowed\n@Cortex (mW)',...
                        'Laser Power Max\nat current angle\n@Cortex (mW)'};
        WP.tip =    {   'Laser Power Max Allowed @Cortex (mW)',...
                        'Laser Power when AOD@5V @Cortex (mW)'};
        WP.inputValue = {	TP.D.Mon.Power.PmaxCtxAllowed,...
                            TP.D.Mon.Power.PmaxAtCurAngle};
        WP.inputFormat = {'%5.1f','%5.1f'};
        WP.inputEnable = {'on','inactive'};
        Panelette(S, WP, 'TP');
        TP.UI.H.hMon_Power_PmaxCtxAllowed_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};  
        TP.UI.H.hMon.Power_PmaxAtCurAngle_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
        set(TP.UI.H.hMon_Power_PmaxCtxAllowed_Edit, 'Tag',  'hMon_Power_PmaxCtxAllowed_Edit');
        clear WP;      
    
	WP.name = 'Power Monitored';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type =       'Edit';         	
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;  
        WP.text =   {   'Laser Power \nInferred \n@Cortex (mW)',...
                        'Laser Power \nMeasured \n@S121C (mW)'};
        WP.tip =    {   'Laser Power Inferred @Cortex (mW)',...
                        'Laser Power Measured @S121C (mW)'};
        WP.inputValue = {	TP.D.Mon.Power.PinferredAtCtx,...
                            TP.D.Mon.Power.PmeasuredS121C};
        WP.inputFormat = {'%5.4f','%5.4f'};
        WP.inputEnable = {'inactive','inactive'};
        Panelette(S, WP, 'TP');
        TP.UI.H.hMon_Power_PinferredAtCtx_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};  
        TP.UI.H.hMon_Power_PmeasuredS121C_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
        clear WP; 
        
	WP.name = 'Power HWP';
        WP.handleseed = 'TP.UI.H0.Panelette';
        WP.type =       'Potentiometer';  
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1;
        WP.text =   {   'PRM1Z8 control angle, which rotates the HWP'};
        WP.tip =    {   'PRM1Z8 control angle, which rotates the HWP'};  
        WP.inputValue =     0;
        WP.inputRange =     TP.D.Sys.Power.HWP_RotAnglRange;
        WP.inputSlideStep=  TP.D.Sys.Power.HWP_RotAnglSteps/...
            (TP.D.Sys.Power.HWP_RotAnglRange(2)-TP.D.Sys.Power.HWP_RotAnglRange(1));
        Panelette(S, WP, 'TP');
        TP.UI.H.hMon_Power_HWP_CtrlAglValue_PotenSlider = TP.UI.H0.Panelette{WP.row,WP.column}.hSlider{1};
        TP.UI.H.hMon_Power_HWP_CtrlAglValue_PotenEdit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};
        clear WP;
        
end

% % create Edit panel 'Image Delays'
%     WP.handleseed = 'TP.UI.H0.Panelette';
%     WP.type = 'Edit';           WP.name = 'Image Delays';
%     WP.row      = S.PnltCurrent.row;
%     WP.column   = S.PnltCurrent.column;
%         S.PnltCurrent.column = S.PnltCurrent.column + 1;
%     WP.text = {	'Tdelay, samples to reach laser beam (1S=0.1us)',...
%                 'Ttrans, samples to go across laser beam (1S=0.1us)'};
%     WP.tip = {	'Tdelay, samples to reach laser beam (1S=0.1us)',...
%                 'Ttrans, samples to go across laser beam (1S=0.1us)'}; 
%     WP.inputValue = {   TP.D.Image.Tdelay,...
%                         TP.D.Image.Ttrans};    
%     WP.inputFormat = {'%5.0f','%5.0f'};
%     WP.inputEnable = {'inactive','inactive'};
%     Panelette(S, WP, 'TP');    
%     TP.UI.H.hImage_Tdelay_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{1};
%     TP.UI.H.hImage_Ttrans_Edit = TP.UI.H0.Panelette{WP.row,WP.column}.hEdit{2};
%     clear WP;
    




    