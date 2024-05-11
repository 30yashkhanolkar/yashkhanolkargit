clear; % Clear variables
addpath('C:\Users\30yas\Downloads\studentproj3\studentproj3\code\data')
datasetNum = 1; % CHANGE THIS VARIABLE TO CHANGE DATASET_NUM
[sampledData, sampledVicon, sampledTime,proj2Data] = init(datasetNum);

Z = sampledVicon(1:6,:);
% Set initial condition
uPrev = vertcat(sampledVicon(1:9,1),zeros(6,1)); % Copy the Vicon Initial state
covarPrev = 0.1*eye(15); % Covariance constant
savedStates = zeros(15, length(sampledTime)); %Just for saving state his.
prevTime = 0; %last time step in real time
pos = proj2Data.position;
pose = proj2Data.angle;

for i = 1:length(sampledTime)-1
    %% Fill in the FOR LOOP
     
     % We have taken smallest time interval between each iteration

     dt = sampledTime(i+1) - sampledTime(i);

     % Taking the position and orientation information from the data given
     % to us and store it in the measurement model(linear) as a 6X1 matrix

     angVel=sampledData(i).omg;
     acc=sampledData(i).acc;

     x = pos(i,:)';
     y = pose(i,:)';

     z_t=[x;y];

     % Calling the prediction and update step and saving the current values 
     % while listing the current values as the previous values 

     [covarEst,uEst] = pred_step(uPrev,covarPrev,angVel,acc,dt);
     [uCurr,covar_curr] = upd_step(z_t,covarEst,uEst);
     
     savedStates(:,i)=uCurr;
     uPrev=uCurr;
     covarPrev=covar_curr;
     disp(i)
end

plotData(savedStates, sampledTime, sampledVicon, 1, datasetNum);