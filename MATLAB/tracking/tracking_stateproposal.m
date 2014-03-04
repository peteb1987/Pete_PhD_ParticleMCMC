function [ state, prob ] = tracking_stateproposal( algo, model, prev_state, next_state, observ, state )
%TRACKING_STATEPROPOSAL Sample and/or calculate proposal density for
%tracking model

[A, Q, R] = tracking_AQR(model);

if ~isempty(prev_state)
    prior_mn = A*prev_state;
    prior_vr = Q;
else
    prior_mn = model.x1_mn;
    prior_vr = model.x1_vr;
end

% %%% EKF-based proposal
% 
% % Point to linearise about
% lin_state = prior_mn;
% 
% % Linearise
% H = tracking_obsjacobian(model, lin_state);
% 
% % Create "augmented observation"
% if ~isempty(next_state) && ~isempty(observ)
%     aug_obs = [next_state; observ];
%     aug_mn = [A*lin_state; tracking_h(model, lin_state)];
%     aug_trans = [A; H];
%     aug_vr = blkdiag(Q, R);
% elseif isempty(next_state) && ~isempty(observ)
%     aug_obs = observ;
%     aug_mn = tracking_h(model, lin_state);
%     aug_trans = H;
%     aug_vr = R;
% elseif ~isempty(next_state) && isempty(observ)
%     aug_obs = next_state;
%     aug_mn = A*lin_state;
%     aug_trans = A;
%     aug_vr = Q;
% end
% 
% % KF update
% [ppsl_mn, ppsl_vr] = ekf_update1(prior_mn, prior_vr, aug_obs, aug_trans, aug_vr, aug_mn);

%%% UKF-based proposal

% Create "augmented observation"
if ~isempty(next_state) && ~isempty(observ)
    aug_obs = [next_state; observ];
    obs_func = @(x, ~) [A*x; tracking_h(model, x)];
    aug_vr = blkdiag(Q, R);
elseif isempty(next_state) && ~isempty(observ)
    aug_obs = observ;
    obs_func = @(x, ~) tracking_h(model, x);
    aug_vr = R;
elseif ~isempty(next_state) && isempty(observ)
    aug_obs = next_state;
    obs_func = @(x, ~) A*x;
    aug_vr = Q;
end

% KF update
[ppsl_mn, ppsl_vr] = ukf_update1(prior_mn, prior_vr, aug_obs, obs_func, aug_vr);

%%%%%

ppsl_vr = (ppsl_vr+ppsl_vr')/2;

% Sample state if not provided
if (nargin<8)||isempty(state)
    state = mvnrnd(ppsl_mn, ppsl_vr)';
end

% Calculate probability if required
if nargout>1
    prob = loggausspdf(state, ppsl_mn, ppsl_vr);
else
    prob = [];
end

end

