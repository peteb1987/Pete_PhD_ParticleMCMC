function [ new_state, prob ] = autoregressive_transition( model, state, new_state )
%tracking_transition Sample and/or evaluate observation density for the
%autoregressive model.

% prob is a log-probability.

[A, Q, ~] = autoregressive_AQR(model);

% Calculate new_state mean
mn = A * state;

% Sample state if not provided
if (nargin<3)||isempty(new_state)
    new_state = mvnrnd(mn', Q)';
end

% Calculate probability if required
if nargout>1
    if max(abs(new_state(2:end)-mn(2:end))) < 1E-7
        prob = loggausspdf(new_state(1), mn(1), Q(1,1));
    else
        prob = -inf;
    end
else
    prob = [];
end

end

