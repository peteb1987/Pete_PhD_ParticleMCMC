function [ arr ] = nlbenchmark_trajearray(model, N)
%NLBENCHMARK_TRAJEARRAY Initialise a structure array to store trajectories

if N > 1
    arr = struct('state', cell(N,1), 'index', cell(N,1), 'weight', cell(N,1));
else
    arr = struct('state', zeros(model.ds, model.K), 'index', zeros(1, model.K), 'weight', zeros(1, model.K));
end

end

