function [ delay, ac ] = parameter_autocorrelation( algo, p_arr )
%PARAMETER_AUTOCORRELATION Calculate autocorrelation of parameter samples
%from Markov chain

% Mean and variance of chain
est_mn = mean(p_arr(:,algo.B:end),2);
ds = length(est_mn);
est_vr = zeros(ds);
for kk = algo.B:algo.R
    err = p_arr(:,kk) - est_mn;
    est_vr = est_vr + err*err';
end
est_vr = est_vr/(algo.R+1 - algo.B);

delay = 0:algo.D;
ac = zeros(ds,length(delay));

for ii = 1:length(delay)
    
    dd = delay(ii);
    
    cvr = zeros(ds);
    for kk = algo.B:algo.R-dd
        err1 = p_arr(:,kk) - est_mn;
        err2 = p_arr(:,kk+dd) - est_mn;
        cvr = cvr + err1*err2';
    end
    cvr = cvr/(algo.R+1-algo.B-dd)';
    ac(:,ii) = ( diag(cvr)./diag(est_vr) )';
    
end

end

