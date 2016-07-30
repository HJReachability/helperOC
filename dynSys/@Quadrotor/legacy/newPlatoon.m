% function p = newPlatoon(obj,nmax,followTime)
% % UNUSED
% % Check if vehicle is Free
% if ~strcmp(obj.q,'Free')
%     warning([
%         sprintf('Cannot create new platoon.\n'),...
%         sprintf('\t%s is currently in %s mode.\n',obj.ID,obj.q),...
%         sprintf('\tOnly Free vehicles can create a new platoon.\n')
%         ]);
%     p = [];
%     return
% end
% % Create new platon and switch to 'Leader' mode
% if nargin<2
%     p = platoon(obj);
% elseif nargin<3
%     p = platoon(obj,nmax);
% elseif nargin<4
%     p = platoon(obj,nmax,followTime);
% end
% obj.q = 'Leader';
% obj.platoon = p;
% obj.idx = 1;
% end