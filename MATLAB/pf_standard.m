function [ pf ] = pf_standard( fh, algo, model, observ )
%PF_STANDARD Run a standard particle filter

% Initialise arrays
pf = struct('state', cell(model.K,1), 'ancestor', cell(model.K,1), 'weight', cell(model.K,1));
pf(1).state = zeros(model.ds, algo.N);
pf(1).ancestor = zeros(1, algo.N);
pf(1).weight = zeros(1, algo.N);

% Sample first state from prior and calculate weight
for ii = 1:algo.N
    
    if algo.proposal == 1
        % Bootstrap
        [pf(1).state(:,ii), ~] = feval(fh.stateprior, model);
        [~, pf(1).weight(ii)] = feval(fh.observation, model, pf(1).state(:,ii), observ(:,1));
        
    elseif algo.proposal == 2
        % Other
        [state, ppsl_prob] = feval(fh.stateproposal, algo, model, [], [], observ(:,1));
        [~, trans_prob] = feval(fh.stateprior, model);
        [~, obs_prob] = feval(fh.observation, model, state, observ(:,1));
        
        pf(1).state(:,ii) = state;
        pf(1).weight(ii) = obs_prob + trans_prob - ppsl_prob;
         
    end
    
end

% Loop through time
for kk = 2:model.K
    
    % Sample ancestors
    pf(kk).ancestor = sample_weights(pf(kk-1).weight, algo.N);
    
    % Initialise state and weight arrays
    pf(kk).state = zeros(model.ds, algo.N);
    pf(kk).weight = zeros(1, algo.N);
    
    % Loop through particles
    for ii = 1:algo.N
        
        % Ancestory
        prev_state = pf(kk-1).state(:,pf(kk).ancestor(ii));
        
        if algo.proposal == 1
            % Bootstrap
            pf(kk).state(:,ii) = feval(fh.transition, model, prev_state);
            [~, pf(kk).weight(ii)] = feval(fh.observation, model, pf(kk).state(:,ii), observ(:,kk));
            
        elseif algo.proposal == 2
            % Other
            [state, ppsl_prob] = feval(fh.stateproposal, algo, model, prev_state, [], observ(:,kk));
            [~, trans_prob] = feval(fh.transition, model, prev_state, state);
            [~, obs_prob] = feval(fh.observation, model, state, observ(:,1));
            
            pf(kk).state(:,ii) = state;
            pf(kk).weight(ii) = obs_prob + trans_prob - ppsl_prob;
            
        end
        
    end
    
end

end

