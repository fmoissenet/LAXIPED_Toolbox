function signalOut = polyfit_array3(signal,motionIN,motionOUT,type,ptitle,iplot)

for i = 1:size(signal,2)
    
    x1  = motionIN;
    y1  = signal(:,i);  
    idx = find(~isnan(y1));
%     p   = polyfit(x1(idx),y1(idx),order);
%     x2  = motionOUT;
%     y2  = polyval(p,x2);
    f   = fit(x1(idx),y1(idx),type);
    x2  = motionOUT;
    y2  = f(x2);

    if iplot == 1
        figure; hold on;
        title(ptitle);
        plot(x1,y1,'b.');
        plot(x2,y2,'g.');
    end
    
    signalOut(:,i) = y2';
end