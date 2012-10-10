function [ arr ] = nlbenchmark_trajearray(N)
%NLBENCHMARK_TRAJEARRAY Initialise a structure array to store trajectories

arr = struct('state', cell(N,1), 'index', cell(N,1));

end

