function sleepArchitecture_12052016
working_dir=pwd;
batchProcess = 0;
fileType = '*.xls';
% Question box for batch processing:
choiceBatchProcess = questdlg('Please select analysis:',...
            'Analysis Selection', 'Batch Process', 'Single File','Single File');
switch choiceBatchProcess
    case 'Batch Process'
        % Select folder and get list of Excel files:    
        [dataFolder, fileList, numberOfDataFiles] = batchLoadFiles(fileType);
    case 'Single File'
        % Select a single file:
        dataFolder = [];
        fileList = [];
        fileSelectedCheck = 0;
        while isequal(fileSelectedCheck,0)
            [fileList, dataFolder] = uigetfile(fileType, 'Select the Scored File');
            if isempty(fileList) || isempty(dataFolder)
                uiwait(errordlg('You need to select a file. Please try again',...
                    'ERROR','modal'));
            else
                fileSelectedCheck = 1;
            end 
        end
        numberOfDataFiles = 1;
end
clear choiceBatchProcess

% Dialog box to enter the bin size:
timeBinSize = [];
while isempty(timeBinSize)
    prompt={'Enter time bin size in hours:'};
    dlgTitle='Time Bin Size';
    lineNo=1;
    answer = inputdlg(prompt,dlgTitle,lineNo);
    if isnan(str2double(answer))
    else
        timeBinSize = str2double(answer{1,1});
    end
    clear answer prompt dlgTitle lineNo
end

for p = 1:numberOfDataFiles
    %Load sleep scored spreadsheet from Excel (.xls) file:
    filename = strtrim(fileList(p,:)); %Removes any whites space at end of file name string.
    scoredFile = fullfile(dataFolder,filename);
    try
        [numData, stringData] = xlsread(scoredFile);
    catch %#ok<*CTCH>
        % If file fails to load, it will notify user and prompt to
        % choose another file.
        uiwait(errordlg('Check if the scored file is saved in Microsoft Excel format.',...
         'ERROR','modal'));
    end

    %% Detect if states are in number or 2-letter format:
    if isequal(size(numData,2),3)
        scoredStates = numData(:,2:3);
        clear numData stringData
    else
        scoredStates = numData(:,2);
        clear numData
        stringData = stringData(3:end,3);
        [stateNumber] = stateLetter2NumberConverter(stringData);
        scoredStates = [scoredStates stateNumber];
        clear stateNumber stringData
    end
    %Re-define data into components:
    timeStamps = scoredStates(:,1);
    scoredStates = scoredStates(:,2);

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
        percentPerBin = zeros(numBins, 8);
        numBoutPerBin = zeros(numBins, 8);
        avgBoutLengthBin = zeros(numBins, 8);
        stdDevBoutPerBin = zeros(numBins, 8);
        %SEMperBin = zeros(numBins, 8, numBands);
        %%%%%%%%%%%%%%%
        for m = 1:numBins %analyze per time bin
            idx1 = timeBlockIdx(m,1);
            idx2 = timeBlockIdx(m,2);
            binStates = scoredStates(idx1:idx2); %isolate states for the time bin
            numEpochsBin(m) = size(binStates,1); %finds total # epochs in each time bin
            boutData = calculateBoutLength(binStates);
            boutStats = StatsByCategory(boutData.boutCategory', boutData.boutLength');
            %--Insert code here if want to record total number of epochs in time bin.
            for n = 1:8 %analyze for each state within each time bin
                stateIdx = find(binStates == n);
                if isempty(stateIdx)==0
                    sampleSizes(m, n) = size(stateIdx,1); % # of epochs of state in time bin
                    percentPerBin(m, n) = 100 * sampleSizes(m, n)/numEpochsBin(m);
                    % Collect bout information:
                    target = find(boutStats.category == n);
                    numBoutPerBin(m, n) = boutStats.sampleSize(target);
                    avgBoutLengthBin(m, n) = 10 * boutStats.mean(target);
                    stdDevBoutPerBin(m, n) = 10 * boutStats.stdDev(target);
                end
            end
            clear boutData boutStats
        end
        % Write results to the Excel file:
        warning off MATLAB:xlswrite:AddSheet

        resultsFilename = ['C:\SleepData\SleepArchitecture' num2str(timeBinSize) 'HrBins_' filename];
        xlswrite(resultsFilename,{'Bin Size (s)'}, 'Sheet1', 'A1');
        xlswrite(resultsFilename, timeBin, 'Sheet1', 'B1');
        columnHeaders = {'#EpochsInBin', 'IdxStart', 'IdxStop', 'Start(s)',...
            'Stop(s)', 'AW', 'QS', 'RE', 'QW', 'UH', 'TR', 'NS', 'IW'};
        xlswrite(resultsFilename, columnHeaders, 'Sheet1', 'A3');
        xlswrite(resultsFilename, [numEpochsBin timeBlockIdx binTS percentPerBin], 'Sheet1', 'A4');

        %Write bout stats per time bin for each state:
        columnHeaders = {'Start(s)', 'Stop(s)', 'AW', 'QS', 'RE', 'QW', 'UH', 'TR', 'NS', 'IW'};
        
        xlswrite(resultsFilename,columnHeaders, 'AvgBoutLength_sec', 'A1');
        xlswrite(resultsFilename, [binTS avgBoutLengthBin], 'AvgBoutLength_sec', 'A2');
        
        xlswrite(resultsFilename,columnHeaders, 'stdDevBoutLength', 'A1');
        xlswrite(resultsFilename, [binTS stdDevBoutPerBin], 'stdDevBoutLength', 'A2');
        
        xlswrite(resultsFilename,columnHeaders, 'numBoutsPerBin', 'A1');
        xlswrite(resultsFilename, [binTS numBoutPerBin], 'numBoutsPerBin', 'A2');       
    end
end
cd(working_dir);
msgbox(['State architecture calculations in ' num2str(timeBinSize) '-h bins have complete.'],'Pop-up');