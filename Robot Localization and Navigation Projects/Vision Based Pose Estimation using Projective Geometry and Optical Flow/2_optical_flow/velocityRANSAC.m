function [Vel] = velocityRANSAC(optV,optPos,Z,R_c2w,e)

% Applying the formula for the probability of Hitting inliers

  p_success = 0.99;
  M = 3;
  k = (log(1 - p_success))/(log(1 - (e^M)));

  inliers = 0;

  max_inliers = 0;

% Taking 3 random points and calculate the inliers regarding those points

  for i = 1:k
     pos = randperm(length(optPos),3); 
     p1 = optPos(pos(1,1),:);
     p2 = optPos(pos(1,2),:);
     p3 = optPos(pos(1,3),:);

% Calculating At and Bt, which together gives all the information about the
% selected points

     H_1 = [-1/Z(i),    0,   p1(1,1)/Z(i),   p1(1,1)*p1(1,2),   -(1 + p1(1,1)^2),   p1(1,2);
              0,  -1/Z(i),   p1(1,2)/Z(i),     1 + p1(1,2)^2,   -p1(1,1)*p1(1,2),  -p1(1,1) ];

     H_2 = [-1/Z(i),   0,   p2(1,1)/Z(i),   p2(1,1)*p2(1,2),   -(1 + p2(1,1)^2),   p2(1,2);
              0,  -1/Z(i),   p2(1,2)/Z(i),     1 + p2(1,2)^2,   -p2(1,1)*p2(1,2),  -p2(1,1) ];

     H_3 = [-1/Z(i),    0,   p3(1,1)/Z(i),   p3(1,1)*p3(1,2),   -(1 + p3(1,1)^2),   p3(1,2);
              0,  -1/Z(i),   p3(1,2)/Z(i),     1 + p3(1,2)^2,   -p3(1,1)*p3(1,2),  -p3(1,1) ];

      
     H = [H_1; H_2; H_3];

 % Storing the coordinates of the randomly chosen points and calculating
 % velocity given the coordinates and all relevant information 

  opt_vel = [ optV(2*pos(1,1) - 1); optV(2*pos(1,1)); optV(2*pos(1,2) - 1); optV(2*pos(1,2)); optV(2*pos(1,3) - 1); optV(2*pos(1,3))];

  velocity = pinv(H)*opt_vel;

  % Using the stored values to calculate Hi and P dot i
  
  for a = 1: length(optPos)
       
      H_i = [-1/Z(a),    0,   optPos(a,1)/Z(a),  optPos(a,1)*optPos(a,2),        -(1+optPos(a,1)^2),  optPos(a,2);
                0, -1/Z(a),   optPos(a,2)/Z(a),        (1+optPos(a,2)^2),  -optPos(a,1)*optPos(a,2), -optPos(a,1)];

      p_dot_i = [optV(2*a - 1); optV(2*a)];
  
  % Applying the least square formula to count the number of inliers
  % present for the selected point. The point with the maximum inliers is
  % chosen

      least_square = norm(H_i*velocity - p_dot_i)^2;

      inliers = 0;

      if least_square <= 0.005
                inliers = inliers + 1;
      end
  end

      
        if(inliers >= max_inliers)
               max_inliers = inliers;
               Vel = velocity;
        end
  end
end

