% Close all and clear workspace
close all
clear
clc
% Initialize variables that will store concatenated data and features
Data_Table_All = table;
% Activities
Activities = {'Walking' 'Running' 'Upstairs' 'Downstairs' 'Sitting' 'Laying' 'Standing'};
for Activ_Num = 1:numel(Activities)
    for Trial_Num = 1:3
        %% Load sensor data
        filename = strcat(['IQ_' Activities{Activ_Num} '_' num2str(Trial_Num) '.mat']);
        load(filename)
        %% Plot Sensor Data
        % Plot acceleration data
        PlotSensorData(Acceleration, "Acceleration", " (m/s^2)")
        % Plot magnetic field
        PlotSensorData(MagneticField, "Magnetic Field", " (microT)")
        % Plot orientation
        PlotSensorData(Orientation, "Orientation", " (deg)")
        % Plot angular velocity
        PlotSensorData(AngularVelocity, "Angular Velocity", " (rad/s)")
        %% Combine Sensor Data
        % This section of code first converts your sensor measurements from
        % the timetable data type that is exported from your phone to a
        % standard table. This table contains the X, Y, and Z values for
        % each variable and a new variable called ElapsedTime that contains
        % the elapsed time from the beginning of the recording.
        % Convert timetable data to standard tables
        Accel_Table = SensorTimeTable2Table(Acceleration);
        MagField_Table = SensorTimeTable2Table(MagneticField);
        Orientation_Table = SensorTimeTable2Table(Orientation);
        AngVel_Table = SensorTimeTable2Table(AngularVelocity);
        % Some phones do not have a consistent sampling rate. Some data
        % points may be space 1 ms apart while others are spaced 2 ms
        % apart. To address this potential problem, we will resample the
        % data (lines 54 - 80) so that each variable has an equal number of
        % observations and uniform spacing between consecutive
        % measurements. Note that there is a local function at the end of
        % the script called ResampleSensorData that performs this
        % processing step for each variable.
        % Determine the maximum time for which each sensor was recorded
        Max_Accel_Time = max(Accel_Table.ElapsedTime);
        Max_MagField_Time = max(MagField_Table.ElapsedTime);
        Max_Orientation_Time = max(Orientation_Table.ElapsedTime);
        Max_AngVel_Time = max(AngVel_Table.ElapsedTime);
        % Find the shortest (in time) set of sensor data
        Min_Time = min([Max_Accel_Time ...
            Max_MagField_Time ...
            Max_Orientation_Time...
            Max_AngVel_Time]);


        Accel_Table = ResampleSensorData(Accel_Table, Min_Time);
        Accel_Table.Properties.VariableNames = {'Accel_X' 'Accel_Y' 'Accel_Z' 'ElapsedTime'};
        % Resample magnetic field signals
        MagField_Table = ResampleSensorData(MagField_Table, Min_Time);
        MagField_Table.Properties.VariableNames = {'MagField_X' 'MagField_Y' 'MagField_Z' 'ElapsedTime'};
        % Resample orientation signals
        Orientation_Table = ResampleSensorData(Orientation_Table, Min_Time);
        Orientation_Table.Properties.VariableNames = {'Orientation_X' 'Orientation_Y' 'Orientation_Z' 'ElapsedTime'};
        % Resample angular velocity signals
        AngVel_Table = ResampleSensorData(AngVel_Table, Min_Time);
        AngVel_Table.Properties.VariableNames = {'AngVel_X' 'AngVel_Y' 'AngVel_Z' 'ElapsedTime'};
        %% Here, we combine the data from all sensors into a single table 
        % This last column of this table contains a number that corresponds
        % to the activity the participant performed.
        % Concatenate signals into a single table
        Data_Table = [Accel_Table(:,1:3) ...
            MagField_Table(:,1:3) ...
            Orientation_Table(:,1:3) ...
            AngVel_Table(:,1:3) ...
            array2table(Activ_Num*ones(size(Accel_Table,1),1),'VariableNames',{'Activity'})];
        Data_Table_All = [Data_Table_All; Data_Table];
    end
end
%--------------------------------------------------------------------------
function Data = ResampleSensorData(Data, Duration)
Data_Array = table2array(Data);
New_Elapsed_Time = 0:0.01:Duration;
Data_Array = interp1(Data_Array(:,4), Data_Array, New_Elapsed_Time);
Data = array2table(Data_Array,'VariableNames',Data.Properties.VariableNames);
end
%--------------------------------------------------------------------------
function Data_Table = SensorTimeTable2Table(Data)
% Compute elapsed time from Timestep variable and add data to timetable
Elapsed = Data.Timestamp - Data.Timestamp(1);
Elapsed_Sec = seconds(Elapsed);
Data.ElapsedTime = Elapsed_Sec;
% Convert timetable to table
Data_Table = timetable2table(Data);
% Remove timestamp variable
Data_Table = removevars(Data_Table,'Timestamp');
end
%--------------------------------------------------------------------------
function PlotSensorData(Data, Variable_Name_String, Units_String)
% Compute elapsed time from Timestep variable and add data to timetable
Elapsed = Data.Timestamp - Data.Timestamp(1);
Elapsed_Sec = seconds(Elapsed);
Data.ElapsedTime = Elapsed_Sec;
figure
set(gcf,'Name',Variable_Name_String,'NumberTitle','off')
subplot(3,1,1)
plot(Data.ElapsedTime, Data.X)
ylabel_text = strcat("X ", Variable_Name_String, Units_String);
xlabel('Elapsed Time (s)'), ylabel(ylabel_text)
subplot(3,1,2)
plot(Data.ElapsedTime, Data.Y)
ylabel_text = strcat("Y ", Variable_Name_String, Units_String);
xlabel('Elapsed Time (s)'), ylabel(ylabel_text)
subplot(3,1,3)
plot(Data.ElapsedTime, Data.Z)
ylabel_text = strcat("Z ", Variable_Name_String, Units_String);
xlabel('Elapsed Time (s)'), ylabel(ylabel_text)
end
