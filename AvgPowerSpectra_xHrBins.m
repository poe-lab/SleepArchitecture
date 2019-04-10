function AvgPowerSpectra_xHrBins(batchProcess, timeBinSize) %Set to 0 for Manually scored file or 1 for Auto-Scored file.
% Created by Brooks A. Gross on 04.08.2015 to write to a real Excel file
% Updated on 06.04.2015 to include pop up saying program has completed.
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
%Load power spectra spreadsheet from Excel (.xlsx) file:
filename = strtrim(fileList(p,:)); %Removes any whites space at end of file name string.
powerSpectraFile = fullfile(dataFolder,filename);
try
    [~,sheets]= xlsfinfo(powerSpectraFile);
catch %#ok<*CTCH>
    % If file fails to load, it will notify user and prompt to
    % choose another file.
    uiwait(errordlg('Check if the scored file is saved in Microsoft Excel format.',...
     'ERROR','modal'));
end
sheet = 'PowerSpectra';
for i=1:size(sheets,2)
    if isequal(findstr(sheets{1,i}, 'fixedPower'),1)
        sheet = 'fixedPower';
    end
end
num = xlsread(powerSpectraFile,sheet);
%Re-define data into components:
timeStamps = num(2:end,1);
states = num(2:end,2);
freqVector = num(1,3:end);
numBands = size(freqVector,2);
powerForSpectra = num(2:end,3:end);
clear num
%% States are in number format after going through spectral analyses:
startTime = timeStamps(1);
endTime = timeStamps(end);
timeBin = timeBinSize * 3600; %Set time bin size here in seconds (ex. 7200 seconds = 2 hours).
if isequal(timeBin,0)
    stopTime = endTime;
else
    stopTime = startTime + timeBin;
end
timeBlockIdx = [];
binTS = [];
z = 0;
%Find the indices for the beginning and end of each time bin:
while startTime <= endTime
    if stopTime < endTime
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
    meanPerBin = zeros(numBins, numBands, 8);
    stdDevPerBin = zeros(numBins, numBands, 8);
    %SEMperBin = zeros(numBins, 8, numBands);
    %%%%%%%%%%%%%%%
    for m = 1:numBins %analyze per time bin
        idx1 = timeBlockIdx(m,1);
        idx2 = timeBlockIdx(m,2);
        binPwrSpectra = powerForSpectra(idx1:idx2,:); %creates a matrix of band powers for all epochs within time bin
        numEpochsBin(m) = size(binPwrSpectra,1); %finds total # epochs in each time bin
        %--Insert code here if want to record total number of epochs in time bin.
        for n = 1:8 %analyze for each state within each time bin
            stateIdx = find(states(idx1:idx2) == n);
            if isempty(stateIdx)==0
                stateBinPwrSpectra = binPwrSpectra(stateIdx,:);
                sampleSizes(m, n) = size(stateIdx,1); % # of epochs of state in time bin
                meanPerBin(m, :, n) = mean(stateBinPwrSpectra);
                stdDevPerBin(m, :, n) = std(stateBinPwrSpectra);
            end
        end 
    end
    % Write results to the Excel file:
    warning off MATLAB:xlswrite:AddSheet
    
    resultsFilename = ['C:\Sleepdata\' num2str(timeBinSize) 'HrBinSpectra' filename];
    xlswrite(resultsFilename,{'Bin Size (s)'}, 'Sheet1', 'A1');
    xlswrite(resultsFilename, timeBin, 'Sheet1', 'B1');
    columnHeaders = {'#EpochsInBin', 'IdxStart', 'IdxStop', 'Start(s)', 'Stop(s)'};
    xlswrite(resultsFilename, columnHeaders, 'Sheet1', 'A3');
    xlswrite(resultsFilename, [numEpochsBin timeBlockIdx binTS], 'Sheet1', 'A4');
    
    %Write frequency information to a sheet:
    sheetName = 'info';
    columnHeaders = {'Power_Spectra(uV^2/Hz)'};
    xlswrite(resultsFilename,columnHeaders, sheetName, 'A1');
    columnHeaders = {'Frequency(Hz)'};
    xlswrite(resultsFilename,columnHeaders, sheetName, 'A2');
    clear columnHeaders
    xlswrite(resultsFilename,freqVector', sheetName, 'A3');
    
    %Write sample sizes for each state within each time bin:
    xlswrite(resultsFilename, sampleSizes, 'SampleSize', 'A1');
    
    %Write spectra averaged per time bin for each state:
    sheetNames = {'AW', 'QS', 'RE', 'QW', 'UH', 'TR', 'NS', 'IW'};
    for i = 1:size(sheetNames,2)
        sheetName = ['Avg_' sheetNames{1,i}];
        %Write averaged power spectra to sheet:
        data = meanPerBin(:, :, i);
        xlswrite(resultsFilename, data, sheetName, 'A3');
        sheetName = ['Std_' sheetNames{1,i}];
        %Write standard deviation of power spectra average to sheet:
        data = stdDevPerBin(:, :, i);
        xlswrite(resultsFilename,data, sheetName, 'A3');
    end    
end
end
cd(working_dir);
msgbox(['Average power spectra by state calculations in ' num2str(timeBinSize/3600) '-h bins have complete.'],'Pop-up');