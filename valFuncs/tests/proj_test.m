function proj_test(whatTest)
% proj_test(whatTest)
%   tests the proj() function

if nargin < 1
  whatTest = 'projTo1-3D';
end

switch whatTest
  case 'projTo1-3D'
    %% Project down to 1 to 3 dimensions
    totalDims = 2:6; % Dimensions to test
    
    % Number of trials for each dimension
    numTrialsPerDim = 9*ones(size(totalDims));
    Ns = [101, 51, 25, 15, 11];
    
    R = 0.75; % Radius of hypersphere for testing
    
    for i = 1:length(totalDims)
      g = createGrid(-ones(totalDims(i),1), ones(totalDims(i),1), ...
        Ns(i)*ones(totalDims(i),1));
      data = shapeSphere(g, zeros(g.dim, 1), R);
      
      figure
      spC = ceil(sqrt(numTrialsPerDim(i)));
      spR = ceil(numTrialsPerDim(i)/spC);
      for j = 1:numTrialsPerDim(i)
        % Which dimensions to project?
        dims = randProj123Dims(totalDims(i));
        
        xs = -0.5*R + R*rand(1, nnz(dims));
        [gOut, dataOut] = proj(g, data, dims, xs);
        
        subplot(spR, spC, j)
        visSetIm(gOut, dataOut);
        title(['totalDims: ' num2str(totalDims(i)) ', [' num2str(xs) '] slice'])
      end
    end
    
  case 'projTo4D'
    %% Project down to 4 dimensions
    totalDims = 4:6;
    numTrialsPerDim = 4*ones(size(totalDims));
    Ns = [25, 15, 11];
    R = 0.75; % Radius of hypersphere for testing
    
    for i = 1:length(totalDims)
      g = createGrid(-ones(totalDims(i),1), ones(totalDims(i),1), ...
        Ns(i)*ones(totalDims(i),1));
      data = shapeSphere(g, zeros(g.dim, 1), R);
      
      for j = 1:numTrialsPerDim(i)
        % Which dimensions to project?
        dims = randProjDims(totalDims(i), 4);
        
        xs = -0.5*R + R*rand(1, nnz(dims));
        [gOut, dataOut] = proj(g, data, dims, xs);
        
        figure
        visSetIm(gOut, dataOut);
        title(['totalDims: ' num2str(totalDims(i)) ', [' num2str(xs) '] slice'])
      end
    end
    
  case 'min_and_max'
    %% Project down to 1 to 3 dimensions
    totalDims = 2:6; % Dimensions to test
    
    % Number of trials for each dimension
    numTrialsPerDim = 9*ones(size(totalDims));
    Ns = [101, 51, 25, 15, 11];
    
    R = 0.75; % Radius of hypersphere for testing
    
    for i = 1:length(totalDims)
      g = createGrid(-ones(totalDims(i),1), ones(totalDims(i),1), ...
        Ns(i)*ones(totalDims(i),1));
      data = shapeSphere(g, zeros(g.dim, 1), R);
      
      figure
      spC = ceil(sqrt(numTrialsPerDim(i)));
      spR = ceil(numTrialsPerDim(i)/spC);
      for j = 1:numTrialsPerDim(i)
        % Which dimensions to project?
        dims = randProj123Dims(totalDims(i));
        
        if rand < 0.5
          xs = 'min';
        else
          xs = 'max';
        end
        
        [gOut, dataOut] = proj(g, data, dims, xs);
        
        subplot(spR, spC, j)
        visSetIm(gOut, dataOut);
        title(['totalDims: ' num2str(totalDims(i)) ...
          ', dims = [' num2str(dims) '], ' xs])
      end
    end
    
  case 'periodic'
    g = createGrid([-1 -1 -pi], [1 1 pi], [51 51 51], 3);
    
    % Radius goes from 0.1 to 0.6
    R = 0.1 + 0.5*(g.xs{3}+pi) / 2 / pi;
    data = sqrt(g.xs{1}.^2 + g.xs{2}.^2) - R;
    
    figure; 
    visSetIm(g, data);
    
    figure;
    N = 25;
    small = 1e-2;
    thetas = linspace(-3*pi, 3*pi - small, N);
    spC = ceil(sqrt(N))+1;
    spR = ceil(N/spC);
    for i = 1:N
      subplot(spR, spC, i)
      [g2D, data2D] = proj(g, data, [0 0 1], thetas(i));
      visSetIm(g2D, data2D);
      axis square
      grid on
      title(sprintf('\\theta = %.2f', thetas(i)))
    end
    
    
  otherwise
    error('Unknown test!')
end
end

function dims = randProj123Dims(totalDim)
% dims = randProjDims(totalDim)
%   Randomly determines which dimensions to project and which ones to keep.
%   Between 1 and 3 dimensions will be kept

% Project down to at most 3 dimensions
dims = randProjDims(totalDim, 3);

% For the remaining dimensions, randomly choose which ones to project
avail_dims = find(~dims);
for i = 1:length(avail_dims)
  % 50 percent chance to project each dimension except dimKept
  if rand < 0.5
    dims(avail_dims(i)) = true;
  end
end

% Make sure at least one dimension is kept
if all(dims)
  dims(randi(totalDim)) = false;
end

end

function dims = randProjDims(totalDim, dimsRemaining)
% Project down to at 4 dimensions

% Determine how many dimensions need to be projected
min_dims_proj = totalDim - dimsRemaining;

% Project the required number of dimensions down, each time randomly
% picking a dimension from the remaining available dimensions to project
dims = false(1, totalDim);
for i = 1:min_dims_proj
  avail_dims = find(~dims);
  idimProj = randi(length(avail_dims));
  dims(avail_dims(idimProj)) = true;
end

end
