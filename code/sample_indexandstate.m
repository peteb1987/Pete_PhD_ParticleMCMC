function [ index, state, bess ] = sample_indexandstate( algo, model, kk, pf_kk, init_index, init_state, next_state, observ )
%SAMPLE_INDEXANDSTATE Sample an ancestor and a state for a single time
%instant from their joint posterior. This is the main step in the
%improved backward simulation particle Gibbs algorithm.

N = algo.N;
K = model.K;

% The state we're sampling is for time kk+1. pf_kk is the particle filter
% output from time kk.
    
% Create some arrays
interm_state = zeros(model.ds, N);
interm_weight = zeros(1, N);
interm_index = zeros(1, N);

% First particle is the reference
interm_state(:,1) = init_state;
interm_index(1) = init_index;

% Sample new indexes for each other particle
if kk > 0
    interm_index(2:end) = sample_weights(pf_kk.weight, N-1);
end
for ii = 1:N
    
    % Get previous state
    if kk > 0
        prev_state = pf_kk.state(:,interm_index(ii));
    else
        prev_state = [];
    end
    
    % Sample new state
    if algo.pf_proposal_type == 1
        % Bootstrap
        if ii > 1
            if ~isempty(prev_state)
                [state, ppsl_prob] = model.transition(model, prev_state);
            else
                [state, ppsl_prob] = model.stateprior(model);
            end
        else
            state = interm_state(:,1);
            if ~isempty(prev_state)
                [~, ppsl_prob] = model.transition(model, prev_state, state);
            else
                [~, ppsl_prob] = model.stateprior(model, state);
            end
        end
        
    elseif algo.pf_proposal_type == 2
        % Other
        if ii > 1
            [state, ppsl_prob] = model.stateproposal(algo, model, prev_state, next_state, observ);
        else
            state = interm_state(:,1);
            [~, ppsl_prob] = model.stateproposal(algo, model, prev_state, next_state, observ, state);
        end
    end
    
    % Calculate probabilities
    if kk > 0
        [~, td1_prob] = model.transition(model, prev_state, state);
    else
        [~, td1_prob] = model.stateprior(model, state);
    end
    if kk < K-1
        [~, td2_prob] = model.transition(model, state, next_state);
    else
        td2_prob = 0;
    end
    [~, obs_prob] = model.observation(model, state, observ);
    post_prob = td1_prob + td2_prob + obs_prob;
    
    % Store
    interm_state(:,ii) = state;
    interm_weight(ii) = post_prob - ppsl_prob;
    
end

bess = effsampsize(interm_weight);

% Sample an ancestor
idx = sample_weights(interm_weight, 1);
state = interm_state(:,idx);
if kk > 0
    index = interm_index(idx);
else
    index = 0;
end

end

