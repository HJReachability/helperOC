function numDims_test()

numTrials = 25;
for i = 1:numTrials
  numDims_test_single();
end

end

function numDims_test_single()
dims = randi(6);
Nmax = 10;
N = 1 + randi(Nmax, dims, 1);

cmdStr = 'rand(';
for i = 1:dims
  cmdStr = cat(2, cmdStr, num2str(N(i)));
  if i < dims
    cmdStr = cat(2, cmdStr, ',');
  else
    if dims == 1
      cmdStr = cat(2, cmdStr, ',1)');
    else
      cmdStr = cat(2, cmdStr, ')');
    end
  end
end

temp = eval(cmdStr);
disp(['dims = ' num2str(dims) ' | numDims = ' num2str(numDims(temp))]);

if dims ~= numDims(temp)
  disp('Something is wrong!')
  keyboard
end
end