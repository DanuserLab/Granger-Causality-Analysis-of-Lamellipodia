function phaseDescriptives_OneChan(MD, iChan, maxLayer, chanName, chanTitle, Mask, samplingBw, figuresDir, varargin)
% phaseDescriptives_OneChan PERFORM fluctuation profiling around onsets of
% a given mask.
%
%
% Updated: 
% Jungsik Noh, 2018/01/30. Figure output are improved. A few figures have .fig format.
% Jungsik Noh, 2017/05/23
% Jungsik Noh, 2016/10/18


ip = inputParser;
ip.addParameter('figFlag', 'off');
ip.addParameter('impute', true);
ip.addParameter('WithN', false);
%ip.addParameter('parpoolNum', 4);
%ip.addParameter('rseed', 'shuffle');
%ip.addParameter('numPerm', 1000);

ip.addParameter('omittedWindows', []);
ip.addParameter('Folding', false);
ip.addParameter('subFrames', []);
ip.addParameter('movingAvgSmoothing', false);


ip.parse(varargin{:});
p = ip.Results;

figFlag = p.figFlag;


%%  figuresDir setup
% figuresDir = fullfile(outDir, figDirName)           %% input
if ~isdir(figuresDir); mkdir(figuresDir); end

tmptext = ['phaseDescriptives_OneChan_', 'inputParser.mat'];
save(fullfile(figuresDir, tmptext), 'p')


%%  getting Maps from channels

%
disp(chanName)
disp(chanTitle)


[fname0, MDpixelSize_, MDtimeInterval_, wmax, tmax, rawActmap, actmap_outl, imActmap, actmap_outlSc] ...
        = mapOutlierImputation(MD, iChan, maxLayer, 'impute', p.impute, 'WithN', p.WithN, ...
                'omittedWindows', p.omittedWindows, 'Folding', p.Folding, ...
                'subFrames', p.subFrames, 'movingAvgSmoothing', p.movingAvgSmoothing); 
            
disp(['== MDpixelSize_: ', num2str(MDpixelSize_), ' =='])
disp(['== MDtimeInterval_: ', num2str(MDtimeInterval_), ' =='])

%
[~, ~, ~, ~, ~, ~, ~, imVelmap, velmap_outlSc] ...
        = mapOutlierImputation(MD, 0, 1, 'impute', p.impute, ...
                'omittedWindows', p.omittedWindows, 'Folding', p.Folding, ...
                'subFrames', p.subFrames, 'movingAvgSmoothing', p.movingAvgSmoothing); 



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Plots 


%%  smoothActivityMap prot/act maps

smParam = 0.1;

fchanSm = cell(1, maxLayer);

for indL = 1:maxLayer

inputmap = imActmap{indL};
alphadata0 = ones(size(inputmap));
alphadata0(~Mask) = 0.2;
alphadata0(isnan(inputmap)) = 0;

smmap = smoothActivityMap(inputmap, 'SmoothParam', smParam, 'UpSample', 1);
fchanSm{indL} = figure('Visible', p.figFlag);
figtmp = imagesc(smmap);
title([chanTitle, '-', num2str(indL), 'L'])
colorbar;colormap(jet)

%figtmp.AlphaData = 1-isnan(inputmap);
figtmp.AlphaData = alphadata0;
axis xy;xlabel('Time (s)');ylabel('Window')
ax = gca;
curTick = ax.XTick;
ax.XTickMode = 'manual';
ax.XTick = curTick+1;
ax.XTickLabel = (curTick)*MDtimeInterval_;

end

%
smParam = 0.9;

fchan = cell(1, maxLayer);

for indL = 1:maxLayer

inputmap = imActmap{indL};
alphadata0 = ones(size(inputmap));
alphadata0(~Mask) = 0.2;
alphadata0(isnan(inputmap)) = 0;

smmap = smoothActivityMap(inputmap, 'SmoothParam', smParam, 'UpSample', 1);
fchan{indL} = figure('Visible', p.figFlag);
figtmp = imagesc(smmap);
title([chanTitle, '-', num2str(indL), 'L'])
colorbar;colormap(jet)

%figtmp.AlphaData = 1-isnan(inputmap);
figtmp.AlphaData = alphadata0;
axis xy;xlabel('Time (s)');ylabel('Window')
ax = gca;
curTick = ax.XTick;
ax.XTickMode = 'manual';
ax.XTick = curTick+1;
ax.XTickLabel = (curTick)*MDtimeInterval_;

end


%%
for indL = 1:maxLayer
    saveas(fchanSm{indL}, fullfile(figuresDir, [chanName, '_Sm_', num2str(indL), 'L.png']), 'png')
end
for indL = 1:maxLayer
    saveas(fchan{indL}, fullfile(figuresDir, [chanName, '_', num2str(indL), 'L.png']), 'png')
end



%%  scaled smoothActivityMap prot/act maps

smParam = 0.1;

fchanSm = cell(1, maxLayer);

for indL = 1:maxLayer

inputmap = actmap_outlSc{indL};
alphadata0 = ones(size(inputmap));
alphadata0(~Mask) = 0.2;
alphadata0(isnan(inputmap)) = 0;

smmap = smoothActivityMap(inputmap, 'SmoothParam', smParam, 'UpSample', 1);
fchanSm{indL} = figure('Visible', p.figFlag);
figtmp = imagesc(smmap);
title(['Zscore-', chanTitle, '-', num2str(indL), 'L'])
colorbar;colormap(jet)

%figtmp.AlphaData = 1-isnan(inputmap);
figtmp.AlphaData = alphadata0;
axis xy;xlabel('Time (s)');ylabel('Window')
ax = gca;
curTick = ax.XTick;
ax.XTickMode = 'manual';
ax.XTick = curTick+1;
ax.XTickLabel = (curTick)*MDtimeInterval_;

end

%
smParam = 1;

fchan = cell(1, maxLayer);

for indL = 1:maxLayer

inputmap = actmap_outlSc{indL};
alphadata0 = ones(size(inputmap));
alphadata0(~Mask) = 0.2;
alphadata0(isnan(inputmap)) = 0;

%smmap = smoothActivityMap(inputmap, 'SmoothParam', smParam, 'UpSample', 1);
smmap = inputmap;
fchan{indL} = figure('Visible', p.figFlag);
figtmp = imagesc(smmap);
title(['Zscore-', chanTitle, '-', num2str(indL), 'L'])
colorbar;colormap(jet)

%figtmp.AlphaData = 1-isnan(inputmap);
figtmp.AlphaData = alphadata0;
axis xy;xlabel('Time (s)');ylabel('Window')
ax = gca;
curTick = ax.XTick;
ax.XTickMode = 'manual';
ax.XTick = curTick+1;
ax.XTickLabel = (curTick)*MDtimeInterval_;

end


%%
for indL = 1:maxLayer
    saveas(fchanSm{indL}, fullfile(figuresDir, ['sc_', chanName, '_Sm_', num2str(indL), 'L.png']), 'png')
end
for indL = 1:maxLayer
    saveas(fchan{indL}, fullfile(figuresDir, ['sc_', chanName, '_', num2str(indL), 'L.png']), 'png')
    saveas(fchan{indL}, fullfile(figuresDir, ['sc_', chanName, '_', num2str(indL), 'L.fig']), 'fig')
end


%%  Onset analysis: (1) onset-map

%onsetOfMask = [nan(wmax, 1), diff(Mask, [], 2)];

tmpMask = Mask; tmpMask(:, 1) = NaN;
onsetOfMask = [nan(wmax, 1), diff(tmpMask, [], 2)];

inputmap = onsetOfMask;
fonsetOfMask = figure('Visible', p.figFlag);
figtmp = imagesc(inputmap);
title(['Onsets of Mask-', chanName])
axis xy;xlabel('Time (s)');ylabel('Window')
%
cmap0 = jet(51);
colorbar;colormap(cmap0([1, 26, 51], :))


figtmp.AlphaData = 1-isnan(inputmap);

ax = gca;
curTick = ax.XTick;
ax.XTickMode = 'manual';
ax.XTick = curTick+1;
ax.XTickLabel = (curTick)*MDtimeInterval_;

%
saveas(fonsetOfMask, fullfile(figuresDir, ['OnsetOfMask_', chanName, '.png']), 'png')
saveas(fonsetOfMask, fullfile(figuresDir, ['OnsetOfMask_', chanName, '.fig']), 'fig')


% Later, rle(onsetOfMask) -> histogram of protrusion/retraction(mask) length


%%  Onset analysis: (2) sampling Zscores around the onset


% moving band width
%samplingBw = 8;

ch0Zsamples = cell(maxLayer, 1);
ch1Zsamples = cell(maxLayer, 1);

[r, c] = find(onsetOfMask == 1);
ind1 = ((c > samplingBw) & (c <= tmax - samplingBw));
r = r(ind1);
c = c(ind1);

for indL = 1:maxLayer
    
    ch0Zsamples{indL} = cell(numel(r), 1);
    ch1Zsamples{indL} = cell(numel(r), 1);
    for k = 1:numel(r)
        timeInt0 = c(k)-samplingBw;
        timeInt1 = c(k)+samplingBw;
        ch0Zsamples{indL}{k} = velmap_outlSc{1}(r(k), timeInt0:timeInt1);
        ch1Zsamples{indL}{k} = actmap_outlSc{indL}(r(k), timeInt0:timeInt1);
    end
end



%% Onset analysis: plot sampled Zscores 

timeAxis = (-samplingBw:1:samplingBw)*MDtimeInterval_;

for indL = 1:maxLayer
    
    mat1 = cell2mat(ch0Zsamples{indL});
    mat2 = cell2mat(ch1Zsamples{indL});
    mat1tmp = mat1(~any(isnan(mat1), 2), :);
    mat2tmp = mat2(~any(isnan(mat2), 2), :);
    lrstd1 = sqrt(diag(long_run_variance(mat1tmp)));
    lrstd2 = sqrt(diag(long_run_variance(mat2tmp)));

    meanTS_fig{indL} = figure('Visible', p.figFlag); 
    s1 = shadedErrorBarV2(timeAxis, mean(mat1, 1, 'omitnan'), 2*lrstd1/sqrt(size(mat1, 1)), ...
        'lineprops', '-r');
    hold on
    s2 = shadedErrorBarV2(timeAxis, mean(mat2, 1, 'omitnan'), 2*lrstd2/sqrt(size(mat2, 1)), ...
        'lineprops', '-b');
    
    title1 = ['Average of locally sampled standardized TS'];
    title0 = [num2str(indL), 'L, bandwidth (lag) around onset: ', num2str(samplingBw)];
    title({title1; title0})
    
    refline([0, 0])
    hold on; h = line([0 0], ylim);
    xlabel('Time (s)');ylabel('Standardized TS')
    legend([s1.mainLine, s2.mainLine], {'Vel', chanName})
end


%% saveas
    for indL = 1:maxLayer
        saveas(meanTS_fig{indL}, fullfile(figuresDir, [chanName, '_meanTS_',  num2str(indL), 'L.png']), 'png')
    end

save(fullfile(figuresDir, [chanName, '-ch0Zsamples.mat']), 'ch0Zsamples');    
save(fullfile(figuresDir, [chanName, '-ch1Zsamples.mat']), 'ch1Zsamples');


%%
disp('==== phaseDescriptives_OneChan is Done! ====')


    
end


