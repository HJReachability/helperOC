function dataOut = air3D2csv(values, gradients, filename)

dataOut = zeros(numel(values), 4);

dataOut(:,1) = values(:);

for i = 1:3
  if numel(gradients{i}) ~= numel(values)
    error(['Number of elements in gradient component ' num2str(i) ...
      ' does not match number of elements in value function!'])
  end
  
  dataOut(:,i+1) = gradients{i}(:);
end

csvwrite(filename, dataOut);

end