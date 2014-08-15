function [ new_state, prob ] = tracking_transition( model, state, new_state )
%tracking_transition Sample and/or evaluate observation density for the
%tracking model.

% prob is a log-probability.

[A, Q, ~] = tracking_AQR(model);

% Calculate new_state mean
mn = A * state;

% Sample state if not provided
if (nargin<3)||isempty(new_state)
    new_state = mvnrnd(mn', Q)';
end

% Calculate probability if required
if nargout>1
    prob = loggausspdf(new_state, mn, Q);
else
    prob = [];
end

end

