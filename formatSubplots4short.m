
% Subplot spacing
subP_size = 0.375;
subP_xmin = 0.1;
subP_ymin = 0.275;
subP_xgap = 0.1;
subP_ygap = -0.05;

subP_pos = [subP_xmin               subP_ymin+subP_size+subP_ygap       subP_size subP_size;
    subP_xmin+subP_size+subP_xgap   subP_ymin+subP_size+subP_ygap   subP_size subP_size;
    subP_xmin                       subP_ymin                      subP_size subP_size;
    subP_xmin+subP_size+subP_xgap   subP_ymin                      subP_size subP_size];

for j = 1:4 % Fix defender position
    %     subplot(2,2,j)
    f = gcf;
    sub = f.Children(j+1);
    %     axis equal
    set(sub,'position',subP_pos(5-j,:))
%     
%     if j==1
%         sub.XLim = [0 80];
%         sub.YLim = 0.5*sub.XLim;
%     else
        sub.XLim = [10 65];
        sub.YLim = 0.5*sub.XLim;
%     end

end

pos = get(gcf,'position');
set(gcf,'position',[200 200 600 600]);
set(legend,'units','pixels','position',[200 50 225 100])
% legend('boxoff')