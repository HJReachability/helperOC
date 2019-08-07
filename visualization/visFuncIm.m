function [h]= visFuncIm(gPlot,dataPlot,color,alpha)

if gPlot.dim<2
    h = plot(gPlot.xs{1}, squeeze(dataPlot),...
        'LineWidth',2);
    h.Color = color;
elseif gPlot.dim==2
    h = surf(gPlot.xs{1}, gPlot.xs{2}, dataPlot);
    h.EdgeColor = 'none';
    h.FaceColor = color;
    h.FaceAlpha = alpha;
    h.FaceLighting = 'phong';
else
    error('Can not plot in more than 3D!')
end

end
