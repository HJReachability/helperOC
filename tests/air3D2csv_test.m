clear all;
close all;

load('air3D_simulation')
addpath('..')

filename = 'air3D_simulation.csv';
dataOut = air3D2csv(data, P, filename);