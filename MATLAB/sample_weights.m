function [ ancestor ] = sample_weights( algo, weight, N )
%SAMPLE_WEIGHTS Samples an array of N ancestor indexes from a set of
%weights

% CURRENTLY, THIS USES MULTINOMIAL RESAMPLING

% Row vectors only here, please
weight = weight(:)';

% Convert weights to linear domain and normalise
weight = exp(weight);
weight = weight/sum(weight);

% Catch NaNs
assert(~any(isnan(weight)));

% Create bin boundaries
edges = min([0 cumsum(weight)],1);
edges(end) = 1;

% Sample
[~, ancestor] = histc(rand(N,1),edges);
ancestor = ancestor';

end

