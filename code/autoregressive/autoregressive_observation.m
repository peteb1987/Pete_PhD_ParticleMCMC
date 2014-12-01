function [ obs, prob ] = autoregressive_observation( model, state, obs )
%tracking_observation Sample and/or evaluate observation density for the
%autoregressive model.

% prob is a log-probability.

% Calculate observation mean
mn = autoregressive_h(model, state);

% Sample observation if not provided
if (nargin<3)||isempty(obs)
    obs = mn + sqrt(model.sigy)*trnd(model.dof);
end

% Calculate probability if required
if nargout>1
    
    dt = (obs-mn)/sqrt(model.sigy);
    prob = log(tpdf(dt,model.dof));
   
else
    prob = [];
end

end

