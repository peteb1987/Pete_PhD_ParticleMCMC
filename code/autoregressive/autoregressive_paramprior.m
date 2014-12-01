function [ prob ] = autoregressive_paramprior(  algo, known, param )
%AUTOREGRESSIVE_PARAMPRIOR Evaluate probabilites for parameter
%priors

if isfield(known, 'sigx'), sigx = known.sigx; else sigx = param.sigx; end
if isfield(known, 'sigy'), sigy = known.sigy; else sigx = param.sigy; end
if isfield(known, 'arcoefs'), arcoefs = known.arcoefs; else sigx = param.arcoefs; end
if isfield(known, 'sat'), sat = known.sat; else sigx = param.sat; end
if isfield(known, 'dof'), dof = known.dof; else sigx = param.dof; end

prob = zeros(length(fieldnames(param)));

if ~isfield(known, 'sigx')
    error('This parameter prior has not been coded.')
end

if ~isfield(known, 'sigy')
    error('This parameter prior has not been coded.')
end

if ~isfield(known, 'arcoefs')
    error('This parameter prior has not been coded.')
end

if ~isfield(known, 'sat')
    error('This parameter prior has not been coded.')
end

if ~isfield(known, 'dof')
    error('This parameter prior has not been coded.')
end

end

