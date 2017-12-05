function unplotPosition(obj)
% function unplotPosition(obj)
% Unplot the current state and the trajectory of obj
%
% Qie Hu, 2015-03-20

if ~isempty(obj.hpxpyhist)
    set(obj.hpxpyhist, 'Visible','off');
end

if ~isempty(obj.hpxpy)
    set(obj.hpxpy, 'Visible','off');
end

end