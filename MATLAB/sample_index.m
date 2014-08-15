function [ index, bess ] = sample_index( fh, algo, model, pf_kk, init_index, next_state )
%SAMPLE_INDEX Sample an ancestor for a single time
%instant from the joint posterior, using Metropolis-Hastings. This is the
%main step in the backward simulation particle Gibbs algorithm.

if algo.use_MH_with2
    
    % Initialise chain
    init_state = pf_kk.state(:,init_index);
    chain_index = init_index;
    [~, chain_post_prob] = feval(fh.transition, model, init_state, next_state);
    
    for mm = 1:algo.M
        
        % Propose an index
        ppsl_index = sample_weights(pf_kk.weight, 1);
        ppsl_state = pf_kk.state(:,ppsl_index);
        
        % Calculate probability
        [~, post_prob] = feval(fh.transition, model, ppsl_state, next_state);
        
        % Accept
        ap = post_prob - chain_post_prob;
        if log(rand) < ap
            chain_index = ppsl_index;
        end
        
    end
    
    index = chain_index;
    
else
    
    % Calculate backward sampling weights
    bs_weight = zeros(1,algo.N);
    for ii = 1:algo.N
        [~, td_prob] = feval(fh.transition, model, pf_kk.state(:,ii), next_state);
        bs_weight(ii) = pf_kk.weight(ii) + td_prob;
    end
    
    bess = calc_ESS(bs_weight);

    % Sample an ancestor
    index = sample_weights(bs_weight, 1);
    
%     norm_bs_weight = bs_weight-logsumexp(bs_weight');
%     exp(norm_bs_weight(init_index))
    
end

end

