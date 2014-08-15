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
    
    sigx = mvnrnd(param.sigx, algo.ppsl_sigx_vr);
    sigx = max(sigx, 0.01);
    ppsl_param.sigx = sigx;
    
end

if ~isfield(known, 'decay')
end

if ~isfield(known, 'sigtheta')
end

if ~isfield(known, 'sigphi')
end

if ~isfield(known, 'sigr')
end

if ~isfield(known, 'bias')
end

end

