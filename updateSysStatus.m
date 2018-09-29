function updateSysStatus(~,evnt)
% This function updates System Status from DI, AI monitor tasks of NI
% Terminal Definition is in SetupD
% Terminal comments here are updated @4/18/2013, just for reference.

% ~7.6ms for T5810, E5-1630v3, 64GB, 1TB 850ProSSD, 3.6 - 12.4 ms observed

global TP
persistent sysAIstatus
persistent sysDIstatus
persistent sysAmp
persistent sysNoise
persistent DispFlag
persistent PmeasuredS121C
persistent C
%% Read PowerMeter Data
    if ~TP.D.Mon.Power.CalibFlag
        try
        PmeasuredS121C = ...
        round(1e7*str2double(TP.HW.Thorlabs.PM100{1}.h.fscanf))/1e4;  
                                                                % xx.xxxx mW
        catch
        end
    end
    
%% Read from NIDAQ
    sysAIstatus =   evnt.data;	% ~5us on T5810-2014, if the system is too busy, size(evnt.date) = [0 0] 
        % AI_6323   Dev3/AI: [PMT#1 Gain Mont, AOD X Amp Mont, AOD Y Amp Mont]
	sysDIstatus =   logical(TP.HW.NI.T.hTask_DI_6115.readDigitalData);
        % DI_6115	Dev1/line3:7 [M9012, Status, Error, TooBright, TooHot]  
    sysAmp =        mean(sysAIstatus);   
    sysNoise =      std(sysAIstatus);   
    DispFlag =      (   round([ TP.D.Mon.PMT.MontGainValue, ...
                                TP.D.Mon.Power.AOD_MontAmpValue, ... 
                                TP.D.Mon.PMT.MontGainNoise, .... 
                                TP.D.Mon.Power.AOD_MontAmpNoise],3) ~= ...
                        round([sysAmp sysNoise],3) );
    TP.D.Mon.PMT.MontGainValue =        sysAmp(1);
    TP.D.Mon.Power.AOD_MontAmpValue =	sysAmp(2:3);
    TP.D.Mon.PMT.MontGainNoise =        sysNoise(1);
    TP.D.Mon.Power.AOD_MontAmpNoise =	sysNoise(2:3);

%% Load C Data
    try 	if ~isfield(C, 'HWP_pmax'); C = TP.D.Sys.Power.C;   end
    catch;                              C = TP.D.Sys.Power.C;   end
    
%% Update PMT Gain and AOD Amp & Noise
    if DispFlag(1); set(TP.UI.H.hMon_PMT_MontGainValue_Edit,      'String',sprintf('%5.3f (V)',sysAmp(1))); end % Update PMT Gain Mont
    if DispFlag(2); set(TP.UI.H.hMon_Power_AOD_MontAmpValueX_Edit,'String',sprintf('%5.3f (V)',sysAmp(2))); end % Update AOD X Amp Mont  
    if DispFlag(3); set(TP.UI.H.hMon_Power_AOD_MontAmpValueY_Edit,'String',sprintf('%5.3f (V)',sysAmp(3))); end % Update AOD Y Amp Mont
    
    if DispFlag(4); set(TP.UI.H.hMon_PMT_MontGainNoise_Edit,      'String',sprintf('%5.3f (V)',sysNoise(1))); end % Update PMT Gain Mont Noise      
    if DispFlag(5); set(TP.UI.H.hMon_Power_AOD_MontAmpNoiseX_Edit,'String',sprintf('%5.3f (V)',sysNoise(2))); end % Update AOD X Amp Mont Noise 
    if DispFlag(6); set(TP.UI.H.hMon_Power_AOD_MontAmpNoiseY_Edit,'String',sprintf('%5.3f (V)',sysNoise(3))); end % Update AOD Y Amp Mont Noise
    
%% Update PMT status LEDs   
    for i = 1:TP.D.Sys.NI.Chan_DI_PMT_Status{6}
        if xor(sysDIstatus(i),TP.D.Mon.PMT.StatusLED(i))
            set(TP.D.Sys.NI.Chan_DI_PMT_Status{7}{i}, 'BackgroundColor',...
            (1-sysDIstatus(i))*TP.UI.C.BG + sysDIstatus(i)*TP.D.Sys.NI.Chan_DI_PMT_Status{4}(i,:));
        end
    end
    TP.D.Mon.PMT.StatusLED = sysDIstatus;
    % update TP.D.Ses.OverloadPMT

%% Update PowerMeter Monitored
    if PmeasuredS121C ~= TP.D.Mon.Power.PmeasuredS121C
        TP.D.Mon.Power.PmeasuredS121C =         PmeasuredS121C;
        TP.D.Mon.Power.PinferredAtCtx = ...
            C.ARM_p1 * TP.D.Mon.Power.PmeasuredS121C + C.ARM_p2;
        
        if (TP.D.Mon.Power.PinferredAtCtx > TP.D.Mon.Power.PmaxCtxAllowed)...
            && ~TP.D.Ses.OverloadLaser
            feval(TP.D.Sys.Name,...
                'GUI_AO_6115',[ TP.D.Mon.PMT.CtrlGainValue  0]);
                    %           PMT Gain Control            0, && StartTrigStop==2
            TP.D.Ses.OverloadLaser = 1;  
            set(TP.UI.H.hMon_Power_PinferredAtCtx_Edit, 'ForegroundColor', [0.8 0 0]);
        end
        set(TP.UI.H.hMon_Power_PmeasuredS121C_Edit, 'string', ...
            sprintf('%5.4f',    TP.D.Mon.Power.PmeasuredS121C) );
        set(TP.UI.H.hMon_Power_PinferredAtCtx_Edit, 'string', ...
            sprintf('%5.4f',    TP.D.Mon.Power.PinferredAtCtx) );
    end
    
%% Send hardware reading request
    if ~TP.D.Mon.Power.CalibFlag
        % PowerMeter
        fprintf(TP.HW.Thorlabs.PM100{1}.h,  'MEAS:POW?'); 	% 2-6 ms by itself
    end
    
