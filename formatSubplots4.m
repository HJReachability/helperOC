
% Subplot spacing
subP_size = 0.375;
subP_xmin = 0.1;
subP_ymin = 0.2;
subP_xgap = 0.1;
subP_ygap = 0;

subP_pos = [subP_xmin               subP_ymin+subP_size+subP_ygap       subP_size subP_size;
    subP_xmin+subP_size+subP_xgap   subP_ymin+subP_size+subP_ygap   subP_size subP_size;
    subP_xmin                       subP_ymin                      subP_size subP_size;
    subP_xmin+subP_size+subP_xgap   subP_ymin                      subP_size subP_size];

for j = 1:4 % Fix defender position
%     subplot(2,2,j)
    f = gcf;
    gca = f.Children(j+1);
    set(gca,'position',subP_pos(5-j,:))
end

pos = get(gcf,'position');
set(gcf,'position',[200 200 600 800]);
set(legend,'units','pixels','position',[200 10 225 150])
% legend('boxoff')