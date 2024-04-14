%clear; % Clear variables
datasetNum = 1; % CHANGE THIS VARIABLE TO CHANGE DATASET_NUM
[sampledData, sampledVicon, sampledTime] = init(datasetNum);
Z = single(sampledVicon(7:9,:));%all the measurements that you need for the update
% Set initial condition
uPrev = single(vertcat(sampledVicon(1:9,1),zeros(6,1))); % Copy the Vicon Initial state
covarPrev = eye(15); % Covariance constant
savedStates = single(zeros(15, length(sampledTime))); %J ust for saving state his.
prevTime = 0; %last time step in real time

% Picking up the data from the vicon data file
xPos = single(vicon(1,:));
yPos = single(vicon(2,:));
zPos = single(vicon(3,:));
xOrient = single(vicon(4,:));
yOrient = single(vicon(5,:));
zOrient = single(vicon(6,:));
xVel = single(vicon(7,:));
yVel = single(vicon(8,:));
zVel = single(vicon(9,:));
xBg = single(vicon(10,:));
yBg = single(vicon(11,:));
zBg = single(vicon(12,:));

% Initialize an empty cell array to store the values of the 'omg' field
omgValues = cell(1, numel(data));

% Loop over each element of the structure array and extract the 'omg' field
for i = 1:numel(data)
    % Access the 'omg' field of the current struct and store it
    omgValues{i} = data(i).omg;
end

% Now, omgValues contains the values of the 'acc' field from each element

% Initialize an empty cell array to store the values of the 'acc' field
accValues = cell(1, numel(data));

% Loop over each element of the structure array and extract the 'acc' field
for i = 1:numel(data)
    % Access the 'omg' field of the current struct and store it
    accValues{i} = data(i).acc;
end

% Now, accValues contains the values of the 'acc' field from each element
 
syms phi theta tsi dphi dtheta dtsi Pos_x Pos_y Pos_z vel_x vel_y vel_z ...
    angVel_x angVel_y angVel_z acc_x acc_y acc_z bg_x bg_y bg_z ba_x ba_y ...
    ba_z nba_x nba_y nba_z nbg_x nbg_y nbg_z ng_x ng_y ng_z na_x na_y ...
    na_z g_x g_y g_z

% Obtaining R and W from euler-angle parameterization
Rz = [cos(phi), -sin(phi),       0; 
      sin(phi),  cos(phi),       0; 
            0 ,         0,       1];

Ry = [cos(theta),   0,    sin(theta); 
               0,   1,             0; 
     -sin(theta),   0,    cos(theta)];

Rx = [1,           0,           0; 
      0,    cos(tsi),   -sin(tsi); 
      0,    sin(tsi),    cos(tsi)];

Rzyx = Rz*Ry*Rx;

G = [1,          0,             -sin(theta);
     0,   cos(tsi),     cos(theta)*sin(tsi);
     0,  -sin(tsi),     cos(theta)*cos(tsi)];

% Giving symbolic definition to all variable in order to be able to
% linearize the model through jacobian
angVel = [angVel_x; angVel_y; angVel_z];

acc = [acc_x; acc_y; acc_z];

bg = [bg_x; bg_y; bg_z];

ba = [ba_x; ba_y; ba_z];

nba = [nba_x; nba_y; nba_z];

nbg = [nbg_x; nbg_y; nbg_z];

ng = [ng_x; ng_y; ng_z];

na = [na_x; na_y; na_z];

g  = [g_x;g_y;g_z];

% indicating the assumptions for the process model
W = (inv(G))*(angVel - bg - ng);

accn = g + Rzyx*(acc - ba - na);

state_model = vertcat([Pos_x; Pos_y; Pos_z; tsi; theta; phi; vel_x; vel_y; vel_z; bg; ba]);

process_model = [vel_x; vel_y; vel_z; W; accn; nbg; nba];

noise = [ng; na; nbg; nba];

% Apply jacobian for linearization

At = jacobian(process_model,state_model);

Ut = jacobian(process_model,noise);

u_Prev = uPrev;

%write your code here calling the pred_step.m and upd_step.m functions
for i = 1:(length(sampledTime)-1)

    dt = sampledTime(i+1) - sampledTime(i);

    % Obtaining the numerical value from the dataset given
    x_Pos = single(xPos(:,i));
    y_Pos = single(yPos(:,i));
    z_Pos = single(zPos(:,i));
    tsi_x = single(xOrient(:,i));
    theta_y = single(yOrient(:,i));
    phi_z = single(zOrient(:,i));
    x_Vel = single(xVel(:,i));
    y_Vel = single(yVel(:,i));
    z_Vel = single(zVel(:,i));
    ang_vel = single(cell2mat(omgValues(:,i)));
    accel = single(cell2mat((accValues(:,i)))); 

    %[bgx, bgy, bgz, bax, bay, baz, ngx, ngy, ngz, nax, nay, naz, nbgx ...
    % , nbgy, nbgz, nbax, nbay, nbaz] = deal(0.1);

    orient = single([tsi_x; theta_y; phi_z]);


    R_z = single([cos(phi_z), -sin(phi_z),           0; 
           sin(phi_z),  cos(phi_z),           0; 
                   0 ,           0,           1]);

    R_y = single([cos(theta_y),   0,    sin(theta_y); 
                   0,      1,               0; 
         -sin(theta_y),   0,     cos(theta_y)]);

    R_x = single([1,            0,              0; 
          0,    cos(tsi_x),    -sin(tsi_x); 
          0,    sin(tsi_x),    cos(tsi_x)]);

    R_val = single(R_z*R_y*R_x);

    G_val = single([1,          0,             -sin(theta_y);
         0,   cos(tsi_x),     cos(theta_y)*sin(tsi_x);
         0,  -sin(tsi_x),     cos(theta_y)*cos(tsi_x)]);

    b_g = single([0.1; 0.1; 0.1]);

    b_a = single([0.1; 0.1; 0.1]);

    nb_a = single([0.1; 0.1; 0.1]);

    nb_g = single([0.1; 0.1; 0.1]);

    n_g = single([0.1; 0.1; 0.1]);

    n_a = single([0.1; 0.1; 0.1]);

    g_val = single([9.81; 9.81; 9.81]);

    noise_val_zero = single([0;0;0;0;0;0;0;0;0;0;0;0]);

    W_val = single((inv(G_val))*(ang_vel - b_g - n_g));

    accn_val = single(g_val + R_val*(accel - b_a - n_a));

    state_model_val = single([x_Pos; y_Pos; z_Pos; tsi_x; theta_y; phi_z; x_Vel; y_Vel; z_Vel; b_g; b_a]);

    process_model_val = single([x_Vel; y_Vel; z_Vel; W_val; accn_val; nb_g; nb_a]);

    % Subs command helps to map the numerical value on the symbolic
    % function in case of jacobian
    At_val = single(subs(At, [state_model(:); angVel(:); acc(:); noise(:)], [u_Prev; ang_vel; accel; noise_val_zero]));

    Ut_val = single(subs(Ut, [state_model(:); angVel(:); acc(:); noise(:)], [u_Prev; ang_vel; accel; noise_val_zero]));

    [covarEst,uEst] = pred_step(uPrev,covarPrev, process_model_val, At_val, Ut_val, dt);

    %Updating the measurement model
    z_t = Z(:,i);

    [uCurr,covar_curr] = upd_step(z_t, covarEst, uEst);

    u_Prev = uCurr;
    covarPrev = covar_curr;

 % Saving the current state in a matrix as the previous state
    velx = xVel(1,i);
    vely = yVel(1,i);
    velz = zVel(1,i);
    tsix = xOrient(1,i);
    thetay = yOrient(1,i);
    phiz = zOrient(1,i);
    
    [bgx, bgy, bgz, bax, bay, baz, ngx, ngy, ngz, nax, nay, naz, nbgx, nbgy, nbgz, nbax, nbay, nbaz] = deal(0.1);
    
    saved_state = single(subs(uCurr, [vel_x(:), vel_y(:), vel_z(:), tsi,theta, phi, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1], ...
        [velx, vely, velz, tsix, thetay, phiz, bgx, bgy, bgz, bax, bay, baz, ngx, ngy, ngz ]));

    disp(i);

    savedStates(:, i) = saved_state;
    % savedStates(:,i) = [x_Pos; y_Pos; z_Pos; tsi_x; theta_y; phi_z; x_Vel; y_Vel; z_Vel; 0.1; 0.1; 0.1; 0.1; 0.1; 0.1 ];
    
end
plotData(single(savedStates), single(sampledTime), single(sampledVicon), 1, datasetNum);