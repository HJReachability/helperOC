function computeGradients_test(whatTest)

if nargin < 1
  whatTest = 'sphere';
end

%% Tests if gradients are correctly computed in a numerical sphere
if strcmp(whatTest, 'sphere')
  gmin = ones(3,1);
  gmax = 2*ones(3,1);
  N = 101*ones(3,1);
  g = createGrid(gmin, gmax, N);
  
  R = 0.5;
  numSphere = shapeSphere(g, zeros(3,1), R);
  
  dims = false(g.dim, 1);
  for i = 1:g.dim
    if rand > 0.5
      dims(i) = true;
    end
  end
  
  disp(dims)
  
  numDeriv = computeGradients(g, numSphere, dims);

  error = 0;
    
  for i = 1:g.dim
    if dims(i)
      deriv = g.xs{i} ./ sqrt(g.xs{1}.^2 + g.xs{2}.^2 + g.xs{3}.^2);
      error = error + sqrt(sum((numDeriv{i}(:) - deriv(:)).^2))/prod(N);
    end
  end
  
  fprintf('Average error grid points: %f\n', error);
end

%% Tests if NaNs and infs in original data are preserved in the gradients
if strcmp(whatTest, 'NaN')
  gmin = ones(3,1);
  gmax = 2*ones(3,1);
  N = 101*ones(3,1);
  g = createGrid(gmin, gmax, N);
  
  R = 0.5;
  numSphere = shapeSphere(g, zeros(3,1), R);
  
  numSphere(g.xs{1} >= 1.9) = inf;
  numSphere(g.xs{2} >= 1.9) = nan;
  
  numDeriv = computeGradients(g, numSphere);
  
  fprintf('Number of nans: %d in original data, %d in gradient\n', ...
    nnz(isnan(numSphere)), nnz(isnan(numDeriv{3})))
  fprintf('Number of infs: %d in original data, %d in gradient\n', ...
    nnz(isinf(numSphere)), nnz(isinf(numDeriv{2})))
end

end