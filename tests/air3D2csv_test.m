clear all;
close all;
addpath('..')

load('air3D')
data2D = air3D2csv(g, data, 'air3D.csv', 0);
data2Dh = air3D2csv(g, data, 'air3Dh.csv', 1);

disp(['Difference in data: ' num2str(norm(data2D - data2Dh(2:end,3:end)))])
disp('Expected difference: 0')