function data2D = air3D2csv(g, data3D, output_file, header)
% function data2D = air3D2csv(g, data3D, output_file, header)
%
% Converts a 3D array from the air3D output into a 2D array which is then
% exported as a csv file. Each row in the csv file corresponds to
% data3D(i,j,:) (i.e. the relative x and y positions), and each column
% represents a relative heading.
%
% Inputs: g           - grid structure
%         data3D      - original 3D array from air3D.m output
%         output_file - output file name
%         header      - set to 1 to enable header rows (1) and columns (2)
% Output: data2D      - resulting 2D array (which is saved as csv)
%
% Mo Chen, 2015-10-12

% Index offsets if using header
if header
  roffset = 1;
  coffset = 2;
else
  roffset = 0;
  coffset = 0;
end

% Initialize output data, adding in row header if needed
data2D = zeros(g.N(1)*g.N(2)+roffset, g.N(3)+coffset);
if header
  data2D(1, 1+coffset:end) = g.vs{3}';
end

% Fill in the rest of the rows, adding column headers if needed
for i = 1:g.N(1)
  for j = 1:g.N(2)
    if header
      data2D((i-1)*g.N(2)+j+roffset, 1) = g.vs{1}(i);
      data2D((i-1)*g.N(2)+j+roffset, 2) = g.vs{2}(j);
    end

    data2D((i-1)*g.N(2)+j+roffset, 1+coffset:end) = ...
      squeeze(data3D(i,j,:))';
  end
end

% Output csv file
csvwrite(output_file, data2D);
end