function StateAnalysis_xHrBins(dataFolder,filename, timeBinSize) %Set to 0 for Manually scored file or 1 for Auto-Scored file.
% Modified by Brooks A. Gross on 06.30.2014 to write to a real Excel file
% 07.01.2014 -- Changed output to break down into detailed percentages
%            -- Files are now named automatically   
%Load sleep scored file:
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
startTime = scoredStates(1,1);
endTime = scoredStates(end,1);
timeBin = timeBinSize * 3600; %Set time bin size here in seconds (ex. 7200 seconds = 2 hours).
stopTime = startTime + timeBin;
z = 0;
while startTime <= endTime
    if stopTime <= endTime
        z = z + 1;
        indexTimeBlock = find(scoredStates(:,1) >= startTime & scoredStates(:,1) <= stopTime);
        timeBlock{z} = scoredStates(indexTimeBlock, :);
        startTime = scoredStates((indexTimeBlock(end)+1), 1);
        stopTime = startTime + timeBin;
    else
        z = z + 1;
        indexTimeBlock = find(scoredStates(:,1) >= startTime & scoredStates(:,1) <= endTime);
        timeBlock{z} = scoredStates(indexTimeBlock, :); 
        startTime = 10 + scoredStates((indexTimeBlock(end)), 1);
    end
end
    
results = zeros(z,10);
percentResults = results;

for i = 1:z
    n = size(timeBlock{i},1);
    results(i, 1) = n;
    results(i, 2) = timeBlock{i}(1,1);
    results(i, 3) = timeBlock{i}(n,1);
    for m = 1:n
        switch timeBlock{i}(m,2)
            case 1 %AW
                results(i,4) = results(i,4) + 1;
            case 2 %QS
                results(i,6) = results(i,6) + 1;
            case 3 %REM
                results(i,8) = results(i,8) + 1;
            case 4 %QW
                results(i,5) = results(i,5) + 1;
            case 5 %UH
                results(i,9) = results(i,9) + 1;
            case 6 %TR
                results(i,7) = results(i,7) + 1;
            case 7 %Not Scored
                results(i,10) = results(i,10) + 1;
            case 8 %IW -Only present if auto-scored and not corrected
                results(i,4) = results(i,4) + 1;
        end
    end
    percentResults(i, 1:3) = results(i, 1:3);
    percentResults(i, 4:10) = 100 * results(i, 4:10)/n;  % Solves for percent of time block spent in Waking, Sleep, and REM.
end
avgResults = sum(results);
avgResults(4:10) = 100 * avgResults(4:10)/avgResults(1);
avgResults(2) = results(1,2);
avgResults(3) = results(z,3);
clear results
results = [percentResults; avgResults];

if isequal(z,0)
    uiwait(errordlg('No states to analyze. Please try again',...
            'ERROR','modal'));
else
    warning off MATLAB:xlswrite:AddSheet
    resultsFilename = ['C:\Sleepdata\Results\stateAnalysis' num2str(timeBinSize) 'Hr' filename];
    xlswrite(resultsFilename,{'Bin Size (s)'}, 'Sheet1', 'A1');
    xlswrite(resultsFilename, timeBin, 'Sheet1', 'B1');
    columnHeaders = {'# EpochsInBin', 'Bin Start', 'Bin Stop', '% A-Wake',...
        '% Q-Wake','% NonREM', '% TR', '% REM', 'Unhooked', 'NotScored'};
    xlswrite(resultsFilename, columnHeaders, 'Sheet1', 'A3');
    xlswrite(resultsFilename, results, 'Sheet1', 'A4'); 
end