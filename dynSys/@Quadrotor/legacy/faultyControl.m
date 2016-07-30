function uFaulty = faultyControl(obj, other, safeV)
% function uFaulty = faultyControl(obj, other, safeV)
% Computes faulty control of a faulty quadrotor
%
%faulty QR

%Randomly alternate between worst case control and random control
% r = randi(100,1,1);



%if()
%Find worst controls
uFaulty = worstControl(obj, other, safeV);

%else
%Generate random control
% a = -3;
% b = 3;
% uFaulty = a + (b-a).*rand(1,2)
% uFaulty = [2 0]
% end
end