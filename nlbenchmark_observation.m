function [ obs, prob ] = nlbenchmark_observation( model, state, obs )
%NLBENCHMARK_OBSERVATION Sample and/or calculate observation density for
%nonlinear benchmark.

% prob is a log-probability.

% Calculate observation mean
mn = nlbenchmark_h(model, state);

% Sample observation if not provided
if (nargin<3)||isempty(obs)
    obs = mvnrnd(mn, model.sigy);
end

% Calculate probability if required
if nargout>1
    prob = loggausspdf(obs, mn, model.sigy);
else
    prob = [];
end

end

