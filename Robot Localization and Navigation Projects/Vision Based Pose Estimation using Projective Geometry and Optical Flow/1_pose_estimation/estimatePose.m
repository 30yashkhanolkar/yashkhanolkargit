function [position, orientation] = estimatePose(data, t)

%Get the id Data from the samples provided and calling the getCorner
%function to get the corners calculated in that function
id = data(t).id;

res = getCorner(id, data, t);

% We list all the information about the 4 corners along with the center in
% the matrix A which we iterate in the loop for each April Tag
A = [];

for i =1:numel(data(t).id)

% The corner data we found out getCorner function
    x0 = res(1,i);
    y0 = res(2,i);
    x1 = res(3,i);
    y1 = res(4,i);
    x2 = res(5,i);
    y2 = res(6,i);
    x3 = res(7,i);
    y3 = res(8,i);
    x4 = res(9,i);
    y4 = res(10,i);

 % The corner data in pixels provided to us by the camera sensor
    x0_dash = data(t).p0(1,i);
    y0_dash = data(t).p0(2,i);
    x1_dash = data(t).p1(1,i);
    y1_dash = data(t).p1(2,i);
    x2_dash = data(t).p2(1,i);
    y2_dash = data(t).p2(2,i);
    x3_dash = data(t).p3(1,i);
    y3_dash = data(t).p3(2,i);
    x4_dash = data(t).p4(1,i);
    y4_dash = data(t).p4(2,i);


A_con = [x0,   y0,    1,      0,      0,    0,   -x0_dash*x0,   -x0_dash*y0,    -x0_dash;
          0,    0,    0,     x0,     y0,    1,   -y0_dash*x0,   -y0_dash*y0,    -y0_dash;
         x1,   y1,    1,      0,      0,    0,   -x1_dash*x1,   -x1_dash*y1,    -x1_dash;
          0,    0,    0,     x1,     y1,    1,   -y1_dash*x1,   -y1_dash*y1,    -y1_dash;
         x2,   y2,    1,      0,      0,    0,   -x2_dash*x2,   -x2_dash*y2,    -x2_dash;
          0,    0,    0,     x2,     y2,    1,   -y2_dash*x2,   -y2_dash*y2,    -y2_dash;
         x3,   y3,    1,      0,      0,    0,   -x3_dash*x3,   -x3_dash*y3,    -x3_dash;
          0,    0,    0,     x3,     y3,    1,   -y3_dash*x3,   -y3_dash*y3,    -y3_dash;
         x4,   y4,    1,      0,      0,    0,   -x4_dash*x4,   -x4_dash*y4,    -x4_dash;
          0,    0,    0,     x4,     y4,    1,   -y4_dash*x4,   -y4_dash*y4,    -y4_dash ];

   A = [A; A_con];
end

%XYZ = [-0.04, 0.0, -0.03];

% We solve the SVD in the camera frame with the smallest singular value and
% take the 9TH column of V to get h matrix. On this homography we have to
% implement sign function to guarantee solution with positive z
[~, ~, V_c] = svd(A);

h = reshape(V_c(:,9),[3,3]);

H  = (transpose(h))*(sign(V_c(9,9)));


% Camera Matrix (zero-indexed):
K = [311.0520,            0,    201.8724;
            0,     311.3885,    113.6210;
            0,            0,            1   ];

% We find the vectored information of R and T based on K and H matrices
% available to us
R_T_cap = inv(K)*H;

T1 = cross(R_T_cap(1:3,1),R_T_cap(1:3,2));

R1_R2_T = [R_T_cap(1:3,1), R_T_cap(1:3,2), T1];

% We find the SVD in the robot frame and calculate the Final R and T
% matrices
[U_r, ~, V_r] = svd(R1_R2_T);

R  = U_r*[1, 0, 0; 0, 1, 0; 0, 0, det(U_r*(transpose(V_r)))]*(transpose(V_r));

T = R_T_cap(:,3)/norm(R_T_cap(:,1));

% Transformation matrix found according the images provided
T_c_r = [     0.707,     -0.707,       0,     0.04;
             -0.707,     -0.707,       0,        0;
                 0,          0,       -1,    -0.03;
                 0,          0,        0,       1];

% Pose matrix containing required position and orientation information
pose = inv((T_c_r)*([R(1,:), T(1,:); ...
                     R(2,:), T(2,:); ...
                     R(3,:), T(3,:); ...
                      0, 0, 0, 1]));

   
    %% Output Parameter Definition
    
    % position = translation vector representing the position of the
    % drone(body) in the world frame in the current time, in the order ZYX
    position = pose(1:3,4);
    
    % orientation = euler angles representing the orientation of the
    % drone(body) in the world frame in the current time, in the order ZYX
    orientation = rotm2eul(pose(1:3, 1:3));

end