function [ obs_mean ] = nlbenchmark_h( model, state )
%NLBENCHMARK_H Nonlinear function giving the mean of the current
%observation for the nonlinear benchmark

obs_mean = 0.05 * abs(state)^model.alpha;

end
