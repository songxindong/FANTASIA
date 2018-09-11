function msg = scanStarted
% This function is called by
%   (1) GUI "Start" press
%   (2) GUI_ScanStartTrigStop function
% and is the only function that controls the trial starting procedure
% takes ? s on T5810 @ 2015/1

%% State
global TP

%% Time & Flag, for Started
    TP.D.Trl.StartTrigStop =        1;    
    %   -3 = Timeout,       -2 = Stopping by GUI,   -1=Stopping by ExtTrig, 
    %   0 = Stopped,        1 = Started,            2 = Triggered
    TP.D.Trl.TimeStampStarted =     datestr(now, 'yy/mm/dd HH:MM:SS.FFF'); 
    TP.D.Trl.TimeStampBCDCom =      TP.D.Exp.BCD.CommitedTimeStamp; 
          
%% TP.D Initialization / Reset & Stream File Openned
    % Setup Timing
    TP.D.Trl.Udone = 0;     TP.D.Trl.Vdone = 0;     TP.D.Trl.Tdone = 0;
    TP.D.Trl.Unum = 0;      TP.D.Trl.Vnum = 0;
    TP.D.Trl.PowerOverload = 0;  
        %% Check Up TP.D.Trl
        %%
        %%
    % Reset PowerOverload Color
    set(TP.UI.H.hMon_Power_PinferredAtCtx_Edit, 'ForegroundColor',  TP.UI.C.FG);
    set(TP.UI.H.hTrl_Tdone_Edit,                'string',           sprintf('%5.1f',TP.D.Trl.Tdone));

%% Imaging Data Allocation    
	if TP.D.Exp.BCD.ImageEnable  
        %% Clean Up TP.D.Trl.VS.
        %%
        %% Allocate Memories  
        %% MOVE THE FOLLOWING PART INTO TRL CTRL
        Vmax = floor( TP.D.Trl.Tmax4GB * TP.D.Exp.BCD.ScanVolumeRate);
        TP.D.Trl.VS.TimeStampUpdt =             zeros(Vmax,1);
        TP.D.Trl.VS.PMT_PMTctrl =               zeros(Vmax,1);
        TP.D.Trl.VS.PMT_FANctrl =               zeros(Vmax,1);
        TP.D.Trl.VS.PMT_PELctrl =               zeros(Vmax,1);
        TP.D.Trl.VS.PMT_StatusLED =             false(Vmax,5);
        TP.D.Trl.VS.PMT_CtrlGainValue =         zeros(Vmax,1);
        TP.D.Trl.VS.PMT_MontGainValue =         zeros(Vmax,1);
        TP.D.Trl.VS.PMT_MontGainNoise =         zeros(Vmax,1);
        TP.D.Trl.VS.Power_AOD_CtrlAmpValue =	zeros(Vmax,1);
        TP.D.Trl.VS.Power_AOD_MontAmpValue =    zeros(Vmax,2);
        TP.D.Trl.VS.Power_AOD_MontAmpNoise =    zeros(Vmax,2);
        TP.D.Trl.VS.Power_PmeasuredS121C =      zeros(Vmax,1);
        TP.D.Trl.VS.Power_PinferredAtCtx =      zeros(Vmax,1);
        
        TP.D.Trl.StreamFname = ...
            [TP.D.Exp.DataDir, datestr(TP.D.Trl.TimeStampStarted, 'yymmddTHHMMSS'),'.rec'];
        TP.D.Trl.StreamFid = fopen(TP.D.Trl.StreamFname,'w');  
	end
 
%% Setup NIDAQ
    TP.HW.NI.T.hTask_DO_6536.start();                   % Scanning
    TP.HW.NI.T.hTask_AI_6115.start();                   % Imaging
  	TP.HW.NI.T.hTask_CO_TrigListener.start();           % Trigger Listener
	switch TP.D.Trl.ScanScheme
        case 'FOCUS'
            TP.HW.NI.T.hTask_CO_IntTrig.start();        % Internal Trigger
        case 'GRAB'
            TP.HW.NI.T.hTask_AO_6323.start();           % Sound Playback
            TP.HW.NI.T.hTask_CO_IntTrig.start();        % Internal Trigger
        case 'LOOP'
         	TP.HW.NI.T.hTask_CO_StopListener.start(); 	% Stop Listerner
        otherwise
	end
    
%% GUI StartTrigStop Coloring
	h = get(TP.UI.H.hTrl_StartTrigStop_Rocker, 'Children');
    set(h(2),   'backgroundcolor', TP.UI.C.SelectB);
	set(h(1),   'backgroundcolor', TP.UI.C.TextBG);
	set(h(3),   'backgroundcolor', TP.UI.C.TextBG);

%% MSG LOG
    msg = [datestr(now, 'yy/mm/dd HH:MM:SS.FFF') '\tscanStarted\tScanning Started w/ Volume time = ',...
        num2str(TP.D.Exp.BCD.ScanVolumeTime),' sec\r\n'];
    updateMsg(TP.D.Exp.hLog, msg);