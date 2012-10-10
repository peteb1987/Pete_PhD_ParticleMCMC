function [ arr ] = nlbenchmark_paramarray(N)
%NLBENCHMARK_PARAMARRAY Initialise a structure array to store parameter
%values

arr = struct('pro_var', cell(N,1), 'obs_var', cell(N,1));

end

