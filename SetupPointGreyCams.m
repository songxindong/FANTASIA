function msg = SetupPointGreyCams
global Xin

%% Initiation
imaqreset;      % reset cameras 

%% Search All PointGrey Cameras
try 
    info = imaqhwinfo('pointgrey');
    % All PointGrey cameras' name would be listed
catch
    errordlg('PointGrey cameras cannot be located')
end

%% Locate Each Camera 
for i = 1:length(info.DeviceInfo)
    info.hVid = videoinput('pointgrey', i, info.DeviceInfo(i).DefaultFormat);
    info.hSrc = getselectedsource(info.hVid);
    for j = 1:length(Xin.D.Sys.PointGreyCam) 
        if strcmp(  Xin.D.Sys.PointGreyCam(j).DeviceName,	info.DeviceInfo(i).DeviceName) && ...
           strcmp(  Xin.D.Sys.PointGreyCam(j).SerialNumber,	info.hSrc.SerialNumber)
            Xin.D.Sys.PointGreyCam(j).Located = i;
        end     
    end
    delete(info.hVid);
end

%% Setting Up Cameras
for i = 1:length(Xin.D.Sys.PointGreyCam)    
    if Xin.D.Sys.PointGreyCam(i).Located
        Xin.HW.PointGrey.Cam(i).hVid = videoinput('pointgrey',...
                                        Xin.D.Sys.PointGreyCam(i).Located,...
                                        Xin.D.Sys.PointGreyCam(i).Format);
        Xin.HW.PointGrey.Cam(i).hSrc = getselectedsource( Xin.HW.PointGrey.Cam(i).hVid);
             
        %% Getting Parameters from Cameras        
        pVid = propinfo(Xin.HW.PointGrey.Cam(i).hVid);
        pSrc = propinfo(Xin.HW.PointGrey.Cam(i).hSrc); 

        %% General Fixed Settings for all Cameras in XINTRINSIC & FANTASIA
        Xin.HW.PointGrey.Cam(i).hVid.LoggingMode =      'memory';   % do not use VideoWriter, since initial binning is necessary
        Xin.HW.PointGrey.Cam(i).hVid.FramesPerTrigger =	1;          % one frame/trigger
        Xin.HW.PointGrey.Cam(i).hSrc.Brightness =       pSrc.Brightness.ConstraintValue(1);  
                                                                  % the lowest possible brightness
        Xin.HW.PointGrey.Cam(i).hSrc.FrameRateMode =    'Manual';   % customized lock
        if isfield(pSrc, 'Gamma')
            Xin.HW.PointGrey.Cam(i).hSrc.Gamma =        1;          % 1 = linear
            Xin.HW.PointGrey.Cam(i).hSrc.GammaMode =	'Off';      % customized lock
        end
        if isfield(pVid, 'Sharpness')
            Xin.HW.PointGrey.Cam(i).hSrc.Sharpness =	1024;       % 1024 = do nothing
            Xin.HW.PointGrey.Cam(i).hSrc.SharpnessMode ='Off';      % customized lock 
        end
        Xin.HW.PointGrey.Cam(i).hSrc.Strobe1 =          'Off';      % disable
        Xin.HW.PointGrey.Cam(i).hSrc.Strobe2 =          'Off';      % disable
        Xin.HW.PointGrey.Cam(i).hSrc.Strobe3 =          'Off';      % disable
        Xin.HW.PointGrey.Cam(i).hSrc.TriggerDelay =     0;          % immediately
        Xin.HW.PointGrey.Cam(i).hSrc.TriggerParameter =	1;          % ? DCAM property
        Xin.HW.PointGrey.Cam(i).hSrc.TriggerDelayMode = 'Off';      % no delay
        Xin.HW.PointGrey.Cam(i).hSrc.ExposureMode = 	'Off';       
        Xin.HW.PointGrey.Cam(i).hSrc.ShutterMode =      'Manual';  
        Xin.HW.PointGrey.Cam(i).hSrc.GainMode =         'Manual'; 

        %% Variable Settings for Individual Cameras
        Xin.HW.PointGrey.Cam(i).hSrc.FrameRate =        Xin.D.Sys.PointGreyCam(i).FrameRate; 
        
        Xin.D.Sys.PointGreyCam(i).ShutterRange =        pSrc.Shutter.ConstraintValue;
        Xin.D.Sys.PointGreyCam(i).Shutter =             Xin.D.Sys.PointGreyCam(i).ShutterRange(2);
        Xin.HW.PointGrey.Cam(i).hSrc.Shutter =          Xin.D.Sys.PointGreyCam(i).Shutter;        
        
        Xin.D.Sys.PointGreyCam(i).GainRange =        	pSrc.Gain.ConstraintValue;  
        switch Xin.D.Sys.PointGreyCam(i).GainPolar
            case 'Min' 
                Xin.D.Sys.PointGreyCam(i).Gain =        Xin.D.Sys.PointGreyCam(i).GainRange(1); 
            case 'Max' 
                Xin.D.Sys.PointGreyCam(i).Gain =        Xin.D.Sys.PointGreyCam(i).GainRange(2);
            otherwise
                errordlg(...
                    ['PointGrey Camera #', num2str(i),...
                    ': unidentifiable "GainPolar"']);
                Xin.D.Sys.PointGreyCam(i).Gain =        Xin.D.Sys.PointGreyCam(i).GainRange(1); 
        end 
        Xin.HW.PointGrey.Cam(i).hSrc.Gain =             Xin.D.Sys.PointGreyCam(i).Gain;

%         % For Color Cameras
%         Xin.HW.PointGrey.Cam(i).hSrc.WhiteBalanceRB =   Xin.D.Sys.PointGreyCam(i).WhiteBalanceRB; 
%         Xin.HW.PointGrey.Cam(i).hSrc.WhiteBalanceRBMode = ...
%                                                         Xin.D.Sys.PointGreyCam(i).WhiteBalanceRBMode;

        %% Setting up Display Related Parameters
        set(Xin.HW.PointGrey.Cam(i).hVid,...
            'UserData',                                 ['PGC(', num2str(i), ').hVid']);        
        Xin.D.Sys.PointGreyCam(i).RawVideoResolution =	pVid.VideoResolution.DefaultValue;
        Xin.D.Sys.PointGreyCam(i).RawWidth =            Xin.D.Sys.PointGreyCam(i).RawVideoResolution(1); 
        Xin.D.Sys.PointGreyCam(i).RawHeight =           Xin.D.Sys.PointGreyCam(i).RawVideoResolution(2);
        Xin.D.Sys.PointGreyCam(i).DispClipROI =         0;        
        Xin.D.Sys.PointGreyCam(i).DispPeriod =          0.1;  % in second, fixed for all cameras
        Xin.D.Sys.PointGreyCam(i).DispTimer =           second(now);  
        Xin.D.Sys.PointGreyCam(i).DispGainBit =         0;
        Xin.D.Sys.PointGreyCam(i).DispGainNum =         2^Xin.D.Sys.PointGreyCam(i).DispGainBit;
        Xin.D.Sys.PointGreyCam(i).DispGainBitRange =    0:4;
        Xin.D.Sys.PointGreyCam(i).DispGainBinNummRange= 2.^Xin.D.Sys.PointGreyCam(i).DispGainBitRange;
            % Xin.D.Sys.PointGreyCam(i).ROIPosition
        
        %% Camera preview inputs
        switch  Xin.D.Sys.PointGreyCam(i).PreviewBitDepth
            case 8
                Xin.D.Sys.PointGreyCam(i).PreviewImageIn = ...
                                                        uint8(256*rand(...
                                                        Xin.D.Sys.PointGreyCam(i).RawHeight,...
                                                        Xin.D.Sys.PointGreyCam(i).RawWidth, 1));   
            case 16
                Xin.D.Sys.PointGreyCam(i).PreviewImageIn = ...
                                                        uint16(256*rand(...
                                                        Xin.D.Sys.PointGreyCam(i).RawHeight,...
                                                        Xin.D.Sys.PointGreyCam(i).RawWidth, 1));  
            otherwise
        end
            Xin.D.Sys.PointGreyCam(i).PreviewStrFR =	[num2str(Xin.D.Sys.PointGreyCam(i).FrameRate) '.00 FPS'];
            Xin.D.Sys.PointGreyCam(i).PreviewStrTS =	'00:00:00.0';
       
        %% process display image
        % BINNING
        BinW =	Xin.D.Sys.PointGreyCam(i).RawWidth/ Xin.D.Sys.PointGreyCam(i).PreviewZoom;
        BinH =	Xin.D.Sys.PointGreyCam(i).RawHeight/Xin.D.Sys.PointGreyCam(i).PreviewZoom;
        Bin =     Xin.D.Sys.PointGreyCam(i).PreviewZoom;
        
            Xin.D.Sys.PointGreyCam(i).DispImgB1 =       uint16( Xin.D.Sys.PointGreyCam(i).PreviewImageIn); 
        if Bin == 1
            Xin.D.Sys.PointGreyCam(i).DispImgBO =       Xin.D.Sys.PointGreyCam(i).DispImgB1;
        else 	
            Xin.D.Sys.PointGreyCam(i).DispImgB2 =       reshape(Xin.D.Sys.PointGreyCam(i).DispImgB1,...
                                                            Bin,      BinH,...
                                                            Bin,      BinW); 
            Xin.D.Sys.PointGreyCam(i).DispImgB3 =       sum(Xin.D.Sys.PointGreyCam(i).DispImgB2, 1, 'native');  
            Xin.D.Sys.PointGreyCam(i).DispImgB4 =       sum(Xin.D.Sys.PointGreyCam(i).DispImgB3, 3, 'native');
            Xin.D.Sys.PointGreyCam(i).DispImgBO =       squeeze(Xin.D.Sys.PointGreyCam(i).DispImgB4);
        end
        % GAIN & NORMALIZATION
            Xin.D.Sys.PointGreyCam(i).DispImgGO =       uint8(...
                                                            Xin.D.Sys.PointGreyCam(i).DispImgBO/Bin^2*...
                                                            Xin.D.Sys.PointGreyCam(i).DispGainNum);        
        % ROTATE
        try
            Xin.D.Sys.PointGreyCam(i).DispImgRO =       rot90(Xin.D.Sys.PointGreyCam(i).DispImgGO, ...
                                                            (360-Xin.D.Sys.PointGreyCam(i).PreviewRot)/90);
        catch
            Xin.D.Sys.PointGreyCam(i).DispImgRO =       Xin.D.Sys.PointGreyCam(i).DispImgGO;
            disp('Preview Rotation Angle Not Support');
        end        
        % ROI 
        if  Xin.D.Sys.PointGreyCam(i).DispClipROI
            Xin.D.Sys.PointGreyCam(i).DispImgOO =       Xin.D.Sys.PointGreyCam(i).DispImgRO.*...
                                                        Xin.D.Sys.PointGreyCam(i).ROIi;
        else
            Xin.D.Sys.PointGreyCam(i).DispImgOO =       Xin.D.Sys.PointGreyCam(i).DispImgRO;
        end       
        Xin.D.Sys.PointGreyCam(i).DispImg =             Xin.D.Sys.PointGreyCam(i).DispImgOO;

%         % HISTOGRAM
%         Xin.D.Sys.PointGreyCam(i).DispHistMax =   	max(Xin.D.Sys.PointGreyCam(i).DispImage, [], 2);
%         Xin.D.Sys.PointGreyCam(i).DispHistMean =      uint8(mean(Xin.D.Sys.PointGreyCam(i).DispImage,2)); 
%         Xin.D.Sys.PointGreyCam(i).DispHistMin =       min(Xin.D.Sys.PointGreyCam(i).DispImage, [], 2);
        
        %% Display rotaion reltaed parameters
        switch Xin.D.Sys.PointGreyCam(i).PreviewRot
            case 0;     Xin.D.Sys.PointGreyCam(i).DispWidth =	BinW;
                        Xin.D.Sys.PointGreyCam(i).DispHeight =	BinH;
            case 90;	Xin.D.Sys.PointGreyCam(i).DispWidth =	BinH;
                        Xin.D.Sys.PointGreyCam(i).DispHeight =	BinW;
            case 180;	Xin.D.Sys.PointGreyCam(i).DispWidth =	BinW;
                        Xin.D.Sys.PointGreyCam(i).DispHeight =	BinH;
            case 270;	Xin.D.Sys.PointGreyCam(i).DispWidth =	BinH;
                        Xin.D.Sys.PointGreyCam(i).DispHeight =	BinW;
            otherwise;  errordlg('Preview Rotation Angle Not Support');
        end

    else
        errordlg(['PointGrey cameras #', num2str(i),' "', Xin.D.Sys.PointGreyCam(i).Comments, '" cannot be located']);        
    end
end

%% LOG MSG
msg = [datestr(now) '\tSetupPointGreyCamera\tSetup PointGrey Cameras\r\n'];  
try
	fprintf(Xin.D.Sys.hLog, msg);
catch
	disp(msg);
end