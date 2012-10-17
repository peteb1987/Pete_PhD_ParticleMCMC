function [ chain_index, chain_state ] = sample_indexandstate( algo, model, kk, pf_kk, init_index, init_state, next_state, observ )
%SAMPLE_INDEXANDSTATE Sample an ancestor and a state for a single time
%instant from their joint posterior, using Metropolis-Hastings. This is the
%main step in the improved backward simulation particle Gibbs algorithm.

N = algo.N;
K = model.K;

% The state we're sampling is for time kk+1. pf is the particle filter
% output from time kk.

% Initial states and probabilities
if kk > 0
    prev_state = pf_kk.state(:,init_index);
    [~, td1_prob] = nlbenchmark_transition(model, kk, prev_state, init_state);
    prior_mn = nlbenchmark_f(model, kk, prev_state);
    prior_vr = model.sigx;
else
    prev_state = [];
    td1_prob = 0;
    prior_mn = model.x1_mn;
    prior_vr = model.x1_vr;
end
if kk < K-1
    [~, td2_prob] = nlbenchmark_transition(model, kk+1, init_state, next_state);
else
    td2_prob = 0;
end
[~, obs_prob] = nlbenchmark_observation(model, init_state, observ);
chain_post_prob = td1_prob + td2_prob + obs_prob;
[~, chain_ppsl_prob] = nlbenchmark_stateproposal(algo, model, kk+1, prior_mn, prior_vr, next_state, observ, init_state);

chain_state = init_state;
chain_index = init_index;

% Markov chain
for mm = 1:algo.M
    
    % Propose an ancestor
    if kk > 0
        ppsl_index = sample_weights(algo, pf_kk.weight, 1);
        prev_state = pf_kk.state(:,ppsl_index);
        prior_mn = nlbenchmark_f(model, kk, prev_state);
        prior_vr = model.sigx;
    else
        ppsl_index = 0;
        prev_state = [];
        prior_mn = model.x1_mn;
        prior_vr = model.x1_vr;
    end
    
    % Propose a state
    [ppsl_state, ppsl_prob] = nlbenchmark_stateproposal(algo, model, kk+1, prior_mn, prior_vr, next_state, observ);
    
    % Calculate probabilities
    if kk > 0
        [~, td1_prob] = nlbenchmark_transition(model, kk, prev_state, ppsl_state);
    else
        td1_prob = nlbenchmark_stateprior(model, ppsl_state);
    end
    if kk < K-1
        [~, td2_prob] = nlbenchmark_transition(model, kk+1, ppsl_state, next_state);
    else
        td2_prob = 0;
    end
    [~, obs_prob] = nlbenchmark_observation(model, ppsl_state, observ);
    post_prob = td1_prob + td2_prob + obs_prob;
    
    % Calculate acceptance probability
    ap = (post_prob - ppsl_prob) - (chain_post_prob - chain_ppsl_prob);
    
    % Accept?
    if log(rand) < ap
        chain_state = ppsl_state;
        chain_index = ppsl_index;
        chain_post_prob = post_prob;
        chain_ppsl_prob = ppsl_prob;
    end
    
end



end

