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
        % Set state for conditioned particle
        pf(1).state(:, ii ) = traje.state(:,1);
    else
        % Sample state
        [pf(1).state(:,ii), ~] = nlbenchmark_stateprior(model);
    end
    % Calculate weight
    [~, pf(1).weight(1,ii)] = nlbenchmark_observation(model, pf(1).state(:,ii), observ(:,1));
end

% Loop through time
for kk = 2:K
    
    % Index of conditioned particle
    ind = traje.index(kk);
    
    % Initialise arrays
    pf(kk).state = zeros(model.ds, N);
    pf(kk).weight = zeros(1, N);
    
    % Sample ancestors for all but conditioned particle
    pf(kk).ancestor(1,[1:ind-1 ind+1:N]) = sample_weights(algo, pf(kk-1).weight, N-1);
    
    switch algo.traje_sampling
        case 1  % Standard particle Gibbs
            
            % Set conditioned particle ancestor
            pf(kk).ancestor(1, ind ) = traje.index(kk-1);
            
        case 2  % Particle Gibbs with backward-simulation
            
            % Calculate modified ancestor sampling weights
            bs_weight = zeros(N,1);
            for ii = 1:N
                [~, td_prob] = nlbenchmark_transition(model, kk-1, pf(kk-1).state(:,ii), traje.state(kk));
                bs_weight(ii) = pf(kk-1).weight(ii) + td_prob;
            end
            
            % Sample an ancestor
            pf(kk).ancestor(1,ind) = sample_weights(algo, bs_weight, 1);
            
        case 3  % Particle Gibbs with improved backward-simulation
            
    end
    
    % Loop through particles
    for ii = 1:N
        
        % Ancestory
        prev_state = pf(kk-1).state(:,pf(kk).ancestor(ii));
        
        if ii == ind
            
            % Set state for conditioned particle
            pf(kk).state(:,ii) = traje.state(:,kk);
            
        else
            
            % Sample a state
            [pf(kk).state(:,ii), ~] = nlbenchmark_transition(model, kk-1, prev_state);
            
        end
        
        % Calculate weight
        [~, pf(kk).weight(1,ii)] = nlbenchmark_observation(model, pf(kk).state(:,ii), observ(:,kk));
        
    end
    
end

end

