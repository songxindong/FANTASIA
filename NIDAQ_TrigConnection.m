function NIDAQ_TrigConnection
global TP

%% NI-DAQ Trigger line connection
switch TP.D.Ses.ScanTrigType
    case 'internal'
%             TP.HW.NI.T.hTask_CO_IntTrig.start();
%             pause(0.01);
%             TP.HW.NI.T.hTask_CO_IntTrig.stop();            
        % Connect the Internal trigger line to the trigger bridge
        TP.HW.NI.hSys.connectTerms(...
            ['/', TP.D.Sys.NI.Sys_TrigInternalSrc{1},'/',TP.D.Sys.NI.Sys_TrigInternalSrc{2}],...
            ['/', TP.D.Sys.NI.Sys_TrigInternalSrc{1},'/',TP.D.Sys.NI.Sys_TrigBridge{2}]);
    case 'external'
        % Disconnect the Internal trigger line from the trigger bridge
        try
        TP.HW.NI.hSys.disconnectTerms(...
            ['/', TP.D.Sys.NI.Sys_TrigInternalSrc{1},'/',TP.D.Sys.NI.Sys_TrigInternalSrc{2}],...
            ['/', TP.D.Sys.NI.Sys_TrigInternalSrc{1},'/',TP.D.Sys.NI.Sys_TrigBridge{2}]);
        catch
        end
    otherwise
end