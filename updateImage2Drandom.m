function updateImage2Drandom
% The function processes the raw data in	TP.D.Vol.DataColRaw,
% and puts the processed absolute image to  TP.D.Vol.LayerAbs{i}
% for 2D random mode

global TP

%% Data Formmating & Pixelizing
    TP.D.Vol.DataColFlt = -single(TP.D.Vol.DataColRaw);  	% 24 ms  256p

    if TP.D.Ses.Image.NumSmplPerPixl == 1
        TP.D.Vol.PixlCol = TP.D.Vol.DataColFlt;
    else  
        TP.D.Vol.PixlSmplMat = ...
            reshape(	TP.D.Vol.DataColFlt,...
                        TP.D.Ses.Image.NumSmplPerPixl,...
                        TP.D.Ses.Image.NumPixlPerUpdt);     % 2 ms 256p
        TP.D.Vol.PixlCol = ...
            mean(       TP.D.Vol.PixlSmplMat,1);            % 14 ms 256p
    end
        
%% Descanning Image
    % Use Unum to locate which part of ScanInd is used in current update
    % Locate which part of current LayerAbs needs to be updated
    % Remember for 2D random access mode
    TP.D.Vol.LayerAbs{1}(...
        TP.D.Ses.Scan.ScanInd{1}.Ind(...
            (TP.D.Trl.Unum-1)* 	TP.D.Ses.Image.NumPixlPerUpdt + 1:...
             TP.D.Trl.Unum*     TP.D.Ses.Image.NumPixlPerUpdt)) =...
        TP.D.Vol.PixlCol;
                                                            % 5 ms 256p
    % TODO: The AOD travel delay
    
%%
% ~50   ms for 2D random 256p       on T5810
% ~300  ms for 2D random 512p       on T5810
% ~300  ms for 2D random 1024p/4U 	on T5810