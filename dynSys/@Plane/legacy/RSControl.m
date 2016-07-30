function u = RSControl(obj, BRS, t)
% u = RSControl(obj, BRS)

ind = find(BRS.tau <= t, 1, 'first');
P = extractCostates(BRS.g, BRS.data(:,:,:,ind));
p = calculateCostate(BRS.g, P, obj.x);
u = (p(3) >= 0) * (-BRS.uMax) + (p(3) < 0) * BRS.uMax;

end