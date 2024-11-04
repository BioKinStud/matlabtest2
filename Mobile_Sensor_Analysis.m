
%% Load sensor data
load('IQ_Downstairs_1.mat')


% Activities
Activities = {'Walking', 'Running', 'Upstairs', 'Downstairs', 'Sitting', 'Laying', 'Standing'};

for Activ_Num = 1:numel(Activities)
    for Trial_Num = 1:3
        filename = strcat('IQ_', Activities{Activ_Num}, '_', num2str(Trial_Num), '.mat');
        
        % Load sensor data
        load(filename);

        % Compute elapsed time from Timestep variable and add data to timetable
        Elapsed = Acceleration.Timestamp - Acceleration.Timestamp(1);
        Elapsed_Sec = seconds(Elapsed);
        Acceleration.ElapsedTime = Elapsed_Sec;

        % Plot acceleration data
        figure
        subplot(3,1,1)
        plot(Acceleration.ElapsedTime, Acceleration.X)
        xlabel('Elapsed Time (s)'), ylabel('X Acceleration (m/s^2)')

        subplot(3,1,2)
        plot(Acceleration.ElapsedTime, Acceleration.Y)
        xlabel('Elapsed Time (s)'), ylabel('Y Acceleration (m/s^2)')

        subplot(3,1,3)
        plot(Acceleration.ElapsedTime, Acceleration.Z)
        xlabel('Elapsed Time (s)'), ylabel('Z Acceleration (m/s^2)')

        %% Plot orientation data

        % Compute elapsed time from Timestep variable and add data to timetable
        Elapsed = Orientation.Timestamp - Orientation.Timestamp(1);
        Elapsed_Sec = seconds(Elapsed);
        Orientation.ElapsedTime = Elapsed_Sec;

        figure
        subplot(3,1,1)
        plot(Orientation.ElapsedTime, Orientation.X)
        xlabel('Elapsed Time (s)'), ylabel('X Orientation (deg)')

        subplot(3,1,2)
        plot(Orientation.ElapsedTime, Orientation.Y)
        xlabel('Elapsed Time (s)'), ylabel('Y Orientation (deg)')

        subplot(3,1,3)
        plot(Orientation.ElapsedTime, Orientation.Z)
        xlabel('Elapsed Time (s)'), ylabel('Z Orientation (deg)')
    end
end
