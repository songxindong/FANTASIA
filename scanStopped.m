function scanStopped
% This function is called by
%   (1) updateScanKeeper if timeout by the end of a VOL
%   (2) Ses_StartStop with TP.D.Ses.State = -1
%           Session Stopping by CANCELLING the current TRIAL before TRIGGERED in 'XBlaster'

global 	TP

%% Trial State Timing  
    if TP.D.Trl.State == 1  % Stopped from GUI before a trial is triggered
        TP.D.Trl.TimeStampStopping =	datestr(now, 'yy/mm/dd HH:MM:SS.FFF'); 
        TP.D.Trl.State =                -1;
    end
        TP.D.Trl.TimeStampStopped =     datestr(now, 'yy/mm/dd HH:MM:SS.FFF');   
        TP.D.Trl.State =                0; 
        %   -1 =    Stopping,  
        %   0 =     Stopped,
        %   1 =     Started,
        %   2 =     Triggered
    feval(TP.D.Sys.Name,'GUI_Rocker','hTrl_StartTrigStop_Rocker',   'Stopped');

%% Setup NIDAQ
    % Switch AOD & PMT accordingly
    feval(TP.D.Sys.Name,...
  	'GUI_AO_6115',[ TP.D.Mon.PMT.CtrlGainValue  TP.D.Mon.Power.AOD_CtrlAmpValue]);
        %           PMT Gain Control            AOD Amp, && Trl.State==2
    TP.HW.NI.T.hTask_DO_6536.stop();                    % Scanning
    TP.HW.NI.T.hTask_AI_6115.stop();                    % Imaging
    TP.HW.NI.T.hTask_CO_TrigListener.abort();        	% Trigger Listener
    switch TP.D.Ses.ScanScheme
        case 'Search'
            TP.HW.NI.T.hTask_CO_IntTrig.stop();         % Internal Trigger 
        case 'Record'
            TP.HW.NI.T.hTask_CO_IntTrig.stop();         % Internal Trigger  
            TP.HW.NI.T.hTask_AO_6323.abort();         	% Sound Playback   
            TP.HW.NI.T.hTask_AO_6323.delete();            
        case 'XBlaster'
         	TP.HW.NI.T.hTask_CO_StopListener.abort();   % Stop Listerner
        otherwise
    end

%% Trial Data
    % Trim VS
    if TP.D.Exp.BCD.ImageEnable 
        fclose(TP.D.Trl.Fid);
        Trl = TP.D.Trl;
        save([TP.D.Exp.DataDir, TP.D.Trl.FileName,'.mat'],...
            '-struct','Trl');
    end  
    
%% MSG LOG 
    msg = [datestr(now, 'yy/mm/dd HH:MM:SS.FFF') '\tscanStopped\tScanning Stopped w/ # of Volumes Scanned = ',...
        num2str(TP.D.Trl.Vdone),'\r\n'];
	updateMsg(TP.D.Exp.hLog, msg);
    
%% Trl Restart Control
    if TP.D.Ses.TargetedTrlNumCurrent < TP.D.Ses.TargetedTrlNumTotal
        % Session CONTINUES
        pause(TP.D.Trl.ITI);
        scanStarted;
    else
        % Session ENDS
        feval(TP.D.Sys.Name,    'Ses_StartStop',    0)
    end
    