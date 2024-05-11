 function [covarEst,uEst] = pred_step(uPrev,covarPrev,angVel,acc,dt)
%% BEFORE RUNNING THE CODE CHANGE NAME TO pred_step
    %% Parameter Definition
    % uPrev - is the mean of the prev state
    %covarPrev - covar of the prev state
    %angVel - angular velocity input at the time step
    %acc - acceleration at the timestep
    %dt - difference in time 

    % Setting the noise value to be augmented with our data
    
    Q_t = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
           0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
           0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0;
           0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0;
           0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0;
           0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0;
           0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0;
           0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0;
           0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0;
           0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0;
           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0;
           0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1;
        ];
    
    % Setting the previous mean and covariance as the initial state

    u_aug = [uPrev; zeros(12,1)];

    sig_aug = [covarPrev, zeros(15,12); zeros(12,15), Q_t];

    % Using the Cholesky function to derive the square root of the
    % covariance and determining the parameters

    root_sig_aug = chol(sig_aug);

    alpha = 0.001;
    beta = 2;
    k = 1;
    n_prime = 27;   % n_prime = n + q = 15 + 12 = 27

    lambda_prime = (alpha^2)*(n_prime + k) - n_prime;
    
    % Starting the Computation of sigma points  which will result in 55
    % sigma points as  num of sigma points = 2*n_prime + 1

    X_0 = u_aug;

    X_1 = [];
    X_2 = [];
  
    for i = 1:n_prime
  
        X_i_plus = u_aug + sqrt(n_prime + lambda_prime)*(root_sig_aug(:,i));
        X_i_minus = u_aug - sqrt(n_prime + lambda_prime)*(root_sig_aug(:,i));
        X_1 = [X_1, X_i_plus];
        X_2 = [X_2, X_i_minus];
    
    end

    sigma_points = [X_0, X_1, X_2];

    % Propagating the sigma points through the non-linear function f

    for i = 1: (2*n_prime+1)

      P_x = sigma_points(1,i);
      P_y = sigma_points(2,i);
      P_z = sigma_points(3,i);
      phi = sigma_points(4,i);
      theta = sigma_points(5,i);
      tsi = sigma_points(6,i);
      V_x = sigma_points(7,i);
      V_y = sigma_points(8,i);
      V_z = sigma_points(9,i);
      bg = sigma_points(10:12,i);
      ba = sigma_points(13:15,i);
      ng = sigma_points(16:18,i);
      na = sigma_points(19:21,i);
      nbg = sigma_points(22:24,i);
      nba = sigma_points(25:27,i);
      

      Rz = [cos(tsi), -sin(tsi),       0; 
            sin(tsi),  cos(tsi),       0; 
                  0 ,         0,       1];

      Ry = [cos(theta),   0,    sin(theta); 
                     0,   1,             0; 
           -sin(theta),   0,    cos(theta)];

      Rx = [1,           0,           0; 
            0,    cos(phi),   -sin(phi); 
            0,    sin(phi),    cos(phi)];

      R = Rz*Ry*Rx;

      G = [         -sin(theta),            0,     1;
            cos(theta)*sin(phi),     cos(phi),     0;
            cos(theta)*cos(phi),    -sin(phi),     0];

      g = [0; 0; -9.81];

      x_t = [V_x; V_y; V_z; inv(G)*(angVel - bg - ng); g + R*(acc - ba - na); nbg; nba ];

      f(1:15,i) = sigma_points(1:15,i) + dt*x_t;
        
    end

    % Computing the mean and covariance matrices from the derived state
    % parameter values stored in the function f

    Wo_c_prime = (lambda_prime/(n_prime + lambda_prime)) + (1 - alpha^2 + beta);
    Wi_c_prime = 1/(2*(n_prime + lambda_prime));
    Wo_m_prime = lambda_prime/(n_prime + lambda_prime);
    Wi_m_prime = 1/(2*(n_prime + lambda_prime));

     for a = 1:(2*n_prime + 1)
        if a == 1
            uEst = Wo_m_prime*f(:,1);
        else
            uEst = uEst + Wi_m_prime*f(:,a);
        end
    end

    for b = 1:(2*n_prime + 1)
        if b == 1
            covarEst = Wo_c_prime*(f(:,1)-uEst)*(f(:,1)-uEst)';
        else
            covarEst = covarEst + (Wi_c_prime*(f(:,b)-uEst)*(f(:,b)-uEst)');
        end
    end

end

