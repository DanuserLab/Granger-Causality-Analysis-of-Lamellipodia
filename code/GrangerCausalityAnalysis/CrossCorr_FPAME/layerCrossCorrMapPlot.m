function [xcorrMatArr, xcmap_figArr] = layerCrossCorrMapPlot(ch1Actmap, ch2Actmap, ch1ActmapName, ch2ActmapName, MDtimeInterval_, varargin)
% layerCrossCorrMapPlot Compute/Draw cross correlation maps between two channels for
% each layer and between layers by utilizing nanXcorrMaps.m function.
%
% Usage:
% [xcorrMat, xcmap_fig] =  layerCrossCorrMapPlot(ch1Actmap, ch2Actmap, ch1ActmapName, ch2ActmapName,  ...
%               MDtimeInterval_, 'smParam', 1, 'fullRange', 1, 'figFlag', 'on');
% INPUT:      
%       ch1Actmap       - A cell with multiple activity maps for
%                       different layers
%
% Jungsik Noh, 2019/03/25

%% intialization
%wmax = size(ch1Actmap{1}, 1);
tmax = size(ch1Actmap{1}, 2);
layerMax = numel(ch1Actmap);

%ip
ip = inputParser;
ip.addParameter('figFlag', 'off');
ip.addParameter('smParam', 1, @isnumeric);
ip.addParameter('lagMax', round(tmax/4), @isnumeric);
ip.addParameter('fullRange', false);

ip.parse(varargin{:});
p = ip.Results;
%figFlag = p.figFlag;


%%  xcmap_parameters

%lagGrid = round(p.lagMax/2);
%xcmapXtick = 1:lagGrid:(p.lagMax*2+1);
%xcmapXticklabel = round((-p.lagMax:lagGrid:p.lagMax) * MDtimeInterval_, 2);

lagMax = p.lagMax;
lagGrid = floor(p.lagMax/2);
xcmapXtick = [1, 1+lagMax-lagGrid, 1+lagMax, 1+lagMax+lagGrid, 1+2*lagMax];
xcmapXticklabel = round( (xcmapXtick-1-lagMax)*MDtimeInterval_, 2);

    
%%  plot per layer

xcorrMatArr = cell(layerMax, layerMax);
xcmap_figArr = cell(layerMax, layerMax);

for indL = 1:layerMax
 for indL2 = 1:layerMax

%    chan1map = reshape(ch1Actmap(:, indL, :), wmax, tmax);
%    chan2map = reshape(ch2Actmap(:, indL, :), wmax, tmax);
    chan1map = ch1Actmap{indL};
    chan2map = ch2Actmap{indL2};
    
  
    %% plotting, May indicate nan existence in the map using xx=0.5
    nanIndex1 = isnan(mean(chan1map(:,:), 2));
    nanIndex2 = isnan(mean(chan2map(:,:), 2));
    nanIndex = (nanIndex1 | nanIndex2)';  % row vector
    alphaIndex = (1 - 0*nanIndex);      % 0.5 or 0

    % nanXcorrMaps() is used.
    xcorrMatArr{indL, indL2}  = nanXcorrMaps(chan1map, chan2map, 'lagMax', p.lagMax);

    thrh0 = 2/sqrt(size(chan1map, 2));
    % smoothing
    if all(isnan(xcorrMatArr{indL, indL2})) 
        filteredmap = nan(size(xcorrMatArr{indL, indL2}));
    else
        filteredmap = smoothActivityMap(xcorrMatArr{indL, indL2}, 'SmoothParam', p.smParam, 'UpSample', 1);
    end
    
    % figure
    title0 = ['xcorr(', ch1ActmapName, '_{t+Lag}, ', ch2ActmapName, '_t)  ', ...
        '(', char(177), sprintf('%0.2f', thrh0), ') - ', num2str(indL), 'L-', num2str(indL2), 'L'];

    xcmap_figArr{indL, indL2} = figure('Visible', p.figFlag); 
    if p.fullRange
        figtmp = imagesc(filteredmap, [-1, 1]);
    else
        figtmp = imagesc(filteredmap);
    end
            
    AlphaData0 = repmat(alphaIndex', 1,  2*p.lagMax+1);
    AlphaData0(isnan(xcorrMatArr{indL, indL2})) = 0;
    figtmp.AlphaData = AlphaData0;
    title(title0);
    colorbar;colormap(jet)
    axis xy;xlabel('Time lag (s)');ylabel('Windows')

    set(gca, 'XTick', xcmapXtick)
    set(gca, 'XTickLabel', {xcmapXticklabel})
    set(gca, 'XGrid', 'on')

 end 
end




end



