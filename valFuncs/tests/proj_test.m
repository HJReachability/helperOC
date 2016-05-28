function proj_test()
totalDims = [3 4];
Ns = [9 9];

R = 0.75;
for i = 1:length(totalDims)
  g = createGrid(-ones(totalDims(i),1), ones(totalDims(i),1), ...
    25*ones(totalDims(i),1));
  data = shapeSphere(g, [0;0;0], R);
  
  figure
  spC = ceil(sqrt(Ns(i)));
  spR = ceil(Ns(i)/spC);
  for j = 1:Ns(i)
    
    
    xs = -R + 2*R*rand(1, nnz(dims));
    [gOut, dataOut] = proj(g, data, dims, xs);
    
    subplot(spR, spC, j)
    visSetIm(gOut, dataOut);
    title(['totalDims: ' num2str(totalDims(i)) ', [' num2str(xs) '] slice'])
  end
end
end

function dims = randProjDims(totalDim)
dimKept = randi(totalDim); % Do not project this dimension
dims = false(1, totalDim);
for k = 1:totalDim
  % 50 percent chance to project each dimension except dimKept
  if k ~= dimKept && rand < 0.5
    dims(k) = true;
  end
end
end
