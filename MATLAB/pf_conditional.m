function [ pf ] = pf_conditional( algo, model, observ, traje )
%PF_STANDARD Run a standard particle filter

% CURRENTLY, THIS IS A BOOTSTRAP FILTER

N = algo.N;
K = model.K;

% Initialise arrays
pf = struct('state', cell(K,1), 'ancestor', cell(K,1), 'weight', cell(K,1));
pf(1).state = zeros(model.ds, N);
pf(1).ancestor = zeros(1, N);
pf(1).weight = zeros(1, N);

% First state
for ii = 1:N
    if ii == traje.index(1)
        if (algo.traje_sampling == 1) || (algo.traje_sampling == 2)
            
            % Set state for conditioned particle
            pf(1).state(:, ii) = traje.state(:,1);
            
        elseif (algo.traje_sampling == 3)
            
            % Sample state for conditioned particle
            init_state = traje.state(:,1); init_index = 0;
            next_state = traje.state(:,2);
            [~, chain_state] = sample_indexandstate(algo, model, 0, [], init_index, init_state, next_state, observ(:,1) );
            
            pf(1).state(:, ii) = chain_state;
            
        end
        
    else
        % Sample state
        [pf(1).state(:,ii), ~] = nlbenchmark_stateprior(model);
    end
    % Calculate weight
    [~, pf(1).weight(1,ii)] = nlbenchmark_observation(model, pf(1).state(:,ii), observ(:,1));
end

% Loop through time
for kk = 2:K
    
    % Initialise arrays
    pf(kk).state = zeros(model.ds, N);
    pf(kk).weight = zeros(1, N);
    
    % Index of conditioned particle
    ind = traje.index(kk);
    
    % Ancestor and state sampling for conditioned particle
    switch algo.traje_sampling
        case 1  % Standard particle Gibbs
            
            % Set conditioned particle ancestor
            pf(kk).ancestor(1, ind ) = traje.index(kk-1);
            
            % Set state for conditioned particle
            pf(kk).state(:,ind) = traje.state(:,kk);
            
        case 2  % Particle Gibbs with backward-simulation
            
            % Calculate modified ancestor sampling weights
            bs_weight = zeros(N,1);
            for ii = 1:N
                [~, td_prob] = nlbenchmark_transition(model, kk-1, pf(kk-1).state(:,ii), traje.state(kk));
                bs_weight(ii) = pf(kk-1).weight(ii) + td_prob;
            end
            
            % Sample an ancestor
            pf(kk).ancestor(1,ind) = sample_weights(algo, bs_weight, 1);
            
            % Set state for conditioned particle
            pf(kk).state(:,ind) = traje.state(:,kk);
            
        case 3  % Particle Gibbs with improved backward-simulation
            
            % Get initial values for sampling
            init_index = traje.index(1,kk-1);
            init_state = traje.state(:,kk);
            
            if kk < K
                next_state = traje.state(:,kk+1);
            else
                next_state = [];
            end
            
            % Sample using Markov chain
            [chain_index, chain_state] = sample_indexandstate(algo, model, kk-1, pf(kk-1), init_index, init_state, next_state, observ(:,kk) );
            
            % Store values
            if kk > 1
                pf(kk).ancestor(1,ind) = chain_index;
            end
            pf(kk).state(:,ind) = chain_state;
            
    end
    
    % Calculate weight of conditioned particle
    [~, pf(kk).weight(1,ind)] = nlbenchmark_observation(model, pf(kk).state(:,ind), observ(:,kk));
    
    % Sample ancestors for non-conditioned particles
    pf(kk).ancestor(1,[1:ind-1 ind+1:N]) = sample_weights(algo, pf(kk-1).weight, N-1);
    
    % Loop through non-conditioned particles
    for ii = [1:ind-1 ind+1:N]
        
        % Ancestory
        prev_state = pf(kk-1).state(:,pf(kk).ancestor(ii));
        
        % Sample a state
        [pf(kk).state(:,ii), ~] = nlbenchmark_transition(model, kk-1, prev_state);
        
        % Calculate weight
        [~, pf(kk).weight(1,ii)] = nlbenchmark_observation(model, pf(kk).state(:,ii), observ(:,kk));
        
    end
    
end

end

