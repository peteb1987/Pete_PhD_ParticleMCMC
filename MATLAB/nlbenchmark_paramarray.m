function [ arr ] = nlbenchmark_paramarray(model, N)
%NLBENCHMARK_PARAMARRAY Initialise a structure array to store parameter
%values

arr = struct('sigx', cell(N,1), 'sigy', cell(N,1));

end

