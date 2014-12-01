function [ block, match_prob ] = autoregressive_blockproposal( algo, model, L, prev_state, next_state, observ, block )
%AUTOREGRESSIVE_BLOCKPROPOSAL

% This is a "bootstrap" proposal, i.e. we sample from a prior conditional
% on hitting the end state. match_prob is the probability of the end state
% given the start state, and is the component needed for the weights

% Prior on disturbance variables
dstrb_mn = zeros(model.dn*L,1);
dstrb_vr = eye(model.dn*L);

% Gramian
A = autoregressive_AQR(model);
G = zeros(model.ds,1); G(1) = sqrt(model.sigx);
Gram = zeros(model.ds,0);
An = A;
for ll = 1:L
    if ~isempty(prev_state) || (ll < L)
        Gram = [An*G, Gram];
        An = A*An;
    else
        Gram = [An*chol(model.x1_vr)', Gram];
        
        % We've got the first state, which is full rank, so we need more dimensions
        dstrb_mn = zeros(model.dn*(L-1)+model.ds,1);
        dstrb_vr = eye(model.dn*(L-1)+model.ds);
    end
end

% Kalman update
if ~isempty(next_state)
    if ~isempty(prev_state) || (ll < L) 
        state_diff = next_state - An*prev_state;
    else
        state_diff = next_state - An*model.x1_mn;
    end
    [dstrb_mn, dstrb_vr, ~, ~, ~, lhood] = kf_update(dstrb_mn, dstrb_vr, state_diff, Gram, G*G');
    dstrb_vr = (dstrb_vr+dstrb_vr')/2;
    match_prob = log(lhood);
else
    match_prob = 0;
end

if isempty(block)
    
    if (algo.L == model.ds-1) && (det(dstrb_vr)<1E-20)
        % Degenerate. "Sample" deterministically.
        dstrb = dstrb_mn;
    else
        % Sample disturbance
        dstrb = mvnrnd(dstrb_mn', dstrb_vr)';
    end
    
    % Make state block
    block = zeros(model.ds, L);
    state = prev_state;
    for ll = 1:L
        if ~isempty(prev_state) || ll > 1
            state = A*state + G*dstrb(ll);
            block(:,ll) = state;
        else
            state = model.x1_mn + chol(model.x1_vr)'*dstrb(1:model.ds);
            block(:,ll) = state;
            dstrb(1:model.ds-1) = [];
        end
    end
    
    % Check we've hit
    if ~isempty(next_state)
        err = next_state - A*state;
        if abs(err(2:end))>1E-7
            error('Missed!');
        end
    end
    
end

end

