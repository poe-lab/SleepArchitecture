function results = calculateBoutLength(scoredStates)
numEpochs = length(scoredStates);

results.boutCategory = scoredStates(1);
results.boutLength = 1;
c=1;
for i = 2:numEpochs
  if   isequal(scoredStates(i), scoredStates(i-1))
      results.boutLength(c) = results.boutLength(c) +1;
  else
      c = c+1;
      results.boutCategory(c) = scoredStates(i);
      results.boutLength(c) = 1;
  end
end

end
