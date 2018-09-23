function scanStopping(~,~)
% This function is called by
%   (1) External trigger falling edge, StopListener

global TP

%% Trial State Timing
	TP.D.Trl.TargetedTrlDurTotal =      TP.D.Trl.Load.DurCurrent; 
