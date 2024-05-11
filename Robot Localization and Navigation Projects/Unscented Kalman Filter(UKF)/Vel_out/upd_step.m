function [uCurr,covar_curr] = upd_step(z_t,covarEst,uEst)
%% BEFORE RUNNING THE CODE CHANGE NAME TO upd_step
    %% Parameter Definition
    %z_t - is the sensor data at the time step
    %covarEst - estimated covar of the  state
    %uEst - estimated mean of the state

    % Using the Cholesky function to derive the square root of the
    % covariance and determining the parameters, setting noise vt

    R = [0.1, 0, 0;
         0, 0.1, 0;
         0, 0, 0.1];

    alpha = 0.001;
    beta = 2;
    k = 1;
    n_prime = 15;
    lambda_prime = alpha^2*(n_prime + k) - n_prime;

    root_sig_aug = chol(covarEst,"lower");

    %   Computing the sigma points using the uEst and covarEst from the
    %   prediction state

    X_0 = uEst;

    X_1 = [];
    X_2 = [];
  
    for i = 1:n_prime
  
        X_i_plus = uEst + sqrt(n_prime + lambda_prime)*(root_sig_aug(:,i));
        X_i_minus = uEst - sqrt(n_prime + lambda_prime)*(root_sig_aug(:,i));
        X_1 = [X_1, X_i_plus];
        X_2 = [X_2, X_i_minus];
    
    end

    sigma_points = [X_0, X_1, X_2];

    % Calculation the skew symmetric matrix to find out g to derive the
    % measurement Model Zt_i

    R_c_b = [  0.707, -0.707,    0;
              -0.707, -0.707,    0;
                   0,      0,   -1];

    R_b_c =  R_c_b';

    Tr_b_c = [-0.04; 0; -0.03];

    T_b_c = [R_b_c, Tr_b_c;
            0,  0,  0,   1];

    T_c_b =  inv(T_b_c);

    Tr_c_b = T_c_b(1:3,4);

    T_c_b_skew = [0, -Tr_c_b(3), Tr_c_b(2);
                 Tr_c_b(3),  0, -Tr_c_b(1);
                 -Tr_c_b(2), Tr_c_b(1), 0;];

    % Applying the adjoint matrix to move frames from body wrt World to
    % camera wrt to World and calculating z which is applied in the last
    % stage of the update step

    Zt_i = [];

    v_t = [0.0001;0.0001;0.0001];

    for x = 1:(2*n_prime + 1)
        
        orient = (uEst(4:6))';  % Only considering orientation

        R_b_w = eul2rotm(orient);

        R_w_b = inv(R_b_w);

        g_u = R_b_c*R_w_b*sigma_points(7:9,x) - R_b_c*T_c_b_skew*R_c_b*(z_t(4:6));
        
        Zt = g_u + v_t;

        Zt_i =[Zt_i, Zt];

    end

    % Computing the mean, covariance and cross covariance matrices from the derived state
    % parameter values stored in the function z

    Wo_c_prime = (lambda_prime/(n_prime + lambda_prime)) + (1 - alpha^2 + beta);
    Wi_c_prime = 1/(2*(n_prime + lambda_prime));
    Wo_m_prime = lambda_prime/(n_prime + lambda_prime);
    Wi_m_prime = 1/(2*(n_prime + lambda_prime));

    
     for a = 1:(2*n_prime + 1)
        if a == 1
            Zu_t = Wo_m_prime*Zt_i(:,1);
        else
            Zu_t = Zu_t + Wi_m_prime*Zt_i(:,a);
        end
     end
    
    for n = 1:(2*n_prime + 1)
        if n == 1
            C_t = Wo_c_prime*(sigma_points(:,1) - uEst)*(Zt_i(:,1) - Zu_t)';
           
        else
            C_t = C_t + Wi_c_prime*(sigma_points(:,n) - uEst)*(Zt_i(:,n) - Zu_t)';
            

        end
    end

    for m = 1:(2*n_prime + 1)
        if m == 1
            S_t = Wo_c_prime*(Zt_i(:,1) - Zu_t)*(Zt_i(:,1) - Zu_t)';

        else
           
            S_t = S_t + Wi_c_prime*(Zt_i(:,m) - Zu_t)*(Zt_i(:,m) - Zu_t)';

        end
    end

    S_t = S_t + R;

    % Applying basic formula to get current mean and covariance from our
    % estimate results by just pluging in the C_t and S_t values 

    K_t = C_t*(inv(S_t));

    uCurr = uEst + K_t*(z_t(1:3) - Zu_t);

    covar_curr = covarEst - K_t*S_t*K_t';

end


