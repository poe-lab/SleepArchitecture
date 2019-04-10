function results = StatsByCategory(categoryVector,dataArray)
maxState = max(categoryVector);
results.category = [];
results.sampleSize = [];
results.mean = [];
results.stdDev = [];
results.semPwr = [];
for i = 1:maxState
    dataSet = dataArray(categoryVector == i,:);
    if isempty(dataSet)
    else
        results.category = [results.category; i];
        numOcc = size(dataSet,1);
        results.sampleSize = [results.sampleSize; numOcc];
        meanPwr = mean(dataSet,1);
        results.mean = [results.mean; meanPwr];
        stdDevPwr = std(dataSet,0,1);
        results.stdDev = [results.stdDev; stdDevPwr];
        semPwr = stdDevPwr./sqrt(numOcc);
        results.semPwr = [results.semPwr; semPwr];
    end
end
end