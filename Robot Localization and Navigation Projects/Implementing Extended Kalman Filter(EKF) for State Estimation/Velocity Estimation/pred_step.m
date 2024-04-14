function [covarEst,uEst] = pred_step(uPrev, covarPrev, process_model_val, At_val, Ut_val, dt)
%covarPrev and uPrev are the previous mean and covariance respectively
%At_Val and Ut_Val are jacobian  results from linearlization
% process_model_val is the process model matrix
%dt is the sampling time

f = process_model_val;

uEst = single(uPrev + dt*f);

F_t = single(eye(15) + dt*At_val);

Q = single([    0.01, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
         0, 0.01, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
         0, 0, 0.01, 0, 0, 0, 0, 0, 0, 0, 0, 0;
         0, 0, 0, 0.01, 0, 0, 0, 0, 0, 0, 0, 0;
         0, 0, 0, 0, 0.01, 0, 0, 0, 0, 0, 0, 0;
         0, 0, 0, 0, 0, 0.01, 0, 0, 0, 0, 0, 0;
         0, 0, 0, 0, 0, 0, 0.01, 0, 0, 0, 0, 0;
         0, 0, 0, 0, 0, 0, 0, 0.01, 0, 0, 0, 0;
         0, 0, 0, 0, 0, 0, 0, 0, 0.01, 0, 0, 0;
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0.01, 0, 0;
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.01, 0;
         0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0.01   ]);

Q_d = single(Q*dt);

covarEst = single(F_t*covarPrev*(transpose(F_t)) + Ut_val*Q_d*(transpose(Ut_val)));

end

