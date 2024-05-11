function [uCurr,covar_curr] = upd_step(z_t,covarEst,uEst)
%% BEFORE RUNNING THE CODE CHANGE NAME TO upd_step
    %% Parameter Definition
    %z_t - is the sensor data at the time step
    %covarEst - estimated covar of the  state
    %uEst - estimated mean of the state

   % Setting the parameters for the Vision pose update in the linear
   % additive case

    C = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
         0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
         0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
         0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
         0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
         0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0];

    R = [ 0.00001, 0, 0, 0, 0, 0;
          0, 0.00001, 0, 0, 0, 0;
          0, 0, 0.00001, 0, 0, 0;
          0, 0, 0, 0.00001, 0, 0;
          0, 0, 0, 0, 0.00001, 0;
          0, 0, 0, 0, 0, 0.00001];

    % The measurement model to find position and orientation is similar to
    % that used in Kalman Filter

    K_t = covarEst*(C')*(inv(C*covarEst*(C') +  R));

    uCurr = uEst + K_t*(z_t - C*uEst);

    covar_curr =  covarEst - K_t*C*covarEst;
 
end

