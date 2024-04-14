%% PROJECT 2 VELOCITY ESTIMATION
clear all;
clc;
addpath('../data')

%Change this for both dataset 1 and dataset 4. Do not use dataset 9.
datasetNum = 1;

ransac = 1;

[sampledData, sampledVicon, sampledTime] = init(datasetNum);

%% INITIALIZE CAMERA MATRIX AND OTHER NEEDED INFORMATION

K = [311.0520,            0,    201.8724;
            0,     311.3885,    113.6210;
            0,            0,            1   ];

t = zeros(length(sampledData),1);

for n = 1:length(sampledData)
    t(n) = sampledData(n).t;
end

t = sgolayfilt(t,1,101);

for n = 2:length(sampledData)
    %% Initalize Loop load images
    curr_img = sampledData(n-1).img;
    nxt_img = sampledData(n).img;
    
    %% Detect good points
    curr_pt = detectHarrisFeatures(curr_img,'MinQuality', 0.1);
    good_curr_pt = curr_pt.selectStrongest(100).Location;

    nxt_pt = detectHarrisFeatures(nxt_img, 'MinQuality', 0.1);
    good_nxt_pt = nxt_pt.selectStrongest(100).Location;

     %% Initalize the tracker to the last frame.
    pt_track = vision.PointTracker('MaxBidirectionalError',1);
    
    %% Find the location of the next pts;
    initialize(pt_track, good_curr_pt, curr_img);
    [pts,validity] = pt_track(nxt_img);

    current_image_points = [];
    next_image_points = [];

    for i = 1: length(good_curr_pt)
        cp1 = inv(K)*[good_curr_pt(i,1); good_curr_pt(i,2); 1];
        current_image_points = [current_image_points; cp1(1,1), cp1(2,1)];

        np1 = inv(K)*[pts(i,1); pts(i,2); 1];
        next_image_points = [next_image_points; np1(1,1), np1(2,1)];

    end

    %% Calculate velocity
    % Use a for loop
    V = [];

    for m = 1: length(current_image_points)
        val = [(next_image_points(m,1) - current_image_points(m,1))/(t(n) - t(n - 1)),(next_image_points(m,2) - current_image_points(m,2))/(t(n) -t(n - 1))];
        V = [V; val(1,1);val(1,2)];
    end

    %% Calculate Height
    [position, orientation, R_c2w] = estimatePose(sampledData, n);
    
    T_c_r = [   0.707,     -0.707,       0,     0.04;
               -0.707,     -0.707,       0,        0;
                    0,          0,      -1,    -0.03;
                    0,          0,       0,       1];

    R_c_r = T_c_r(1:3, 1:3);

    t_c_r = T_c_r(1:3,4);

    T_r_c = inv(T_c_r);

    R_r_w = eul2rotm(orientation);

    T_r_w = [R_r_w, position; 0, 0, 0, 1];

    T_c_w =  T_c_r*T_r_w;

    T_w_c = inv(T_c_w);

    R_w_c = T_w_c(1:3,1:3);

     Z = [];

    for num = 1: length(current_image_points)
       z = position(3)/(dot([current_image_points(num,1);current_image_points(num,2);1],-1*R_w_c(:,3)));
       Z= [Z; z];
    end
   
    
    %% RANSAC    
    % Write your own RANSAC implementation in the file velocityRANSAC
    if ransac == 0
        H_1 =[];
         
        for i = 1:length(pts)
            x = current_image_points(i,1);
            y = current_image_points(i,2);

            H1 = [-1/Z(i),    0,  x/Z(i),  x*y, -(1+x^2),  y; 
                     0, -1/Z(i),  y/Z(i),1+y^2,    - x*y, -x];  

            H_1 = [H_1; H1];
           
        end

       V1 = pinv(H_1)*V;
    end
  
    if  ransac == 1
       e = 0.5;
       V1 = velocityRANSAC(V,current_image_points,Z,R_c2w,e);
    end 
    

    %% Thereshold outputs into a range.
    % Not necessary
    
    %% Fix the linear velocity
    % Change the frame of the computed velocity to world frame
     
    skew = [        0,  -T_c_r(3,1),   T_c_r(2,1) ;
              T_c_r(3,1),            0,  -T_c_r(1,1) ;
             -T_c_r(2,1),   T_c_r(1,1),           0 ];

    Transformation = [R_r_w, zeros(3); zeros(3), R_r_w]*[R_c_r, -R_c_r*skew; zeros(3), R_c_r];
    Vel = Transformation*V1;
    
    %% ADD SOME LOW PASS FILTER CODE
    % Not necessary but recommended 
    estimatedV(:,n) = Vel;
    
    %% STORE THE COMPUTED VELOCITY IN THE VARIABLE estimatedV AS BELOW
    estimatedV(:,n) = Vel; % Feel free to change the variable Vel to anything that you used.
    % Structure of the Vector Vel should be as follows:
    % Vel(1) = Linear Velocity in X
    % Vel(2) = Linear Velocity in Y
    % Vel(3) = Linear Velocity in Z
    % Vel(4) = Angular Velocity in X
    % Vel(5) = Angular Velocity in Y
    % Vel(6) = Angular Velocity in Zd
end 

estimatedV(1,:) = sgolayfilt(double(estimatedV(1,:)), 1, 35);
estimatedV(2,:) = sgolayfilt(double(estimatedV(2,:)), 1, 17);
estimatedV(3,:) = sgolayfilt(double(estimatedV(3,:)), 1, 19);
estimatedV(4,:) = sgolayfilt(double(estimatedV(4,:)), 1, 17);
estimatedV(5,:) = sgolayfilt(double(estimatedV(5,:)), 1, 15);
estimatedV(6,:) = sgolayfilt(double(estimatedV(6,:)), 1, 13);


plotData(estimatedV, sampledData, sampledVicon, sampledTime, datasetNum)
