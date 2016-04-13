function RunTremorLaser()

close all
f = figure('Name','Tremor Measurement');

txt1 = uicontrol('Style','text',...
    'Position',[200 50 210 40],...
    'String','Which test are you running?');

lst = uicontrol('Style','listbox',...
    'Max',1, ...
    'Position',[200 10 200 60], ...
    'String',{'Rest_Left','Posture_Left','Rest_Right','Posture_Right'},...
    'Callback',@twoOnly);
    function twoOnly(h,~)
        oldValues = get(h,'UserData');
        newValues = get(h,'Value');
        if numel(newValues) > 2
            newValues = oldValues;
        end
        set(h,'Value',newValues)
        set(h,'UserData',newValues)
        
    end

plot([]);ylabel('distance (cm)');xlabel('time (ms)')
set(gca,'Position',[.3 .35 .6 .6]); grid on; box off

% close;
% 
% bg = uibuttongroup('Visible','off',...
%                   'Position',[0 0 .2 1],...
%                   'SelectionChangedFcn',@bselection);

bg = uibuttongroup('Visible','off',...
                  'Position',[0 0 .2 1]);
              
% Create three radio buttons in the button group.

r0 = uicontrol(bg,'Style',...
                  'radiobutton',...
                  'String','trial number',...
                  'Position',[10 350 100 30],...
                  'HandleVisibility','off');
              
r1 = uicontrol(bg,'Style',...
                  'radiobutton',...
                  'String','1',...
                  'Position',[10 300 100 30],...
                  'HandleVisibility','off');
              
r2 = uicontrol(bg,'Style','radiobutton',...
                  'String','2',...
                  'Position',[10 250 100 30],...
                  'HandleVisibility','off');
              
r3 = uicontrol(bg,'Style','radiobutton',...
                  'String','3',...
                  'Position',[10 200 100 30],...
                  'HandleVisibility','off');
bg.Visible = 'on';


btn = uicontrol('Style', 'togglebutton', 'String', 'Start',...
        'Position', [20 20 50 20],...
        'Callback', @StartLaser); 
%     function bselection(source,callbackdata)
%         display(['Previous Trial: ' callbackdata.OldValue.String]);
%         display(['Current Trial: ' callbackdata.NewValue.String]);
%         display('------------------');
%         CurrentTrial = (callbackdata.NewValue.String);
%         
%         
%         
%     end

    function StartLaser(source,callbackdata)
        CurrentTrial = bg.SelectedObject.String;
        switch lst.Value
            case 1
                CurrentCondition = 'Rest_Left';
            case 2
                CurrentCondition = 'Posture_Left';
            case 3
                CurrentCondition = 'Rest_Right';
            case 4
                CurrentCondition = 'Posture_Right';
        end
        
        
        options.channel=9;
        options.count=3500;
        options.f=100;
        options.range=0;
        options.immediate = 1;
        
        i = 0; Stop = false;
        params=DaqAInScanBegin(5,options);
        t = GetSecs;
        while ~Stop
            i = i + 1;
            % v(i)=DaqAIn(5,9,0,0);
            params=DaqAInScanContinue(5,options);
            if (GetSecs - t) > 30
                Stop = true;
            end
        end
        params=DaqAInScanContinue(5,options);
        [data,params]=DaqAInScanEnd(5,options);
        
        % [data,params]=DaqAInScan(5,options);
        save([CurrentCondition,'_',CurrentTrial,'.mat'],'data')
        %         eval([CurrentCondition,'_',callbackdata.NewValue.String,' = data;']);
%         close all
        plot(data);
    end

end


