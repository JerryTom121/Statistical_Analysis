function Montage=CREx_ExtractMontage(csdFName,eeglabels)

%% EXTRACT THE ELECTRODE MONTAGE

 [lab,theta,phi] = textread(csdFName,'%s %f %f','commentstyle','c++');
    n = 0;
    theta0 = theta;
    phi0 = phi;
    lab0 = lab;
    for e = 1:length(eeglabels)
        ok = 0;
        for f = 1:length(lab)
            if strcmp(upper(char(eeglabels(e,:))),upper(lab(f,:)))
                n = n + 1;
                theta0(e) = theta(f);
                phi0(e) = phi(f);
                lab0(e,:) = eeglabels(e,:);
                ok = 1;
                break
            end
        end
        if ~ ok
            disp(sprintf('*** Error: Label %s undefined in %s',...
                char(eeglabels(e,:)),csdFileName));
            lab0(e,:) = eeglabels(e,:);
            theta0(e) = NaN;
            phi0(e) = NaN;
        end
    end
    theta = theta0(1:length(eeglabels));
    phi = phi0(1:length(eeglabels));
    lab = lab0(1:length(eeglabels),:);
    phiT = 90 - phi;                    % calculate phi from top of sphere
    theta2 = (2 * pi * theta) / 360;    % convert degrees to radians
    phi2 = (2 * pi * phiT) / 360;
    [x,y] = pol2cart(theta2,phi2);      % get plane coordinates
    xy = [x y];
    xy = xy/max(max(xy));               % set maximum to unit length
    xy = xy/2 + 0.5;                    % adjust to range 0-1
    save('C:\Users\bolger\Documents\MATLAB_tools\CSDtoolbox\CSDtoolbox\resource\tmpMontage.mat', 'lab', 'theta', 'phi', 'xy');
    Montage = open('C:\Users\bolger\Documents\MATLAB_tools\CSDtoolbox\CSDtoolbox\resource\tmpMontage.mat');
    delete('C:\Users\bolger\Documents\MATLAB_tools\CSDtoolbox\CSDtoolbox\resource\tmpMontage.mat');
    disp(sprintf('%5s %7s %10s %10s %8s %8s', ...
        '#','Label','theta','phi','X','Y'));
    for e = 1:length(Montage.xy);
        if isnan(theta(e))
            disp(sprintf('%5d %7s %10.3f %10.3f %8.3f %8.3f *** ERROR ***', ...
                e,char(lab(e,:)),theta(e),phi(e),xy(e,:)));
        else
            disp(sprintf('%5d %7s %10.3f %10.3f %8.3f %8.3f', ...
                e,char(lab(e,:)),theta(e),phi(e),xy(e,:)));
        end
    end;
    if ~(n == length(eeglabels))
        Montage = NaN
        disp(sprintf('*** Error: %d assigned <> %d read EEG channel labels',n,length(eeglabels)));
    end;
   
    %% **********************PLOT THE EEG MONTAGE ********************************************************
    
    figure;
    nElec = size(Montage.xy,1);
    set(gcf,'Name',sprintf('%d-channel EEG Montage',nElec),'NumberTitle','off')
    m = 100;
    t = [0:pi/100:2*pi];
    r = m/2 + 0.5;
    head = [sin(t)*r + m/2+1; cos(t)*r + m/2+1]' - m/2;
    scrsz = get(0,'ScreenSize');
    d = min(scrsz(3:4)) / 2;
    set(gcf,'Position',[scrsz(3)/2 - d/2 scrsz(4)/2 - d/2 d d]);
    whitebg('w');
    axes('position',[0 0 1 1]);
    set(gca,'Visible','off');
    line(head(:,1),head(:,2),'Color','k','LineWidth',1);
    mark = '\bullet';
    if nElec > 129; mark = '.'; end;
    l = sqrt((Montage.xy(:,1)-0.5).^2 + (Montage.xy(:,2)-0.5).^2) * 2;
    r = (r - 3.5) / (max(l) / max([max(Montage.xy(:,1)) max(Montage.xy(:,2))]));
    for e = 1:nElec
        text(Montage.xy(e,1)*2*r - r + 0.5,Montage.xy(e,2)*2*r - r + 2.5,mark);
        text(Montage.xy(e,1)*2*r - r + 1, ...
            Montage.xy(e,2)*2*r - r , ...
            Montage.lab(e), ...
            'FontSize',8, ...
            'FontWeight','bold', ...
            'VerticalAlignment','middle', ...
            'HorizontalAlignment','center');
    end


end 