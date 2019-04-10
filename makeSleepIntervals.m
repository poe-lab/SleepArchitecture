%Read in data from Brook's file. First row is nans bc of file format, next
%rows have data.
[brooksFile, brooksPath, brooksIndex] = uigetfile('.xls');
brooksFileFull = fullfile(brooksPath, brooksFile);
sleepData = xlsread(brooksFileFull);
%Sort Sleep Data based on State Number
catInd1 = 1;
catInd2 = 1;
catInd3 = 1;
catInd4 = 1;
catInd5 = 1; 
catInd6 = 1;
catInd7 = 1;
[numRows, numCols] = size(sleepData);
for j=1:numRows
    if sleepData(j,3) == 1
        cat1(catInd1) = sleepData(j,2);
        catInd1 = catInd1 + 1; 
    elseif sleepData(j,3) == 2
        cat2(catInd2) = sleepData(j,2);
        catInd2 = catInd2 + 1;
    elseif sleepData(j,3) == 3
        cat3(catInd3) = sleepData(j,2);
        catInd3 = catInd3 + 1;
    elseif sleepData(j,3) == 4
        cat4(catInd4) = sleepData(j,2);
        catInd4 = catInd4 + 1;
    elseif sleepData(j,3) == 5
        cat5(catInd5) = sleepData(j,2);
        catInd5 = catInd5 + 1;
    elseif sleepData(j,3) == 6
        cat6(catInd6) = sleepData(j,2);
        catInd6 = catInd6 + 1;
    else
        cat7(catInd7) = sleepData(j,2);
        catInd7 = catInd7 + 1;
    end
end
%checks existence of category and consolidate intervals in each category
if exist('cat1')
    [cat1Rows, cat1Cols] = size(cat1);
    rowIndex = 1;
    conCat1(rowIndex, 1) = cat1(1,1);
    for j=1:(cat1Cols-1)
        if cat1(1, j+1)-cat1(1,j) > 11 
           conCat1(rowIndex, 2) = cat1(1,j)+10;
           rowIndex = rowIndex + 1;
           conCat1(rowIndex, 1) = cat1(1, j+1);
        end
    end
    conCat1(rowIndex,2) = cat1(1, j+1)+10;
    rowIndex = rowIndex + 1;
    for j=rowIndex:5000
        conCat1(j, 1) = NaN;
        conCat1(j, 2) = NaN;
    end
    xlswrite(brooksFileFull, conCat1, 'F2:G5000');
end

if exist('cat2')
    [cat2Rows, cat2Cols] = size(cat2);
    rowIndex = 1;
    conCat2(rowIndex, 1) = cat2(1,1);
    for j=1:(cat2Cols-1)
        if cat2(1, j+1)-cat2(1,j) > 11 
           conCat2(rowIndex, 2) = cat2(1,j)+10;
           rowIndex = rowIndex + 1;
           conCat2(rowIndex, 1) = cat2(1, j+1);
        end
    end
    conCat2(rowIndex,2) = cat2(1, j+1)+10;
    rowIndex = rowIndex + 1;
    for j=rowIndex:5000
        conCat2(j, 1) = NaN;
        conCat2(j, 2) = NaN;
    end
    xlswrite(brooksFileFull, conCat2, 'I2:J5000');
end

if exist('cat3')
    [cat3Rows, cat3Cols] = size(cat3);
    rowIndex = 1;
    conCat3(rowIndex, 1) = cat3(1,1);
    for j=1:(cat3Cols-1)
        if cat3(1, j+1)-cat3(1,j) > 11 
           conCat3(rowIndex, 2) = cat3(1,j)+10;
           rowIndex = rowIndex + 1;
           conCat3(rowIndex, 1) = cat3(1, j+1);
        end
    end
    conCat3(rowIndex,2) = cat3(1, j+1)+10;
    rowIndex = rowIndex + 1;
    for j=rowIndex:5000
        conCat3(j, 1) = NaN;
        conCat3(j, 2) = NaN;
    end
    xlswrite(brooksFileFull, conCat3, 'L2:M5000');
end

if exist('cat4')
    [cat4Rows, cat4Cols] = size(cat4);
    rowIndex = 1;
    conCat4(rowIndex, 1) = cat4(1,1);
    for j=1:(cat4Cols-1)
        if cat4(1, j+1)-cat4(1,j) > 11 
           conCat4(rowIndex, 2) = cat4(1,j)+10;
           rowIndex = rowIndex + 1;
           conCat4(rowIndex, 1) = cat4(1, j+1);
        end
    end
    conCat4(rowIndex,2) = cat4(1, j+1)+10;
    rowIndex = rowIndex + 1;
    for j=rowIndex:5000
        conCat4(j, 1) = NaN;
        conCat4(j, 2) = NaN;
    end
    xlswrite(brooksFileFull, conCat4, 'O2:P5000');
end


if exist('cat5')
    [cat5Rows, cat5Cols] = size(cat5);
    rowIndex = 1;
    conCat5(rowIndex, 1) = cat5(1,1);
    for j=1:(cat5Cols-1)
        if cat5(1, j+1)-cat5(1,j) > 11 
           conCat5(rowIndex, 2) = cat5(1,j)+10;
           rowIndex = rowIndex + 1;
           conCat5(rowIndex, 1) = cat5(1, j+1);
        end
    end
    conCat5(rowIndex,2) = cat5(1, j+1)+10;
    rowIndex = rowIndex + 1;
    for j=rowIndex:5000
        conCat5(j, 1) = NaN;
        conCat5(j, 2) = NaN;
    end
    xlswrite(brooksFileFull, conCat5, 'R2:S5000');
end

if exist('cat6')
    [cat6Rows, cat6Cols] = size(cat6);
    rowIndex = 1;
    conCat6(rowIndex, 1) = cat6(1,1);
    for j=1:(cat6Cols-1)
        if cat6(1, j+1)-cat6(1,j) > 11 
           conCat6(rowIndex, 2) = cat6(1,j)+10;
           rowIndex = rowIndex + 1;
           conCat6(rowIndex, 1) = cat6(1, j+1);
        end
    end
    conCat6(rowIndex,2) = cat6(1, j+1)+10;
    rowIndex = rowIndex + 1;
    for j=rowIndex:5000
        conCat6(j, 1) = NaN;
        conCat6(j, 2) = NaN;
    end
    xlswrite(brooksFileFull, conCat6, 'U2:V5000');
end

if exist('cat7')
    [cat7Rows, cat7Cols] = size(cat7);
    rowIndex = 1;
    conCat7(rowIndex, 1) = cat7(1,1);
    for j=1:(cat7Cols-1)
        if cat7(1, j+1)-cat7(1,j) > 11 
           conCat7(rowIndex, 2) = cat7(1,j)+10;
           rowIndex = rowIndex + 1;
           conCat7(rowIndex, 1) = cat7(1, j+1);
        end
    end
    conCat7(rowIndex,2) = cat7(1, j+1)+10;
    rowIndex = rowIndex + 1;
    for j=rowIndex:5000
        conCat7(j, 1) = NaN;
        conCat7(j, 2) = NaN;
    end
    xlswrite(brooksFileFull, conCat7, 'X2:Y5000');
end 

xlswrite(brooksFileFull, '1', 'F1:F1');

xlswrite(brooksFileFull, '2', 'I1:I1');

xlswrite(brooksFileFull, '3', 'L1:L1');

xlswrite(brooksFileFull, '4', 'O1:O1');

xlswrite(brooksFileFull, '5', 'R1:R1');

xlswrite(brooksFileFull, '6', 'U1:U1');

xlswrite(brooksFileFull, '7', 'X1:X1');





