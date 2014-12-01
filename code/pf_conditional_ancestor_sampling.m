function [ pf, bess ] = pf_conditional_ancestor_sampling( algo, model, observ, traje )
%PF_CONDITIONAL_ANCESTOR SAMPLING Run a standard particle filter with
%ancestor sampling

N = algo.N;
K = model.K;

% Initialise particle filter structure
pf = struct('state', cell(K,1), 'ancestor', cell(K,1), 'weight', cell(K,1), 'marg_lhood', cell(model.K,1));
pf(1).state = zeros(model.ds, N);
pf(1).ancestor = zeros(1, N);
pf(1).weight = zeros(1, N);

% Array for ancestor sampling ESSs
bess = zeros(1,K);

% First state
ind = traje.index(1);
for ii = 1:N
    
    if ii == ind
        
        switch algo.anc_samp_type
            
            case 2
                % Ordinary ancestor sampling
                
                % Set state deteministically
                state = traje.state(:,1);
                
                if algo.pf_proposal_type == 1
                    % Bootstrap
                    
                    % Weight
                    [~, pf(1).weight(ii)] = model.observation(model, state, observ(:,1));
                    
                elseif algo.pf_proposal_type == 2
                    % Other
                    
                    % Proposal
                    [~, ppsl_prob] = model.stateproposal(algo, model, [], [], observ(:,1), state);
                    
                    % Weight
                    [~, trans_prob] = model.stateprior(model, state);
                    [~, obs_prob] = model.observation(model, state, observ(:,1));
                    pf(1).weight(ii) = obs_prob + trans_prob - ppsl_prob;
                    
                end
                
            case 3
                % Improved ancestor sampling with state sampling
                
                % Get next state
                next_state = traje.state(:,2);
                
                % Get initial state
                init_state = traje.state(:,1);
                
                % Sample ancestor and state
                [~, state, ~] = sample_indexandstate(algo, model, 0, [], 0, init_state, next_state, observ(:,1));
                
                if algo.pf_proposal_type == 1
                    % Bootstrap
                    
                    % Weight
                    [~, pf(1).weight(ii)] = model.observation(model, state, observ(:,1));
                    
                elseif algo.pf_proposal_type == 2
                    % Other
                    
                    % Proposal
                    [~, ppsl_prob] = model.stateproposal(algo, model, [], [], observ(:,1), state);
                    
                    % Weight
                    [~, trans_prob] = model.stateprior(model, state);
                    [~, obs_prob] = model.observation(model, state, observ(:,1));
                    pf(1).weight(ii) = obs_prob + trans_prob - ppsl_prob;
                    
                end
                
            otherwise
                error('Invalid ancestor sampling type set.')
                
        end
        
    else
        
        if algo.pf_proposal_type == 1
            % Bootstrap
            
            % Sample new state
            [state, ~] = model.stateprior(model);
            
            % Weight
            [~, pf(1).weight(ii)] = model.observation(model, state, observ(:,1));
            
        elseif algo.pf_proposal_type == 2
            % Other
            
            % Sample new state
            [state, ppsl_prob] = model.stateproposal(algo, model, [], [], observ(:,1));
            
            % Weight
            [~, trans_prob] = model.stateprior(model, state);
            [~, obs_prob] = model.observation(model, state, observ(:,1));
            pf(1).weight(ii) = obs_prob + trans_prob - ppsl_prob;
            
        end
        
    end
    
    pf(1).state(:,ii) = state;
    
end

% Loop through time
for kk = 2:K
    
    % Initialise arrays
    pf(kk).state = zeros(model.ds, N);
    pf(kk).weight = zeros(1, N);
    
    % Index of conditioned particle
    ind = traje.index(kk);
    
    % Sample ancestors for all but reference
    pf(kk).ancestor([1:ind-1 ind+1:N]) = sample_weights(pf(kk-1).weight, N-1);
    
    for ii = 1:N
        
        if ii == ind
            
            switch algo.anc_samp_type
                
                case 2
                    % Ordinary ancestor sampling
                    
                    % Set state deteministically
                    state = traje.state(:,kk);
                    pf(kk).state(:,ii) = state;
                    
                    % Sample ancestor
                    [index, bess(kk-1)] = sample_index(algo, model, pf(kk-1), state);
                    
                    % Save index
                    pf(kk).ancestor(ii) = index;
                    
                    if algo.pf_proposal_type == 1
                        % Bootstrap
                        
                        % Weight
                        [~, pf(kk).weight(ii)] = model.observation(model, state, observ(:,kk));
                        
                    elseif algo.pf_proposal_type == 2
                        % Other
                        
                        % Proposal
                        prev_state = pf(kk-1).state(:,pf(kk).ancestor(ii));
                        [~, ppsl_prob] = model.stateproposal(algo, model, prev_state, [], observ(:,kk), state);
                        
                        % Weight
                        [~, trans_prob] = model.transition(model, prev_state, state);
                        [~, obs_prob] = model.observation(model, state, observ(:,kk));
                        pf(kk).weight(ii) = obs_prob + trans_prob - ppsl_prob;
                        
                    end
                    
                case 3
                    % Improved ancestor sampling with state sampling
                    
                    % Get next state
                    if kk < K
                        next_state = traje.state(:,kk+1);
                    else
                        next_state = [];
                    end
                    
                    % Get initial index and state
                    init_index = traje.index(kk-1);
                    init_state = traje.state(:,kk);
                    
                    % Sample ancestor and state
                    [index, state, bess(kk-1)] = sample_indexandstate(algo, model, kk-1, pf(kk-1), init_index, init_state, next_state, observ(:,kk));
                    
                    % Save index and state
                    pf(kk).ancestor(ii) = index;
                    pf(kk).state(:,ii) = state;
                    
                    if algo.pf_proposal_type == 1
                        % Bootstrap
                        
                        % Weight
                        [~, pf(kk).weight(ii)] = model.observation(model, state, observ(:,kk));
                        
                    elseif algo.pf_proposal_type == 2
                        % Other
                        
                        % Proposal
                        prev_state = pf(kk-1).state(:,pf(kk).ancestor(ii));
                        [~, ppsl_prob] = model.stateproposal(algo, model, prev_state, [], observ(:,kk), state);
                        
                        % Weight
                        [~, trans_prob] = model.transition(model, prev_state, state);
                        [~, obs_prob] = model.observation(model, state, observ(:,kk));
                        pf(kk).weight(ii) = obs_prob + trans_prob - ppsl_prob;
                        
                    end
                    
                otherwise
                    error('Invalid ancestor sampling type set.')
                    
            end
            
        else
            
            % Ancestory
            prev_state = pf(kk-1).state(:,pf(kk).ancestor(ii));
            
            if algo.pf_proposal_type == 1
                % Bootstrap
                
                % Sample new state
                [state, ~] = model.transition(model, prev_state);
                
                % Weight
                [~, pf(kk).weight(ii)] = model.observation(model, state, observ(:,kk));
                
            elseif algo.pf_proposal_type == 2
                % Other
                
                % Sample new state
                [state, ppsl_prob] = model.stateproposal(algo, model, prev_state, [], observ(:,kk));
                
                % Weight
                [~, trans_prob] = model.transition(model, prev_state, state);
                [~, obs_prob] = model.observation(model, state, observ(:,kk));
                pf(kk).weight(ii) = obs_prob + trans_prob - ppsl_prob;
                
            end
            
            pf(kk).state(:,ii) = state;
            
        end
        
    end
    
    pf(kk).marg_lhood = logsumexp(pf(kk).weight');

end

end

