function [ traje ] = sample_trajectory( algo, model, pf, observ )
%SAMPLE_TRAJECTORY Sample a trajectory from the particle filter results
%using either the basic method, backward-simulation or improved backward
%simulation

K = model.K;
N = algo.N;

% Create a structure for the trajectory
traje = nlbenchmark_trajearray(model, 1);

% Sample an ancestor from the final stage weights
traje.index(K) = sample_weights(algo, pf(K).weight, 1);

switch algo.traje_sampling
    case 1  % Standard particle Gibbs
        
        % Get final state
        traje.state(:,K) = pf(K).state(:, traje.index(1,K));
        
        % Get the final weight
        traje.weight(:,K) = pf(K).weight(:, traje.index(1,K));
        
        % Loop backwards through time
        for kk = K-1:-1:1
            
            % Get next ancestor
            traje.index(:,kk) = pf(kk+1).ancestor(1, traje.index(1,kk+1));
            
            % Get state and weight
            traje.state(:,kk) = pf(kk).state(:, traje.index(1,kk));
            traje.weight(:,kk) = pf(kk).weight(:, traje.index(1,kk));
            
        end
        
    case 2  % Particle Gibbs with backward-simulation
        
        % Get final state
        traje.state(:,K) = pf(K).state(:, traje.index(1,K));
        
        % Loop backwards through time
        for kk = K-1:-1:1
            
            % Calculate backward sampling weights
            bs_weight = zeros(algo.N,1);
            for ii = 1:N
                [~, td_prob] = nlbenchmark_transition(model, kk, pf(kk).state(:,ii), traje.state(kk+1));
                bs_weight(ii) = pf(kk).weight(ii) + td_prob;
            end
            
            % Sample an ancestor
            traje.index(kk) = sample_weights(algo, bs_weight, 1);
            
            % Get state and weight
            traje.state(:,kk) = pf(kk).state(:, traje.index(1,kk));
            traje.weight(:,kk) = pf(kk).weight(:, traje.index(1,kk));
            
        end
        
    case 3  % Particle Gibbs with improved backward-simulation
        
        % Loop backwards through time
        for kk = K:-1:1
            
            % Get initial values and probabilities for Markov chain
            chain_index = pf(kk).ancestor(1, traje.index(1,kk) );
            chain_state = pf(kk).state(1, traje.index(1,kk) );
            if kk > 1
                prev_state = pf(kk-1).state(:,chain_index);
                [~, td1_prob] = nlbenchmark_transition(model, kk-1, prev_state, chain_state);
            else
                prev_state = [];
                td1_prob = 0;
            end
            if kk < K
                next_state = traje.state(:,kk+1);
                [~, td2_prob] = nlbenchmark_transition(model, kk, chain_state, next_state);
            else
                next_state = [];
                td2_prob = 0;
            end
            [~, obs_prob] = nlbenchmark_observation(model, chain_state, observ(:,kk));
            chain_post = td1_prob + td2_prob + obs_prob;
            
            % Markov chain
            for mm = 1:algo.M
                
                if kk > 1
                    % Propose an ancestor
                    ppsl_index = sample_weights(algo, pf(kk-1).weight, 1);
                    prev_state = pf(kk-1).state(:,ppsl_index);
                else
                    ppsl_index = 0;
                    prev_state = [];
                end
                
                % Propose a state
                [ppsl_state, forw_ppsl_prob] = nlbenchmark_stateproposal(algo, model, prev_state, next_state, observ(:,kk));
                [~, back_ppsl_prob] = nlbenchmark_stateproposal(algo, model, prev_state, next_state, observ(:,kk), chain_state);
                
                % Calculate probabilities
                if kk > 1
                    [~, td1_prob] = nlbenchmark_transition(model, kk-1, prev_state, ppsl_state);
                else
                    td1_prob = 0;
                end
                if kk < K
                    [~, td2_prob] = nlbenchmark_transition(model, kk, ppsl_state, next_state);
                else
                    td2_prob = 0;
                end
                [~, obs_prob] = nlbenchmark_observation(model, ppsl_state, observ(:,kk));
                ppsl_post = td1_prob + td2_prob + obs_prob;
                
                % Calculate acceptance probability
                ap = (ppsl_post - forw_ppsl_prob) - (chain_post - back_ppsl_prob);
                
                % Accept?
                if log(rand) < ap
                    chain_state = ppsl_state;
                    chain_index = ppsl_index;
                    chain_post = ppsl_post;
                end
                
            end
            
            % Store final value from MC
            if kk > 1
                traje.index(kk-1) = chain_index;
            end
            traje.state(:,kk) = chain_state;
            
            % Get weight
            traje.weight(:,kk) = pf(kk).weight(:, traje.index(1,kk));
            
        end
        
end

end

