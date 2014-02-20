function [ new_state, prob ] = nlbenchmark_transition( model, state, new_state )
%NLBENCHMARK_TRANSITION Sample and/or calculate transition density for
%nonlinear benchmark.

% state is the earlier state, which has time index kk. new_state is the
% following state. prob is a log-probability.

kk = state(2);
state(2) = [];

% Calculate new_state mean
mn = nlbenchmark_f(model, kk, state);

% Sample state if not provided
if (nargin<3)||isempty(new_state)
    new_state = mvnrnd(mn, model.sigx);
    new_state = [new_state; kk+1];
end

% Calculate probability if required
if nargout>1
    prob = loggausspdf(new_state(1), mn, model.sigx);
else
    prob = [];
end

end

