% Close all and clear workspace
close all
clear
clc

% Initialize variables that will be used to store concatenated data and
% features
Data_Table_All = table;
Features_All = [];

% Activities
Activities = {'Laying' 'Sitting' 'Walking' 'Upstairs' 'Downstairs' 'Standing' 'Running'};

for Activ_Num = 1:numel(Activities)
    for Trial_Num = 1:3
        filename = strcat(['IQ_' Activities{Activ_Num} '_' num2str(Trial_Num) '.mat']);

        try
            load(filename)
            disp(strcat(['Loading ' filename]))
        catch
            warning(strcat(['No file available named ' filename]))
        end

        % Convert timetable data to standard tables
        try
            Accel_Table = SensorTimeTable2Table(Acceleration);
            MagField_Table = SensorTimeTable2Table(MagneticField);
            Orientation_Table = SensorTimeTable2Table(Orientation);
            AngVel_Table = SensorTimeTable2Table(AngularVelocity);
        catch
            warning(strcat(['Incomplete dataset for file ' filename]))
        end

        % Some phones do not have a consistent sampling rate. Some data
        % points may be spaced 1 ms apart while others are spaced 2 ms
        % apart. To address this potential problem, we will resample the
        % data so that each variable has an equal number of
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

        % Resample acceleration signals
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

        % Concatenate signals into a single table
        Data_Table = [Accel_Table(:,1:3) ...
            MagField_Table(:,1:3) ...
            Orientation_Table(:,1:3) ...
            AngVel_Table(:,1:3) ...
            array2table(Activ_Num*ones(size(Accel_Table,1),1),'VariableNames',{'Activity'})];
        Data_Table_All = [Data_Table_All; Data_Table];

        % Extract the following signal features for each 250 ms window:
        % min, max, standard deviation, average, and median. Note that the
        % observations in Data_Table_All are each 10 milliseconds apart.

        Num_Windows = floor(size(Data_Table,1)/25);
        features = zeros(Num_Windows,61);

        for Window_Number = 1:Num_Windows
            first_row = 1 + 25*(Window_Number - 1);
            last_row = 25*Window_Number;
            features(Window_Number,:) = [min(Data_Table{first_row:last_row,1:12})...
                max(Data_Table{first_row:last_row,1:12}) ...
                std(Data_Table{first_row:last_row,1:12}) ...
                mean(Data_Table{first_row:last_row,1:12}) ...
                median(Data_Table{first_row:last_row,1:12}) ...
                Activ_Num];
        end
        Features_All = [Features_All; features];
    end
end
