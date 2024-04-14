function [uCurr,covar_curr] = upd_step(z_t, covarEst, uEst)
%z_t is the measurement
%covarEst and uEst are the predicted covariance and mean respectively
%uCurr and covar_curr are the updated mean and covariance respectively
C_t = single ([ 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0;
        0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0;
        0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0]);

R = single ([   0.00001, 0, 0;
        0, 0.00002, 0;
        0, 0, 0.00002 ]);

K_t = single((covarEst*(transpose(C_t)))*(inv(C_t*covarEst*(transpose(C_t))+ R)));

% z_t = C_t*state_model_val + [0.001; 0.001; 0.001; 0.001; 0.001; 0.001];

uCurr = single(uEst + K_t*(z_t - C_t*uEst));

covar_curr = single(covarEst - K_t*C_t*covarEst);


end