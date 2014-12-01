function [ index, bess ] = sample_index( algo, model, pf_kk, next_state )
%SAMPLE_INDEX Sample an ancestor for a single time
%instant from the joint posterior. This is the main step in the backward
%simulation particle Gibbs algorithm.

% Calculate backward sampling weights
bs_weight = zeros(1,algo.N);
for ii = 1:algo.N
    [~, td_prob] = model.transition(model, pf_kk.state(:,ii), next_state);
    bs_weight(ii) = pf_kk.weight(ii) + td_prob;
end

bess = effsampsize(bs_weight);

% Sample an ancestor
index = sample_weights(bs_weight, 1);
    
end

