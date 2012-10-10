function [ pf ] = pf_standard( algo, model, observ )
%PF_STANDARD Run a standard particle filter

% CURRENTLY, THIS IS A BOOTSTRAP FILTER

% Initialise arrays
pf = struct('state', cell(model.K,1), 'ancestor', cell(model.K,1), 'weight', cell(model.K,1));
pf(1).state = zeros(model.ds, algo.N);
pf(1).ancestor = zeros(1, algo.N);
pf(1).weight = zeros(1, algo.N);

% Sample first state from prior and calculate weight
for ii = 1:algo.N
    [pf(1).state(:,ii), ~] = nlbenchmark_stateprior(model);
    pf(1).weight(1,ii) = 1;
end

% Loop through time
for kk = 2:model.K
    
    % Sample ancestors
    pf(kk).ancestor = sample_weights(algo, pf(kk-1).weight, algo.N);
    
    % Initialise state and weight arrays
    pf(kk).state = zeros(model.ds, algo.N);
    pf(kk).weight = zeros(1, algo.N);
    
    % Loop through particles
    for ii = 1:algo.N
        
        % Ancestory
        prev_state = pf(kk-1).state(:,pf(kk).ancestor(ii));
        
        % Sample a state
        pf(kk).state(:,ii) = nlbenchmark_transition(model, kk-1, prev_state);
        
        % Calculate weight
        [~, pf(kk).weight(1,ii)] = nlbenchmark_observation(model, pf(kk).state(:,ii), observ(:,1));
        
    end
    
end

end

