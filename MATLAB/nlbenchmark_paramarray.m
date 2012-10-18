function [ arr ] = nlbenchmark_paramarray(model, N)
%NLBENCHMARK_PARAMARRAY Initialise a structure array to store parameter
%values

arr = repmat(struct, N, 1);

if ~isfield(model, 'sigx'), [arr.sigx] = deal(0); end
if ~isfield(model, 'sigy'), [arr.sigy] = deal(0); end
if ~isfield(model, 'beta1'), [arr.beta1] = deal(0); end
if ~isfield(model, 'beta2'), [arr.beta2] = deal(0); end
if ~isfield(model, 'beta3'), [arr.beta3] = deal(0); end
if ~isfield(model, 'alpha'), [arr.alpha] = deal(0); end

% arr = struct('beta1', cell(N,1), ...
%              'beta2', cell(N,1), ...
%              'beta3', cell(N,1), ...
%              'alpha', cell(N,1), ...
%              'sigx', cell(N,1), ...
%              'sigy', cell(N,1));

% arr = struct('sigx', cell(N,1), ...
%              'sigy', cell(N,1));

end

