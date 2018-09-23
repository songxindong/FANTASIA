function scanTriggered(src,~)
% This function is called by 
%   (1) TrigListener Task callbacks 
%   (2) StopListener Task callbacks 


global TP;
persistent Trig;                    Trig = NaN;
switch src.taskName
    case 'Trigger Listener Task';   Trig = 1;   % counter task called by trigger raising edge, internal or external
    case 'Stop Listener Task';      Trig = 0;   % counter task called by External trigger falling edge, 
    otherwise
        disp('Counter Task Name NOT Identified!')
end
if Trig
%% Trial State Timing
        TP.D.Trl.TimeStampTriggered =	datestr(now, 'yy/mm/dd HH:MM:SS.FFF'); 
        TP.D.Trl.State =                2; 
        %   -1 =    Stopping,  
        %   0 =     Stopped,
        %   1 =     Started,
        %   2 =     Triggered
    feval(TP.D.Sys.Name,'GUI_Rocker','hTrl_StartTrigStop_Rocker',   'Triggered');

%% Setup NIDAQ
    % Turn AOD & PMT Amplitude accordingly
    feval(TP.D.Sys.Name,...
    'GUI_AO_6115',[ TP.D.Mon.PMT.CtrlGainValue  TP.D.Mon.Power.AOD_CtrlAmpValue]);
        %           PMT Gain Control            AOD Amp, && StartTrigStop==2

%% MSG LOG
        msg = [datestr(now, 'yy/mm/dd HH:MM:SS.FFF') '\tScanning Triggered\r\n'];
        updateMsg(TP.D.Exp.hLog, msg);
else
        TP.D.Trl.TargetedTrlDurTotal =      TP.D.Trl.Load.DurCurrent;
end
    