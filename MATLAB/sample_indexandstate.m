function [ index, state, bess ] = sample_indexandstate( fh, algo, model, kk, pf_kk, init_index, init_state, next_state, observ )
%SAMPLE_INDEXANDSTATE Sample an ancestor and a state for a single time
%instant from their joint posterior, using Metropolis-Hastings. This is the
%main step in the improved backward simulation particle Gibbs algorithm.

N = algo.N;
K = model.K;

% The state we're sampling is for time kk+1. pf_kk is the particle filter
% output from time kk.

if algo.use_MH_with3
    
    % Initial states and probabilities
    if kk > 0
        prev_state = pf_kk.state(:,init_index);
        [~, td1_prob] = feval(fh.transition, model, prev_state, init_state);
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
    chain_index = init_index;
    
    % Markov chain
    acc_count = 0;
    for mm = 1:algo.M
        
        % Propose an ancestor
        if kk > 0
            ppsl_index = sample_weights(pf_kk.weight, 1);
            prev_state = pf_kk.state(:,ppsl_index);
        else
            ppsl_index = 0;
            prev_state = [];
        end
        
        % Propose a state
        [ppsl_state, ppsl_prob] = feval(fh.stateproposal, algo, model, prev_state, next_state, observ);
        
        % Calculate probabilities
        if kk > 0
            [~, td1_prob] = feval(fh.transition, model, prev_state, ppsl_state);
        else
            [~, td1_prob] = feval(fh.stateprior, model, ppsl_state);
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
            chain_index = ppsl_index;
            chain_post_prob = post_prob;
            chain_ppsl_prob = ppsl_prob;
            acc_count = acc_count + 1;
        end
        
    end
    
    index = chain_index;
    state = chain_state;
    
    % acc_count
    
else
    
    % Create some arrays
    interm_state = zeros(model.ds, algo.N);
    interm_weight = zeros(1, algo.N);
    interm_index = zeros(1, algo.N);
    
    % First particle is the reference
    interm_state(:,1) = init_state;
    interm_index(1) = init_index;
    
    % Sample new indexs for each other particle
    if kk > 0
        interm_index(2:end) = sample_weights(pf_kk.weight, algo.N-1);
    end
    for ii = 1:algo.N
        
        % Get previous state
        if kk > 0
            prev_state = pf_kk.state(:,interm_index(ii));
        else
            prev_state = [];
        end
        
        % Sample new state
        if ii > 1
            [state, ppsl_prob] = feval(fh.stateproposal, algo, model, prev_state, next_state, observ);
        else
            state = interm_state(:,1);
            [~, ppsl_prob] = feval(fh.stateproposal, algo, model, prev_state, next_state, observ, state);
        end
        
        % Calculate probabilities
        if kk > 0
            [~, td1_prob] = feval(fh.transition, model, prev_state, state);
        else
            [~, td1_prob] = feval(fh.stateprior, model, state);
        end
        if kk < K-1
            [~, td2_prob] = feval(fh.transition, model, state, next_state);
        else
            td2_prob = 0;
        end
        [~, obs_prob] = feval(fh.observation, model, state, observ);
        post_prob = td1_prob + td2_prob + obs_prob;
        
        % Store
        interm_state(:,ii) = state;
        interm_weight(ii) = post_prob - ppsl_prob;
        
    end
    
    bess = calc_ESS(interm_weight);
    
    % Sample an ancestor
    idx = sample_weights(interm_weight, 1);
    state = interm_state(:,idx);
    if kk > 0
        index = interm_index(idx);
    else
        index = 0;
    end
    
    
end

end

