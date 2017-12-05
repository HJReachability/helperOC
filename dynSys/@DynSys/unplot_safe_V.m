function unplot_safe_V(obj)
% function unplotSafeV(obj, others)
%
% Unplot safe region around others that obj must stay out of in order to
% be safe.
%
% Qie Hu, 2015-07-25
% Modified: Mo Chen, 2015-12-13

for i = 1:length(obj.h_safe_V)
  obj.h_safe_V(i).Visible = 'off';
end

end
