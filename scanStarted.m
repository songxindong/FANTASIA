function scanStarted
% This function is called by
%   (1) Ses_StartStop, starts the 1st trial
%   (2) scanStopped, restarts next trial


global TP

%% Trial State Timing
    % Timing & Flag Info, for Started
    TP.D.Trl.ExpBCDTimeStamp =      TP.D.Exp.BCD.CommitedTimeStamp; 
    TP.D.Trl.ExpBCDFileName =       TP.D.Exp.BCD.CommitedFileName;
    TP.D.Trl.SesTimeStamp =         TP.D.Ses.TimeStampStart; 
    TP.D.Trl.SesFileName =          TP.D.Ses.FileName;         
        TP.D.Trl.TimeStampStarted =     datestr(now, 'yy/mm/dd HH:MM:SS.FFF'); 
        TP.D.Trl.TimeStampTriggered =	NaN;
        TP.D.Trl.TimeStampStopping =    NaN;
        TP.D.Trl.TimeStampStopped =     NaN; 
        TP.D.Trl.State =                1;  
        %   -1 =    Stopping,  
        %   0 =     Stopped,
        %   1 =     Started,
        %   2 =     Triggered
    feval(TP.D.Sys.Name,'GUI_Rocker','hTrl_StartTrigStop_Rocker',   'Started');

%% Trial & Cycle Number Control (Load)
	TP.D.Ses.TargetedTrlNumCurrent =    TP.D.Ses.TargetedTrlNumCurrent + 1;
            tt =                                TP.D.Ses.TargetedTrlNumCurrent; 
            TP.D.Ses.Load.CycleNumCurrent =     ceil(tt/TP.D.Trl.Load.NumTotal);
            TP.D.Trl.Load.NumCurrent =          mod(tt-1, TP.D.Trl.Load.NumTotal) + 1;
    try     % if "Search" or "Record"    
            stimnum =                           TP.D.Ses.Load.TrlOrderVec(tt);
            TP.D.Trl.Load.StimNumCurrent =      ['#', num2str(stimnum)];
            TP.D.Trl.Load.SoundNumCurrent =     TP.D.Ses.Load.TrlIndexSoundNum(stimnum);
            TP.D.Trl.Load.AttDesignCurrent =    TP.D.Trl.Load.Attenuations(stimnum);
            TP.D.Trl.Load.AttNumCurrent =       TP.D.Ses.Load.TrlIndexAddAttNum(stimnum);
            TP.D.Trl.Load.AttAddCurrent =       TP.D.Ses.Load.AddAtts(TP.D.Trl.Load.AttNumCurrent);        
            TP.D.Trl.Load.AttCurrent =          TP.D.Trl.Load.AttDesignCurrent + TP.D.Trl.Load.AttAddCurrent;
        try     % if Trl Name available in the sound     
            TP.D.Trl.Load.SoundNameCurrent =    TP.D.Trl.Load.Names{TP.D.Trl.Load.SoundNumCurrent};
        catch   % if Trl Name NA in the sound
            TP.D.Trl.Load.SoundNameCurrent =    '???';
        end
        try     % if the s
            TP.D.Trl.Load.StimNumNext =         ['#', num2str(TP.D.Ses.Load.TrlOrderVec(tt+1))];
        catch
            TP.D.Trl.Load.StimNumNext =         'end';
        end
    catch   % if "XBlaster"
            TP.D.Trl.Load.StimNumCurrent =      'XBlaster';
            TP.D.Trl.Load.SoundNumCurrent =     NaN;
            TP.D.Trl.Load.AttDesignCurrent =    NaN;
            TP.D.Trl.Load.AttNumCurrent =       NaN;
            TP.D.Trl.Load.AttAddCurrent =       NaN;
            TP.D.Trl.Load.AttCurrent =          NaN;
            TP.D.Trl.Load.SoundNameCurrent =    '???';
            TP.D.Trl.Load.StimNumNext =         'XBlaster';
    end    
    set(TP.UI.H.hSes_CycleNumCurrent_Edit,  'String',	num2str(TP.D.Ses.Load.CycleNumCurrent));
    set(TP.UI.H.hTrl_NumCurrent_Edit,       'String',	num2str(TP.D.Trl.Load.NumCurrent));
    set(TP.UI.H.hTrl_StimNumCurrent_Edit,   'String',	TP.D.Trl.Load.StimNumCurrent);
    set(TP.UI.H.hTrl_SoundNumCurrent_Edit,  'String',	num2str(TP.D.Trl.Load.SoundNumCurrent));
    set(TP.UI.H.hTrl_AttDesignCurrent_Edit, 'String',	sprintf('%5.1f (dB)',TP.D.Trl.Load.AttDesignCurrent));
    set(TP.UI.H.hTrl_AttAddCurrent_Edit,    'String',	sprintf('%5.1f (dB)',TP.D.Trl.Load.AttAddCurrent));
    set(TP.UI.H.hTrl_AttCurrent_Edit,       'String',	sprintf('%5.1f (dB)',TP.D.Trl.Load.AttCurrent));
    set(TP.UI.H.hTrl_SoundNameCurrent_Edit, 'String',	TP.D.Trl.Load.SoundNameCurrent);
    set(TP.UI.H.hTrl_StimNumNext_Edit,      'String',	TP.D.Trl.Load.StimNumNext);

%% Setup TDT PA5 & Sound
    if ~strcmp(TP.D.Ses.ScanScheme, 'XBlaster')
        invoke(TP.HW.TDT.PA5,   'SetAtten', TP.D.Trl.Load.AttCurrent);   
    end
    if  strcmp(TP.D.Ses.ScanScheme, 'Record')
        TP.D.Trl.RecordSound =  TP.D.Ses.Load.SoundMat(...
                                :,TP.D.Ses.Load.TrlOrderSoundVec(TP.D.Ses.TargetedTrlNumCurrent));
    end
    
%% Trial Timing
    TP.D.Trl.Udone = 0;     TP.D.Trl.Vdone = 0;
    TP.D.Trl.Unum = 0;      TP.D.Trl.Vnum = 0;  
	TP.D.Trl.TargetedTrlDurTotal =      TP.D.Trl.Load.DurTotal;
    TP.D.Ses.Load.CycleDurCurrent =     NaN;  
	TP.D.Ses.Load.DurCurrent =          NaN;  
	TP.D.Trl.Load.DurCurrent =          NaN;
    set(TP.UI.H.hTrl_TargetedTrlDurTotal_Edit,  'String',   sprintf('%5.1f (s)',TP.D.Trl.TargetedTrlDurTotal));
	set(TP.UI.H.hSes_CycleDurCurrent_Edit,      'String',	sprintf('%5.1f (s)',TP.D.Ses.Load.CycleDurCurrent));
	set(TP.UI.H.hSes_DurCurrent_Edit,           'String',	sprintf('%5.1f (s)',TP.D.Ses.Load.DurCurrent)); 
    set(TP.UI.H.hTrl_DurCurrent_Edit,           'String',	sprintf('%5.1f (s)',TP.D.Trl.Load.DurCurrent));
    
%% Trial Data	
	if TP.D.Exp.BCD.ImageEnable  
        TP.D.Trl.FileName =             [datestr(datenum(TP.D.Trl.TimeStampStarted), 'yymmddTHHMMSS'),...
                                        '_Trl_#', num2str(TP.D.Ses.TargetedTrlNumCurrent)];     
        % reset TP.D.Trl.VS
        Vmax =  ceil( TP.D.Trl.Load.DurTotal * TP.D.Exp.BCD.ScanVolumeRate);
        TP.D.Trl.Updts = table;
        TP.D.Trl.Updts.TimeStampUpdt =          repmat(' ', Vmax, 21);     
        TP.D.Trl.Updts.PMT_PMTctrl =            zeros(Vmax,1);
        TP.D.Trl.Updts.PMT_FANctrl =            zeros(Vmax,1);
        TP.D.Trl.Updts.PMT_PELctrl =            zeros(Vmax,1);
        TP.D.Trl.Updts.PMT_StatusLED =          false(Vmax,5);
        TP.D.Trl.Updts.PMT_CtrlGainValue =      zeros(Vmax,1);
        TP.D.Trl.Updts.PMT_MontGainValue =      zeros(Vmax,1);
        TP.D.Trl.Updts.PMT_MontGainNoise =      zeros(Vmax,1);
        TP.D.Trl.Updts.Power_AOD_CtrlAmpValue =	zeros(Vmax,1);
        TP.D.Trl.Updts.Power_AOD_MontAmpValue =	zeros(Vmax,2);
        TP.D.Trl.Updts.Power_AOD_MontAmpNoise =	zeros(Vmax,2);
        TP.D.Trl.Updts.Power_PmeasuredS121C =	zeros(Vmax,1);
        TP.D.Trl.Updts.Power_PinferredAtCtx =	zeros(Vmax,1);
        % Stream File Openned
        TP.D.Trl.Fid = fopen([TP.D.Exp.DataDir, TP.D.Trl.FileName, '.rec'],'w');  
	end
   
%% Setup NIDAQ
    % LOAD RIGHT SOUND !!!!!
    import dabs.ni.daqmx.*
    TP.HW.NI.T.hTask_DO_6536.start();                   % Scanning
    TP.HW.NI.T.hTask_AI_6115.start();                   % Imaging
  	TP.HW.NI.T.hTask_CO_TrigListener.start();           % Trigger Listener
	switch TP.D.Ses.ScanScheme
        case 'Search'
            TP.HW.NI.T.hTask_CO_IntTrig.start();        % Internal Trigger
        case 'Record'
            % Sound Task
            try TP.HW.NI.T.hTask_AO_6323.abort();       catch;  end
            try TP.HW.NI.T.hTask_AO_6323.delete();      catch;  end
            TP.HW.NI.T.hTask_AO_6323 = Task(TP.D.Sys.NI.Task_AO_6323_Name);
            TP.HW.NI.T.hTask_AO_6323.createAOVoltageChan(...
                TP.D.Sys.NI.Chan_AO_SoundWave{1},   TP.D.Sys.NI.Chan_AO_SoundWave{2}, ...
                TP.D.Sys.NI.Chan_AO_SoundWave{3},   TP.D.Sys.NI.Chan_AO_SoundWave{4}(1), ...
                TP.D.Sys.NI.Chan_AO_SoundWave{4}(2),'DAQmx_Val_Volts');
            TP.HW.NI.T.hTask_AO_6323.cfgSampClkTiming(...
                TP.D.Sys.NI.Task_AO_6323_UR,...
                'DAQmx_Val_FiniteSamps',            length(TP.D.Trl.RecordSound) );
            TP.HW.NI.T.hTask_AO_6323.cfgOutputBuffer(...
                                                    length(TP.D.Trl.RecordSound)*2 );
            TP.HW.NI.T.hTask_AO_6323.set(...
                'sampClkTimebaseRate',              TP.D.Sys.NI.Sys_TimingRate,...
                'sampClkTimebaseSrc',               TP.D.Sys.NI.Sys_TimingBridge{2});

            TP.HW.NI.T.hTask_AO_6323.writeAnalogData(TP.D.Trl.RecordSound, 5 ,false);
            TP.HW.NI.T.hTask_AO_6323.cfgDigEdgeStartTrig(...
                TP.D.Sys.NI.Sys_TrigBridge{2},      'DAQmx_Val_Rising');
            TP.HW.NI.T.hTask_AO_6323.start();           % Sound Playback
            TP.HW.NI.T.hTask_CO_IntTrig.start();        % Internal Trigger
        case 'XBlaster'
         	TP.HW.NI.T.hTask_CO_StopListener.start(); 	% Stop Listerner
        otherwise
	end

%% MSG LOG
    msg = [datestr(now, 'yy/mm/dd HH:MM:SS.FFF') '\tscanStarted\tScanning Started w/'...
        'Volume time = ' num2str(TP.D.Exp.BCD.ScanVolumeTime),' (sec) & '...
        'Cycle # ', num2str(TP.D.Ses.Load.CycleNumCurrent), ' & ',...
        'Trial # ', num2str(TP.D.Trl.Load.NumCurrent), '\r\n'];
    updateMsg(TP.D.Exp.hLog, msg);