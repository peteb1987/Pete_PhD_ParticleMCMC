function [ chain_index, chain_state ] = sample_indexandstate_full( fh, algo, model, kk, pf_kk, init_index, init_state, next_state, observ )
%SAMPLE_INDEXANDSTATE Sample an ancestor and a state for a single time
%instant from their joint posterior, using Metropolis-Hastings. This is the
%main step in the improved backward simulation particle Gibbs algorithm.

N = algo.N;
K = model.K;

% The state we're sampling is for time kk+1. pf_kk is the particle filter
% output from time kk.

% Initial states and probabilities
if kk > 0
    prev_state = pf_kk.state(:,init_index);
    td1_prob_arr = zeros(1,algo.N);
    for jj = 1:algo.N
        [~, td1_prob_arr(jj)] = feval(fh.transition, model, pf_kk.state(:,jj), init_state);
        td1_prob_arr(jj) = td1_prob_arr(jj) + pf_kk.weight(jj);
    end
    td1_prob = logsumexp(td1_prob_arr,2);
else
    prev_state = [];
    td1_prob = 0;
end
if kk < K-1
    [~, td2_prob] = feval(fh.transition, model, init_state, next_state);
else
    td2_prob = 0;
end
[~, obs_prob] = feval(fh.observation, model, init_state, observ);
chain_post_prob = td1_prob + td2_prob + obs_prob;
[~, chain_ppsl_prob] = feval(fh.stateproposal, algo, model, prev_state, next_state, observ, init_state);

chain_state = init_state;


% Markov chain
acc_count = 0;
for mm = 1:algo.M
    
    % Propose an ancestor
    if kk > 0
        ppsl_index = sample_weights(pf_kk.weight, 1);
        prev_state = pf_kk.state(:,ppsl_index);
    else
        prev_state = [];
    end
    
    % Propose a state
    [ppsl_state, ppsl_prob] = feval(fh.stateproposal, algo, model, prev_state, next_state, observ);
    
    % Calculate probabilities
    if kk > 0
        td1_prob_arr = zeros(1,algo.N);
        for jj = 1:algo.N
            [~, td1_prob_arr(jj)] = feval(fh.transition, model, pf_kk.state(:,jj), ppsl_state);
            td1_prob_arr(jj) = td1_prob_arr(jj) + pf_kk.weight(jj);
        end
        td1_prob = logsumexp(td1_prob_arr,2);
    else
        td1_prob = feval(fh.stateprior, model, ppsl_state);
    end
    if kk < K-1
        [~, td2_prob] = feval(fh.transition, model, ppsl_state, next_state);
    else
        td2_prob = 0;
    end
    [~, obs_prob] = feval(fh.observation, model, ppsl_state, observ);
    post_prob = td1_prob + td2_prob + obs_prob;
    
    % Calculate acceptance probability
    ap = (post_prob - ppsl_prob) - (chain_post_prob - chain_ppsl_prob);
    
    % Accept?
    if log(rand) < ap
        chain_state = ppsl_state;
        chain_post_prob = post_prob;
        chain_ppsl_prob = ppsl_prob;
        acc_count = acc_count + 1;
    end
    
end

% acc_count

% Ordinary BS to sample index for next step
if kk > 0
    bs_weight = zeros(1,algo.N);
    for ii = 1:algo.N
        [~, td_prob] = feval(fh.transition, model, pf_kk.state(:,ii), chain_state);
        bs_weight(ii) = pf_kk.weight(ii) + td_prob;
    end
    chain_index = sample_weights(bs_weight, 1);
else
    chain_index = 0;
end

end

