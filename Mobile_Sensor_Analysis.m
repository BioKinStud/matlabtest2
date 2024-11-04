% Load sensor data
load('IQ_Downstairs_1.mat')

% Activities
Activities = {'Walking', 'Running', 'Upstairs', 'Downstairs', 'Sitting', 'Laying', 'Standing'};

% Initialize variables to store the largest ranges and corresponding activities and files
largestAccelRange = 0;
largestOrientRange = 0;
largestAngVelRange = 0;
largestMagFieldRange = 0;
activityAccel = '';
activityOrient = '';
activityAngVel = '';
activityMagField = '';
fileAccel = '';
fileOrient = '';
fileAngVel = '';
fileMagField = '';
trialAccel = 0;
trialOrient = 0;
trialAngVel = 0;
trialMagField = 0;

for Activ_Num = 1:numel(Activities)
    for Trial_Num = 1:3
        filename = strcat('IQ_', Activities{Activ_Num}, '_', num2str(Trial_Num), '.mat');
        
        % Load sensor data
        load(filename);

        % Compute elapsed time from Timestep variable and add data to timetable
        Elapsed = Acceleration.Timestamp - Acceleration.Timestamp(1);
        Elapsed_Sec = seconds(Elapsed);
        Acceleration.ElapsedTime = Elapsed_Sec;

        % Calculate range for acceleration on x axis
        accelRange = max(Acceleration.X) - min(Acceleration.X);
        if accelRange > largestAccelRange
            largestAccelRange = accelRange;
            activityAccel = Activities{Activ_Num};
            fileAccel = filename;
            trialAccel = Trial_Num;
        end

        % Compute elapsed time from Timestep variable and add data to timetable
        Elapsed = Orientation.Timestamp - Orientation.Timestamp(1);
        Elapsed_Sec = seconds(Elapsed);
        Orientation.ElapsedTime = Elapsed_Sec;

        % Calculate range for orientation on x axis
        orientRange = max(Orientation.X) - min(Orientation.X);
        if orientRange > largestOrientRange
            largestOrientRange = orientRange;
            activityOrient = Activities{Activ_Num};
            fileOrient = filename;
            trialOrient = Trial_Num;
        end

        % Calculate range for angular velocity on x axis (assuming AngularVelocity data exists)
        angVelRange = max(AngularVelocity.X) - min(AngularVelocity.X);
        if angVelRange > largestAngVelRange
            largestAngVelRange = angVelRange;
            activityAngVel = Activities{Activ_Num};
            fileAngVel = filename;
            trialAngVel = Trial_Num;
        end

        % Calculate range for magnetic field on x axis (assuming MagneticField data exists)
        magFieldRange = max(MagneticField.X) - min(MagneticField.X);
        if magFieldRange > largestMagFieldRange
            largestMagFieldRange = magFieldRange;
            activityMagField = Activities{Activ_Num};
            fileMagField = filename;
            trialMagField = Trial_Num;
        end
    end
end

% Display the results
fprintf('Activity with Largest Acceleration Range on X-axis: %s (%.2f) in file %s (Trial %d)\n', activityAccel, largestAccelRange, fileAccel, trialAccel);
fprintf('Activity with Largest Orientation Range on X-axis: %s (%.2f) in file %s (Trial %d)\n', activityOrient, largestOrientRange, fileOrient, trialOrient);
fprintf('Activity with Largest Angular Velocity Range on X-axis: %s (%.2f) in file %s (Trial %d)\n', activityAngVel, largestAngVelRange, fileAngVel, trialAngVel);
fprintf('Activity with Largest Magnetic Field Range on X-axis: %s (%.2f) in file %s (Trial %d)\n', activityMagField, largestMagFieldRange, fileMagField, trialMagField);
