function AvgBandPower_xHrBins(batchProcess, timeBinSize) %Set to 0 for Manually scored file or 1 for Auto-Scored file.
% Created by Brooks A. Gross on 04.08.2015 to write to a real Excel file
% Updated on 06.04.2015 to include pop up saying program has completed and 
%   now has built-in batch processing.-BAG
working_dir=pwd;
if batchProcess
    % Select folder and get list of Excel files:
    fileType = '*.xlsx';
    [dataFolder, fileList, numberOfDataFiles] = batchLoadFiles(fileType);
else
    dataFolder = [];
    fileList = [];
    fileSelectedCheck = 0;
    % Select a single file:
    while isequal(fileSelectedCheck,0)
        [fileList, dataFolder] = uigetfile('*.xlsx', 'Select the Spectral Analysis File');
        if isempty(fileList) || isempty(dataFolder)
            uiwait(errordlg('You need to select a file. Please try again',...
                'ERROR','modal'));
        else
            fileSelectedCheck = 1;
        end 
    end
    numberOfDataFiles = 1;
end

for p = 1:numberOfDataFiles
%Load Band Power spreadsheet from Excel (.xlsx) file:
filename = strtrim(fileList(p,:)); %Removes any whites space at end of file name string.
powerSpectraFile = fullfile(dataFolder,filename);
try
    sheet = 'bandPower';
    num = xlsread(powerSpectraFile,sheet);
catch %#ok<*CTCH>
    % If file fails to load, it will notify user and prompt to
    % choose another file.
    uiwait(errordlg('Check if the scored file is saved in Microsoft Excel format.',...
     'ERROR','modal'));
end
%Re-define data into components:
timeStamps = num(3:end,1);
states = num(3:end,2);
bandVector = num(1:2,3:end);
numBands = size(bandVector,2);
bandPwr = num(3:end,3:end);
clear num
%% States are in number format after going through spectral analyses:
startTime = timeStamps(1);
endTime = timeStamps(end);
timeBin = timeBinSize * 3600; %Set time bin size here in seconds (ex. 7200 seconds = 2 hours).
stopTime = startTime + timeBin;
timeBlockIdx = [];
binTS = [];
z = 0;
%Find the indices for the beginning and end of each time bin:
while startTime <= endTime
    if stopTime <= endTime
        z = z + 1;
        idx1 = find(timeStamps(:) >= startTime, 1, 'first');
        idx2 = find(timeStamps(:) <= stopTime, 1, 'last');
        binTS = [binTS; startTime stopTime]; %#ok<*AGROW>
        timeBlockIdx = [timeBlockIdx; idx1 idx2]; 
        startTime = timeStamps(idx2+1);
        stopTime = startTime + timeBin;
    else
        z = z + 1;
        idx1 = find(timeStamps(:) >= startTime, 1, 'first');
        idx2 = find(timeStamps(:) <= endTime, 1, 'last');
        binTS = [binTS; startTime endTime];
        timeBlockIdx = [timeBlockIdx; idx1 idx2];
        startTime = 10 + timeStamps(idx2); %Gets out of the While loop by making sure stopTime > endTime
    end
end
clear z idx1 idx2 startTime stopTime endTime
%Define output variables and allocate size:    
numBins = size(timeBlockIdx,1);
if isequal(numBins,0)
else
    numEpochsBin = zeros(numBins,1);
    sampleSizes = zeros(numBins, 8); %There are 8 scored values.
    meanPerBin = zeros(numBins, 8, numBands);
    stdDevPerBin = zeros(numBins, 8, numBands);
    %SEMperBin = zeros(numBins, 8, numBands);
    %%%%%%%%%%%%%%%
    for m = 1:numBins %analyze per time bin
        idx1 = timeBlockIdx(m,1);
        idx2 = timeBlockIdx(m,2);
        binBandPwr = bandPwr(idx1:idx2,:); %creates a matrix of band powers for all epochs within time bin
        numEpochsBin(m) = size(binBandPwr,1); %finds total # epochs in each time bin
        %--Insert code here if want to record total number of epochs in time bin.
        for n = 1:8 %analyze for each state within each time bin
            stateIdx = find(states(idx1:idx2) == n);
            if isempty(stateIdx)==0
                stateBinBndPwr = binBandPwr(stateIdx,:);
                sampleSizes(m, n) = size(stateIdx,1); % # of epochs of state in time bin
                meanPerBin(m, n, :) = mean(stateBinBndPwr);
                stdDevPerBin(m, n, :) = std(stateBinBndPwr);
            end
        end 
    end
    % Write results to the Excel file:
    warning off MATLAB:xlswrite:AddSheet
    
    resultsFilename = ['C:\Sleepdata\' num2str(timeBinSize) 'HrBinAvg' filename];
    xlswrite(resultsFilename,{'Bin Size (s)'}, 'Sheet1', 'A1');
    xlswrite(resultsFilename, timeBin, 'Sheet1', 'B1');
    
    columnHeaders = {'#EpochsInBin', 'IdxStart', 'IdxStop', 'Start(s)', 'Stop(s)'};
    xlswrite(resultsFilename, columnHeaders, 'Sheet1', 'A3');
    xlswrite(resultsFilename, [numEpochsBin timeBlockIdx binTS], 'Sheet1', 'A4');
    
    columnHeaders = {'AW', 'QS', 'RE', 'QW', 'UH', 'TR', 'NS', 'IW'};
    %Write sample sizes for each state within each time bin:
    xlswrite(resultsFilename, columnHeaders, 'SampleSize', 'A1');
    xlswrite(resultsFilename, sampleSizes, 'SampleSize', 'A2');
    %Write averages and standard deviations for each bandwith on separate
    %sheets:
    for m = 1:numBands
        %Write averages for each state within each time bin for the target bandwidth:
        xlswrite(resultsFilename, columnHeaders, ['Avg_' num2str(bandVector(1,m)) 'to' num2str(bandVector(2,m)) 'Hz'], 'A1');
        xlswrite(resultsFilename, meanPerBin(:,:,m), ['Avg_' num2str(bandVector(1,m)) 'to' num2str(bandVector(2,m)) 'Hz'], 'A2');
        %Write standard deviations for each state within each time bin for the target bandwidth:
        xlswrite(resultsFilename, columnHeaders, ['Std_' num2str(bandVector(1,m)) 'to' num2str(bandVector(2,m)) 'Hz'], 'A1');
        xlswrite(resultsFilename, stdDevPerBin(:,:,m), ['Std_' num2str(bandVector(1,m)) 'to' num2str(bandVector(2,m)) 'Hz'], 'A2');
    end
    
end
end
cd(working_dir);
msgbox(['Average band power by state calculations in ' num2str(timeBinSize) '-h bins have completed.'],'Pop-up');