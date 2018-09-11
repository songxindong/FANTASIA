function updateImage
% The function processes the raw data in	TP.D.Vol.DataColRaw,
% and puts the processed absolute image to  TP.D.Vol.LayerAbs{i}
% for   2D random mode;     2D raster mode;     3D raster mode

global TP

%% Data Formmating & Pixelizing
    TP.D.Vol.DataColFlt = -single(TP.D.Vol.DataColRaw);  	% 24 ms  256p

    if TP.D.Exp.BCD.ImageNumSmplPerPixl == 1
        TP.D.Vol.PixlCol = TP.D.Vol.DataColFlt;
    else  
        TP.D.Vol.PixlSmplMat = ...
            reshape(	TP.D.Vol.DataColFlt,...
                        TP.D.Exp.BCD.ImageNumSmplPerPixl,...
                        TP.D.Exp.BCD.ImageNumPixlPerUpdt);     % 2 ms 256p
        TP.D.Vol.PixlCol = ...
            mean(       TP.D.Vol.PixlSmplMat,1);            % 14 ms 256p
    end         

%% for each scanning layer
for i = 1:TP.D.Exp.BCD.ScanNumLayrPerVlme
    %% Descanning Based on the Scanning Mode
    if strcmp(TP.D.Exp.BCD.ScanMode(6), 'n')
        % 2D Random Access, Descanning Image for each update
        TP.D.Vol.LayerAbs{1}(...
            TP.D.Exp.BCD.ScanScanInd{1}.Ind(...
                (TP.D.Trl.Unum-1)* 	TP.D.Exp.BCD.ImageNumPixlPerUpdt + 1:...
                 TP.D.Trl.Unum*     TP.D.Exp.BCD.ImageNumPixlPerUpdt)  ) =...
            TP.D.Vol.PixlCol;                               % 5 ms 256p
        % TODO: The AOD travel delay
        % ~50 ms for 256p;  ~300 ms for 512p;   ~300 ms for 1024p/4U on T5810  
    else
    	% 2D Raster Scanning
        % 3D Raster Scanning
        TP.D.Vol.LayerAbs{i}(...
            TP.D.Exp.BCD.ScanScanInd{i}.Ind                            ) =...
            TP.D.Vol.PixlCol(...
                TP.D.Exp.BCD.ScanScanInd{i}.PixlStart:...
                TP.D.Exp.BCD.ScanScanInd{i}.PixlStop);
    end
    %% Patch the edge
    if strcmp(TP.D.Exp.BCD.ScanMode(6), 's')
        TP.D.Vol.LayerAbs{i}= ... 
            TP.D.Vol.LayerAbs{i};
        TP.D.Vol.LayerAbs{i} = [...
            TP.D.Vol.LayerAbs{i}(end-TP.D.Exp.BCD.ImageNumPixlPerEdge+1:end,	end-TP.D.Exp.BCD.ImageNumPixlPerEdge+1:end ),...
            TP.D.Vol.LayerAbs{i}(end-TP.D.Exp.BCD.ImageNumPixlPerEdge+1:end,	1:end-TP.D.Exp.BCD.ImageNumPixlPerEdge );...
            TP.D.Vol.LayerAbs{i}(1:end-TP.D.Exp.BCD.ImageNumPixlPerEdge,       end-TP.D.Exp.BCD.ImageNumPixlPerEdge+1:end ),...
            TP.D.Vol.LayerAbs{i}(1:end-TP.D.Exp.BCD.ImageNumPixlPerEdge,       1:end-TP.D.Exp.BCD.ImageNumPixlPerEdge )];
    end   
	%% Transpose & Rotate
    if TP.D.Vol.ImageTranspose == 1
        TP.D.Vol.LayerAbsTR{i} = transpose(	TP.D.Vol.LayerAbs{i});
    else
        TP.D.Vol.LayerAbsTR{i} =            TP.D.Vol.LayerAbs{i};
    end
        TP.D.Vol.LayerAbsTR{i} = rot90(TP.D.Vol.LayerAbsTR{i}, TP.D.Vol.ImageRot90Num);
    %% Normalization 'Absolute' or 'Relative' of Display Data
    switch TP.D.Mon.Image.DisplayModeNum
        case 1;	a = 2048;                   b = -8; % -10?              % absolute
        case 2; a = max(TP.D.Vol.PixlCol);  b = min(TP.D.Vol.PixlCol);  % relative
        case 3; a = max(TP.D.Vol.PixlCol);  b = -8; % -10?              % relative-0
        otherwise
    end
        TP.D.Vol.LayerDisp{i}(:,:,2) = uint8(  (TP.D.Vol.LayerAbsTR{i}-b)/(a-b)  *255);
end


