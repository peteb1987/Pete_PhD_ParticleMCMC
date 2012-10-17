function [ state, prob ] = nlbenchmark_stateprior( model, state )
%NLBENCHMARK_STATEPRIOR Sample and/or calculate state prior density for
%nonlinear benchmark.

% prob is a log-probability.

% Sample state if not provided
if (nargin<2)||isempty(state)
    state = mvnrnd(model.x1_mn, model.x1_vr);
end

% Calculate probability if required
if nargout>1
    prob = loggausspdf(state, model.x1_mn, model.x1_vr);
else
    prob = [];
end

end

