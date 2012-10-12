function [ next_state_mean ] = nlbenchmark_f( model, kk, state )
%NLBENCHMARK_F Nonlinear function giving the predictive mean of the next
%state for the nonlinear benchmark

next_state_mean = model.beta1 * state + model.beta2 * (state/(1+state^2)) + model.beta3 * cos(1.2*kk);

end

