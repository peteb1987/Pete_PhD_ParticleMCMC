function [ ppsl_param, ppsl_forw_prob, ppsl_back_prob ] = tracking_paramproposal( algo, known, param, traje, observ )
%TRACKING_PARAMPROPOSAL Propose new parameter values from a proposal
%distribution for MH moves

% This just uses a random walk for now, so the forward and backward
% probabilities are always equal, so we don't need to calculate them.

state = traje.state;
K = known.K;

ppsl_param = param;
ppsl_forw_prob = zeros(length(fieldnames(param)));
ppsl_back_prob = zeros(length(fieldnames(param)));

if ~isfield(known, 'sigx')
    error('This parameter proposal has not been coded.')
end

if ~isfield(known, 'sigy')
    error('This parameter proposal has not been coded.')
end

if ~isfield(known, 'arcoefs')
    error('This parameter proposal has not been coded.')
end

if ~isfield(known, 'sat')
    error('This parameter proposal has not been coded.')
end

if ~isfield(known, 'dof')
    error('This parameter proposal has not been coded.')
end

end

