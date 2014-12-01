function [ traje, bess, change ] = sample_trajectory( algo, model, pf, observ, old_traje )
%SAMPLE_TRAJECTORY Sample a trajectory from the particle filter results
%using either the basic method, backward-simulation or improved backward
%simulation

K = model.K;
N = algo.N;

% Array for backwards sampling ESSs
bess = zeros(1,K);

% Create a structure for the trajectory
traje = struct('state', zeros(model.ds, model.K), 'index', zeros(1, model.K));

% Sample an ancestor from the final stage weights
traje.index(K) = sample_weights(pf(K).weight, 1);
bess(K) = effsampsize(pf(K).weight);

switch algo.ref_traj_type
    case 1  % Standard particle Gibbs
        
        % Get final state
        traje.state(:,K) = pf(K).state(:, traje.index(1,K));
        
        % Loop backwards through time
        for kk = K-1:-1:1
            
            % Get next ancestor
            traje.index(:,kk) = pf(kk+1).ancestor(1, traje.index(1,kk+1));
            
            % Get state and weight
            traje.state(:,kk) = pf(kk).state(:, traje.index(1,kk));
            
            bess(kk) = 1;
            
        end
        
    case 2  % Particle Gibbs with backward-simulation
        
        % Get final state
        traje.state(:,K) = pf(K).state(:, traje.index(K));
        
        % Loop backwards through time
        for kk = K-1:-1:1
            
            % Sample an index
            next_state = traje.state(:,kk+1);
            [traje.index(kk), bess(kk)] = sample_index( algo, model, pf(kk), next_state );
            
            % Get state and weight
            traje.state(:,kk) = pf(kk).state(:, traje.index(kk));
            
        end
        
    case 3  % Particle Gibbs with improved backward-simulation
        
        % Loop backwards through time
        for kk = K:-1:1
            
            % Get reference trajectory values for sampling
            init_index = pf(kk).ancestor(1, traje.index(1,kk) );
            init_state = pf(kk).state(:, traje.index(1,kk) );
            
            if kk < K
                next_state = traje.state(:,kk+1);
            else
                next_state = [];
            end
            
            % Sample using Markov chain
            if kk > 1
                [index, state, bess(kk)] = sample_indexandstate( algo, model, kk-1, pf(kk-1), init_index, init_state, next_state, observ(:,kk) );
            else
                [index, state, bess(kk)] = sample_indexandstate( algo, model, kk-1, [], init_index, init_state, next_state, observ(:,kk) );
            end
            
            % Store values
            if kk > 1
                traje.index(kk-1) = index;
            end
            traje.state(:,kk) = state;
            
        end
        
    case 4  % Particle Gibbs with multiple-state collapsing
        
        % Loop backwards through time
        for kk = K:-1:1
            
            % State block indexes
            bidx = kk:min(K,kk+algo.L-1);
            L = length(bidx);
            
            % Get reference trajectory values for sampling
            init_index = pf(kk).ancestor(1, traje.index(1,kk) );
            init_state_block = zeros(model.ds, L);
            for ll = 1:L
                init_state_block(:,ll) = pf(kk+ll-1).state(:,traje.index(1,kk+ll-1));
            end
                        
            if kk < K-L
                next_state = traje.state(:,kk+L+1);
            else
                next_state = [];
            end
            
            % Sample using Markov kernel
            if kk > 1
                pf_kk = pf(kk-1);
            else
                pf_kk = [];
            end
            [index, state_block, bess(kk)] = sample_indexandstateblock( ...
                            algo, model, kk-1, pf_kk, ...
                            init_index, init_state_block, next_state, ...
                            observ(:,bidx) );
            
            % Store values
            if kk > 1
                traje.index(kk-1) = index;
            end
            for ll = 1:L
                traje.state(:,kk+ll-1) = state_block(:,ll);
            end
                        
        end
        
end

if ~isempty(old_traje)
    change = ~(traje.index==old_traje.index);
else
    change = zeros(size(traje.index));
end

end
