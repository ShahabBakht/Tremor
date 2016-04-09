classdef WristWatchTremor < handle
    
    properties
        Length              % in seconds
        FileLocation
        StartRow            % the first row of acceleration data in the raw csv file
        StartDateTime       % starting date and time for reading data in this format: [Year Month Day Hour Minute Second_acc];
        EndDateTime         % end date and time for reading data in this format: [Year Month Day Hour Minute Second_acc];
        Acceleration        % [X, Y, Z]
        Light               % measured light by the wrist watch within the interval
        CurrentRow
        EndRow
    end
    
    methods
        function WRT = WristWatchTremor(l,loc,row,starttime,endtime)
            WRT.Length = l;
            WRT.FileLocation = loc;
            WRT.StartRow = row;
            WRT.StartDateTime = starttime;
            WRT.EndDateTime = endtime;
            
            if isempty(WRT.Length)
                WRT.Length = etime(endtime,starttime);
            end
            
            
        end
        
        function LoadAcc(WRT)
            
            Stop = false;
            WRT.CurrentRow = WRT.StartRow;
            tinit = WRT.ReadDateTime;
            aX = [];
            aY = [];
            aZ = [];
            lightacc = [];
            
            while ~Stop
                
               WRT.CurrentRow = WRT.CurrentRow + 1;
               t = WRT.ReadDateTime;
               e = etime(t,tinit);
               if e >= WRT.Length
                   Stop = true;
               else
                   Stop = false;
               end
               
               [x, y, z, light] = WRT.ReadXYZLight;
               aX = [aX, x];
               aY = [aY, y];
               aZ = [aZ, z];
               lightacc = [lightacc, light];
               
            end
            
            WRT.Acceleration = [aX; aY; aZ];
            WRT.Light = lightacc;
            WRT.EndRow = WRT.CurrentRow;
        end
        
        function t = ReadDateTime(WRT)
            
            % read the date and time from the csv file
            Row = WRT.CurrentRow;
            filename = WRT.FileLocation;
            delimiter = ',';
            startRow = Row;
            endRow = Row;
            
            formatSpec = '%s%*s%*s%*s%*s%*s%*s%[^\n\r]';
            
            fileID = fopen(filename,'r');
            textscan(fileID, '%[^\n\r]', startRow-1, 'ReturnOnError', false);
            dataArray = textscan(fileID, formatSpec, endRow-startRow+1, 'Delimiter', delimiter, 'ReturnOnError', false);
            
            fclose(fileID);
            DeviceType = dataArray{:, 1};
            
            clearvars filename delimiter startRow endRow formatSpec fileID dataArray ans;
            
            % Change the date and time to standard format
            
            Year = str2double(DeviceType{1}(1:4));
            Month = str2double(DeviceType{1}(6:7));
            Day = str2double(DeviceType{1}(9:10));
            Hour = str2double(DeviceType{1}(12:13));
            Minute = str2double(DeviceType{1}(15:16));
            Second = str2double(DeviceType{1}(18:19));
            mSecond = str2double(DeviceType{1}(21:23));
            Second_acc = Second + mSecond/1000;
            
            t = [Year Month Day Hour Minute Second_acc];
            
            
        end
        
        function [x, y, z, light] = ReadXYZLight(WRT)
            
            % read the date and time from the csv file
            Row = WRT.CurrentRow;
            filename = WRT.FileLocation;
            delimiter = ',';
            startRow = Row;
            endRow = Row;
            
            formatSpec = '%s%f%f%f%f%*s%*s%[^\n\r]';
            
            fileID = fopen(filename,'r');
            textscan(fileID, '%[^\n\r]', startRow-1, 'ReturnOnError', false);
            dataArray = textscan(fileID, formatSpec, endRow-startRow+1, 'Delimiter', delimiter, 'ReturnOnError', false);
            
            fclose(fileID);
            x = dataArray{:, 2};
            y = dataArray{:, 3};
            z = dataArray{:, 4};
            light = dataArray{:, 5};
            
            clearvars filename delimiter startRow endRow formatSpec fileID dataArray ans;
            
        end
        
              
        
    end
end