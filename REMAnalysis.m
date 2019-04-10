function REMAnalysis(batchProcess)
%% Select scored data file(s):
working_dir=pwd;
if batchProcess
    % Select folder and get list of MAT files:
    fileType = '*.xls';
    [dataFolder, fileList, numberOfDataFiles] = batchLoadFiles(fileType);
else
    dataFolder = [];
    fileName = [];
    fileSelectedCheck = 0;
    % Select a single file:
    while isequal(fileSelectedCheck,0)
        [fileName, dataFolder] = uigetfile('*.xls', 'Select the scored data file');
        if isempty(fileName) || isempty(dataFolder)
            uiwait(errordlg('You need to select a file. Please try again',...
                'ERROR','modal'));
        else
            fileSelectedCheck = 1;
        end 
    end
    cd(working_dir);
    numberOfDataFiles = 1;
end
%% Define amount of time allowed in between REM singlets to be considered a REM sequence:
gapTime = [];
while isempty(gapTime)
    prompt={'Enter time in seconds allowed in between REM epochs/singlets to define sequence:'};
    dlgTitle='REM gap time in seconds';
    lineNo=1;
    answer = inputdlg(prompt,dlgTitle,lineNo);
    gapTime = str2double(answer{1,1});
    clear answer prompt dlgTitle lineNo
end
for i = 1:numberOfDataFiles
    if batchProcess
        fileName = strtrim(fileList(i,:)); %Removes any whites space at end of file name string.
    end
    scoredFile = fullfile(dataFolder,fileName);
    %% LOAD SLEEP SCORED DATA
    %Load sleep scored file:
    try
        [numData, stringData] = xlsread(scoredFile);
    catch %#ok<*CTCH>
        uiwait(errordlg('Check if the file is saved in Microsoft Excel format.',...
         'ERROR','modal'));
    end

    %Detect if states are in number or 2-letter format:
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
    

    
    % Create name of output file:
    outputFileName = strrep(scoredFile, '.xls', 'REManalyses.xls');

    startTime = scoredStates(1,1); % First time stamp in the scored file
    stopTime = startTime + 3600; % End time stamp for 1st hour block of time
    endTime = scoredStates(end,1); % Last time stamp in scored file
    z = 0;
    %% Create a cell array of 1 hour blocks of data:
    while stopTime <= endTime
        z = z + 1;
        index1Hr = find(scoredStates(:,1) >= startTime & scoredStates(:,1) <= stopTime);
        OneHrBlock{z} = scoredStates(index1Hr, :);

        startTime = stopTime;
        stopTime = startTime + 3600;

    end
    %% Calculate REM sequences in each 1-hour block of data:
    for i = 1:z
        n = length(OneHrBlock{i}); % # of REM epochs in 1 hour block
        REM = [];
        if OneHrBlock{i}(1,2) == 3
            REM(1,1) = OneHrBlock{i}(1,1);
            REM(1,2) = 1;
            REM(1,3) = 1;
            r = 1;
        else
            r = 0;
        end

        for m = 2:n
            if OneHrBlock{i}(m,2) == 3
                if OneHrBlock{i}(m-1,2) == 3
                    REM(r,2) = REM(r,2) + 1;
                else
                    r = r + 1;
                    REM(r,1) = OneHrBlock{i}(m,1);
                    REM(r,2) = 1;
                end
            end
        end

        singSeqLength = [];
        %REM(1,3) = length(REM(:,1));
        
        % Open the file to save data:
        fid2 = fopen(outputFileName,'a');
        if isempty(REM)
            fprintf(fid2,'No REM in this 1 hour section');
            fprintf(fid2,'\n\n\n');
            fclose(fid2);
        else
            REM(1,3) = length(REM(:,1));
            singlets = REM(1,3);
            sequences = 0;
            inSequence = 0;
            singSeqLength = [REM(1,1) (REM(1,2)*10) 0];

            if REM(1,3) > 2
                p = 1;
                for m = 2:REM(1,3)
                    difference = REM(m,1) - (REM(m-1,1) + 10*REM(m-1,2));
                    if difference > gapTime %Set # of SECONDS (NOT epochs) between REM episodes to count as one sequence.
                        inSequence = 0;
                        p = p + 1;
                        singSeqLength(p,1:3) = [REM(m,1) (REM(m,2)*10) 0];
                    else
                        singlets = singlets - 1;
                        if inSequence == 0
                            sequences = sequences + 1;
                        end
                        singSeqLength(p,2) = REM(m,1) + REM(m,2)*10 - singSeqLength(p,1);
                        singSeqLength(p,3) = 1;
                        inSequence = 1;
                    end

                end
            end
            %% Write data to file:
            fprintf(fid2,'REM Start');
            fprintf(fid2,'\t');
            fprintf(fid2,'REM Length');
            fprintf(fid2,'\t');
            fprintf(fid2,'Total REM Episodes');
            fprintf(fid2,'\t');
            fprintf(fid2,'Avg Epochs/Episode');
            fprintf(fid2,'\n');

            s = REM(1,3);
            for i = 1:s
                fprintf(fid2,num2str(REM(i,1)));
                fprintf(fid2,'\t');
                fprintf(fid2,num2str(REM(i,2)));
                fprintf(fid2,'\t');
                if i == 1
                    fprintf(fid2,num2str(REM(i,3)));
                    fprintf(fid2,'\t');
                    fprintf(fid2,num2str(mean(REM(:,2))));
                    fprintf(fid2,'\n');
                else
                    fprintf(fid2,'\n');
                end
            end

            fprintf(fid2,'\n');
            fprintf(fid2,'Start Time');
            fprintf(fid2,'\t');
            fprintf(fid2,'Length (s)');
            fprintf(fid2,'\t');
            fprintf(fid2,'Type');
            fprintf(fid2,'\n');

            u = length(singSeqLength(:,1));
            for i = 1:u
                fprintf(fid2,num2str(singSeqLength(i,1)));
                fprintf(fid2,'\t');
                fprintf(fid2,num2str(singSeqLength(i,2)));
                fprintf(fid2,'\t');
                if singSeqLength(i,3)==0
                    fprintf(fid2,'Singlet');
                else
                    fprintf(fid2,'Sequenc');
                end
                fprintf(fid2,'\n');
            end
            fprintf(fid2,'Total Singlets');
            fprintf(fid2,'\t');
            fprintf(fid2,'Total Sequences');
            fprintf(fid2,'\n');
            fprintf(fid2, num2str(singlets));
            fprintf(fid2,'\t');
            fprintf(fid2, num2str(sequences));
            fprintf(fid2,'\n\n\n');
            fclose(fid2);
        end
    end
end    
    