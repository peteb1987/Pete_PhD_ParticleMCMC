function [ ancestor ] = sample_weights( algo, weight, N )
%SAMPLE_WEIGHTS Samples an array of N ancestor indexes from a set of
%weights

% CURRENTLY, THIS USES MULTINOMIAL RESAMPLING

% Convert weights to linear domain and normalise
weight = exp(weight);
weight = weight/sum(weight);

% Sample
ancestor = randsample(length(weight), N, true, weight)';

end

