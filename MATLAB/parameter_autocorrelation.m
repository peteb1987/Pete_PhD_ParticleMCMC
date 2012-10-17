function [ delay, ac ] = parameter_autocorrelation( algo, mc_param )
%PARAMETER_AUTOCORRELATION Calculate autocorrelation of parameter samples
%from Markov chain

delay = (0:algo.max_ac_delay)';
ac_sigx = zeros(length(delay),1);
ac_sigy = zeros(length(delay),1);

sigx = cat(2, mc_param.sigx);
sigy = cat(2, mc_param.sigy);

for ii = 1:length(delay)
    
    dd = delay(ii);
    
    sigx_est_mn = sum(sigx(algo.burn_in:end))/(algo.R - algo.burn_in);
    sigx_est_vr = sum((sigx(algo.burn_in:end)-sigx_est_mn).^2)/(algo.R - algo.burn_in);
    ac_sigx(ii) = sum( (sigx(algo.burn_in+dd+1:end)-sigx_est_mn).*(sigx(algo.burn_in+1:end-dd)-sigx_est_mn) )/((algo.R - dd - algo.burn_in)*sigx_est_vr);
    
    sigy_est_mn = sum(sigy(algo.burn_in:end))/(algo.R - algo.burn_in);
    sigy_est_vr = sum((sigy(algo.burn_in:end)-sigy_est_mn).^2)/(algo.R - algo.burn_in);
    ac_sigy(ii) = sum( (sigy(algo.burn_in+dd+1:end)-sigy_est_mn).*(sigy(algo.burn_in+1:end-dd)-sigy_est_mn) )/((algo.R - dd - algo.burn_in)*sigy_est_mn);
    
end

ac.sigx = ac_sigx;
ac.sigy = ac_sigy;

end

