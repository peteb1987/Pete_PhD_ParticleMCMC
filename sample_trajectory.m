function [ traje ] = sample_trajectory( algo, model, pf, observ )
%SAMPLE_TRAJECTORY Sample a trajectory from the particle filter results
%using either the basic method, backward-simulation or improved backward
%simulation

% Create a structure for the trajectory
traje = nlbenchmark_trajearray(model, 1);

% Sample the final stage weight
traje.index(model.K) = sample_weights(algo, pf(1).weight, 1);

switch algo.traje_sampling
    case 1  % Standard particle Gibbs
        
        % Loop backwards through time
        for kk = model.K:-1:1
            
            % Get state and weight
            traje.state(:,kk) = pf(kk).state(:, traje.index(1,kk));
            traje.weight(:,kk) = pf(kk).weight(:, traje.index(1,kk));
            
            if kk > 1
                % Get next ancestor
                traje.index(:,kk-1) = pf(kk).ancestor(1, traje.index(1,kk));
            end
            
        end
        
    case 2  % Particle Gibbs with backward-simulation
        
    case 3  % Particle Gibbs with improved backward-simulation
    
end

end

