function updateImage3Draster  
% The function processes the raw data in	TP.D.Vol.DataColRaw,
% and puts the processed absolute image to  TP.D.Vol.LayerAbs{i}
% for 3D raster mode

global TP
 
%% Data Formmating & Pixelizing
    TP.D.Vol.DataColFlt = -single(TP.D.Vol.DataColRaw);

    if TP.D.Exp.BCD.ImageNumSmplPerPixl == 1
        TP.D.Vol.PixlCol = TP.D.Vol.DataColFlt;
    else
        TP.D.Vol.PixlSmplMat = ...
            reshape(	TP.D.Vol.DataColFlt,...
                        TP.D.Exp.BCD.ImageNumSmplPerPixl, ...
                        TP.D.Exp.BCD.ImageNumPixlPerUpdt)';
        TP.D.Vol.PixlCol = ...
            mean(       TP.D.Vol.PixlSmplMat,1);
    end
    
%% Splitting different layers
    for i = 1:TP.D.Exp.BCD.ScanNumLayrPerVlme

        % Descanning Image
        TP.D.Vol.LayerAbsRaw{i}(...
            TP.D.Exp.BCD.ScanScanInd{i}.Ind ...
                                            ) =...
            TP.D.Vol.PixlCol(...
                TP.D.Exp.BCD.ScanScanInd{i}.PixlStart:...
                TP.D.Exp.BCD.ScanScanInd{i}.PixlStop);

        % Patch the edge, TBD
        TP.D.Vol.LayerAbs{i}= ... 
            TP.D.Vol.LayerAbsRaw{i};
        
    end          


