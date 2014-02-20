function [ traje ] = sample_trajectory( fh, algo, model, pf, observ )
%SAMPLE_TRAJECTORY Sample a trajectory from the particle filter results
%using either the basic method, backward-simulation or improved backward
%simulation

K = model.K;
N = algo.N;

% Create a structure for the trajectory
traje = struct('state', zeros(model.ds, model.K), 'index', zeros(1, model.K), 'weight', zeros(1, model.K));

% Sample an ancestor from the final stage weights
traje.index(K) = sample_weights(pf(K).weight, 1);

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
            
            % Sample an index
            init_index = pf(kk+1).ancestor(1, traje.index(1,kk+1) );
            next_state = traje.state(:,kk+1);
            traje.index(kk) = sample_index( fh, algo, model, pf(kk), init_index, next_state );
            
            % Get state and weight
            traje.state(:,kk) = pf(kk).state(:, traje.index(1,kk));
            traje.weight(:,kk) = pf(kk).weight(:, traje.index(1,kk));
            
        end
        
    case 3  % Particle Gibbs with improved backward-simulation
        
        % Loop backwards through time
        for kk = K:-1:1
            
            % Get initial values for sampling
            init_index = pf(kk).ancestor(1, traje.index(1,kk) );
            init_state = pf(kk).state(:, traje.index(1,kk) );
            
            if kk < K
                next_state = traje.state(:,kk+1);
            else
                next_state = [];
            end
            
            % Sample using Markov chain
            if kk > 1
                [chain_index, chain_state] = sample_indexandstate(fh, algo, model, kk-1, pf(kk-1), init_index, init_state, next_state, observ(:,kk) );
            else
                [chain_index, chain_state] = sample_indexandstate(fh, algo, model, kk-1, [], init_index, init_state, next_state, observ(:,kk) );
            end
            
            % Store values
            if kk > 1
                traje.index(kk-1) = chain_index;
            end
            traje.state(:,kk) = chain_state;
            
            % Get weight
            traje.weight(:,kk) = pf(kk).weight(:, traje.index(1,kk));
            
        end
        
end

end

