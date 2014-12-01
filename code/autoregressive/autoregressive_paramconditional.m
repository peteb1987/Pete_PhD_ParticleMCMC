function [ param ] = autoregressive_paramconditional( algo, known, param, traje, observ )
%AUTOREGRESSIVE_PARAMCONDITIONAL Sample parameters conditional upon states for
%the autoregressive model

state = traje.state;
K = known.K;

if isfield(known, 'sigx'), sigx = known.sigx; else sigx = param.sigx; end
if isfield(known, 'sigy'), sigy = known.sigy; else sigx = param.sigy; end
if isfield(known, 'arcoefs'), arcoefs = known.arcoefs; else sigx = param.arcoefs; end
if isfield(known, 'sat'), sat = known.sat; else sigx = param.sat; end
if isfield(known, 'dof'), dof = known.dof; else sigx = param.dof; end



if ~isfield(known, 'sigx')
    error('This parameter conditional has not been coded.')
end

if ~isfield(known, 'sigy')
    error('This parameter conditional has not been coded.')
end

if ~isfield(known, 'arcoefs')
    error('This parameter conditional has not been coded.')
end

if ~isfield(known, 'sat')
    error('This parameter conditional has not been coded.')
end

if ~isfield(known, 'dof')
    error('This parameter conditional has not been coded.')
end

end

