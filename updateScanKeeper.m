function updateScanKeeper(~,evnt)
% updateScanKeeper is called when hTask_AI_6115 updates
% Count Update and Volume #, Record and Save Data
% And Call scanStopped to Stop when at the end of a volume and 
%   Either Time is up, Or Stop Flag is raised 
% for 2D random 256p         on T5810

global TP
persistent Udone
persistent Tdisp
persistent TimeStampUpdt

%% Record Instant Update Time 
TimeStampUpdt = now;                                        % Read Current Time

%% Stream and Save Data
    if TP.D.Exp.BCD.ImageEnable
        TP.D.Vol.DataColRaw = evnt.data;                    % Read PMT data
        fwrite(TP.D.Trl.Fid, TP.D.Vol.DataColRaw, 'int16');	% Save Streaming Data 
        % record 0.9s data takes ~9ms to log on to harddrive (T3500, 12GB RAM, Raid 0, 7200rpm x2)
    end

%% Update Imaging Time & GUI
    TP.D.Trl.Udone =	TP.D.Trl.Udone + 1;                          	% always integer
    Udone =             TP.D.Trl.Udone;
    TP.D.Trl.Vdone =    TP.D.Trl.Udone * TP.D.Exp.BCD.ImageNumVlmePerUpdt;	% can be float
    TP.D.Trl.Vnum =     ceil(TP.D.Trl.Vdone);
    TP.D.Trl.Unum =     mod(TP.D.Trl.Udone-1, TP.D.Exp.BCD.ImageNumUpdtPerVlme)+1;
                                                                        
    % Record Updates on System Status, if Imaging
    if TP.D.Exp.BCD.ImageEnable
        TP.D.Trl.Updts.TimeStampUpdt(Udone,:) =           	datestr(TimeStampUpdt, 'yy/mm/dd HH:MM:SS.FFF');
        TP.D.Trl.Updts.PMT_PMTctrl(Udone) =               	TP.D.Mon.PMT.PMTctrl;
        TP.D.Trl.Updts.PMT_FANctrl(Udone) =               	TP.D.Mon.PMT.FANctrl;
        TP.D.Trl.Updts.PMT_PELctrl(Udone) =              	TP.D.Mon.PMT.PELctrl;
        TP.D.Trl.Updts.PMT_StatusLED(Udone,:) =             TP.D.Mon.PMT.StatusLED';
        TP.D.Trl.Updts.PMT_CtrlGainValue(Udone) =       	TP.D.Mon.PMT.CtrlGainValue;
        TP.D.Trl.Updts.PMT_MontGainValue(Udone) =        	TP.D.Mon.PMT.MontGainValue;
        TP.D.Trl.Updts.PMT_MontGainNoise(Udone) =        	TP.D.Mon.PMT.MontGainNoise;
        TP.D.Trl.Updts.Power_AOD_CtrlAmpValue(Udone) =  	TP.D.Mon.Power.AOD_CtrlAmpValue;
        TP.D.Trl.Updts.Power_AOD_MontAmpValue(Udone,:) =	TP.D.Mon.Power.AOD_MontAmpValue;
        TP.D.Trl.Updts.Power_AOD_MontAmpNoise(Udone,:) =	TP.D.Mon.Power.AOD_MontAmpNoise;
        TP.D.Trl.Updts.Power_PmeasuredS121C(Udone)=     	TP.D.Mon.Power.PmeasuredS121C;
        TP.D.Trl.Updts.Power_PinferredAtCtx(Udone)=     	TP.D.Mon.Power.PinferredAtCtx;
    end
    
    % Trial Timing & GUI Updates w/ precision of 100ms    
    TP.D.Trl.Load.DurCurrent =      TP.D.Trl.Udone * TP.D.Exp.BCD.ImageNumSmplPerUpdt /...
                                    TP.D.Sys.NI.Task_AI_6115_SR;
    TP.D.Ses.Load.DurCurrent =      TP.D.Trl.Load.DurCurrent + ...
                                    TP.D.Trl.Load.DurTotal*(TP.D.Ses.TargetedTrlNumCurrent-1);
    TP.D.Ses.Load.CycleDurCurrent = mod(TP.D.Ses.Load.DurCurrent, TP.D.Ses.Load.CycleDurTotal);

    if Tdisp ~= floor(TP.D.Trl.Load.DurCurrent*10)/10
        % avoid too fast UI update when volume rate is too high
        % the updating rate is <10Hz
        set(TP.UI.H.hSes_CycleDurCurrent_Edit,	'String',	sprintf('%5.1f (s)',TP.D.Ses.Load.CycleDurCurrent));
        set(TP.UI.H.hSes_DurCurrent_Edit,       'String',	sprintf('%5.1f (s)',TP.D.Ses.Load.DurCurrent)); 
        set(TP.UI.H.hTrl_DurCurrent_Edit,       'String',	sprintf('%5.1f (s)',TP.D.Trl.Load.DurCurrent));
    end
	Tdisp = floor(TP.D.Trl.Load.DurCurrent*10)/10;
    
%% Imaging Update
% Render the Image for Dispaly
if TP.D.Exp.BCD.ImageEnable    
    % Imaging Reconstruction
    feval(TP.D.Exp.BCD.ImageImgFunc);    
    % Image Display
    set(TP.UI.H0.hImage,    'cdata', ...
        TP.D.Vol.LayerDisp{ (TP.D.Exp.BCD.ScanNumLayrPerVlme+1)/2 } );
    % Histogram Display
    updateImageHistogram(TP.UI.H0.Hist0);
end

%% Check if Trial Timeout
if (TP.D.Trl.State == 2) && (TP.D.Trl.Load.DurCurrent > TP.D.Trl.TargetedTrlDurTotal)
        TP.D.Trl.TimeStampStopping =	datestr(now, 'yy/mm/dd HH:MM:SS.FFF');
        TP.D.Trl.State =                -1;   
        %   -1 =    Stopping,  
        %   0 =     Stopped,
        %   1 =     Started,
        %   2 =     Triggered
    % MSG LOG 
    msg = [datestr(now, 'yy/mm/dd HH:MM:SS.FFF') '\tupdateScanKeeper\tScanning Stopping since timeout\r\n'];
    updateMsg(TP.D.Exp.hLog, msg);
end

%% Wait until the current volume is finished to stop the trial
if  TP.D.Trl.State == -1 && TP.D.Trl.Vdone == TP.D.Trl.Vnum 
    scanStopped;
end

