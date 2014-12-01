function [ index, block, bess ] = sample_indexandstateblock( ...
    algo, model, kk, pf_kk, init_index, init_block, next_state, observ )
%SAMPLE_INDEXANDSTATEBLOCK Sample an ancestor for a single time instant
%and a block of states following this time from their joint posterior.
%This is the main step in the blocked improved backward simulation
%particle Gibbs algorithm.

% Currently uses "bootstrap" proposals only, i.e. observations are not used
% in proposing new state sequences.

N = algo.N;
K = model.K;
[ds,L] = size(init_block);

% The states we're sampling are for time kk+1:kk+L.
% pf_kk is the particle filter output from time kk.
    
% Create some arrays
interm_block = cell(1,N);
interm_weight = zeros(1, N);
interm_index = zeros(1, N);

% First particle is the reference
interm_block{1} = init_block;
interm_index(1) = init_index;

% Sample new indexes for each other particle
if kk > 0
    interm_index(2:end) = sample_weights(pf_kk.weight, N-1);
end
for ii = 1:N
    
    % Get previous state
    if kk > 0
        prev_state = pf_kk.state(:,interm_index(ii));
    else
        prev_state = [];
    end
    
    % Sample new states
    if ii == 1
        block = init_block;
        [~, match_prob] = model.blockproposal(algo, model, L, prev_state, next_state, observ, block);
    else
        [block, match_prob] = model.blockproposal(algo, model, L, prev_state, next_state, observ, []);
    end
    
    % Likelihoods
    block_lhood = zeros(1,L);
    for ll = 1:L
        [~, block_lhood(ll)] = model.observation(model, block(:,ll), observ(:,ll));
    end
    
    % Store
    interm_block{ii} = block;
    interm_weight(ii) = match_prob + sum(block_lhood);
    
end

bess = effsampsize(interm_weight);

% Sample an ancestor
idx = sample_weights(interm_weight, 1);
block = interm_block{idx};
if kk > 0
    index = interm_index(idx);
else
    index = 0;
end

end

