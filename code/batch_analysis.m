%%
num_tests = 5;
num_rpts = 5;

% test_names = {...
%     'PGtests_1_100_',...
%     'PGtests_1_200_',...
%     'PGtests_2_100_',...
%     'PGtests_2_200_',...
%     'PGtests_3_100_'};

test_names = {...
    'PGtests_1_5_1_1',...
    'PGtests_2_10_1_1',...
    'PGtests_3_5_1_1',...
    'PGtests_4_10_1_1',...
    'PGtests_5_5_1_1'};

close all

%% Posterior histograms for a single run
rr = 1;
p = 'sigx';
for tt = 3:5
    
%     name = ['test_results/' test_names{tt} num2str(rr)];
    name = test_names{tt};
    load(name);
    mc = {mc_aa};
    
    % Get chain values and truth
    p_arr = cat(2,mc{1}.param.(p));
    p_true = true_model.(p);
    
    % Plot
    figure, hold on
    [counts,bins] = hist(p_arr(algo.B+1:end), 30);
    bar(bins, counts, 1);
%     hist(p_arr(algo.B+1:end),30);
    plot(p_true*ones(1,2), [0 200], ':k');
    
    % Dressing
    xlim([0.5 2])
    xlabel('$\sigma^2$')
    
    % Save it
    matlab2tikz('figurehandle', gcf, ...
    'filename', [test_names{tt} 'hist.tikz'], ...
    'height', '5cm', ...
    'width', '5cm', ...
    'parseStrings', false);
    
end

%% ACF plots averaged over all runs
colors = 'kkbgr';
styles = {'','','-','--',':'};
p = 'sigx';
max_ac_delay = 100;
figure, hold on, 
for tt = 3:5
    
    D = max_ac_delay;
    acf = zeros(num_rpts,D+1);
    
    for rr = 1:num_rpts
    
%         name = ['test_results/' test_names{tt} num2str(rr)];
        name = test_names{tt};
        load(name);
        mc = {mc_aa};
        
        % Get chain values
        p_arr = cat(2,mc{1}.param.(p));
        
        algo.D = max_ac_delay;
        [ ~, ac ] = parameter_autocorrelation( algo, p_arr );
        
        acf(rr,:) = ac;
        
    end
        
    % Get truth
    p_true = true_model.(p);
    
    % Plot
    plot(0:max_ac_delay, mean(acf,1), 'color', colors(tt), 'LineStyle', styles{tt});
    %plot(0:max_ac_delay, mean(acf,1)+std(acf,1), ':', 'color', colors(tt));
    %plot(0:max_ac_delay, mean(acf,1)-std(acf,1), ':', 'color', colors(tt));
    
    % Dressing
    ylim([0 1]);
    xlabel('Shift')
    ylabel('Autocorrelation')
    legend({'PG-BS (N=100)', 'PG-BS (N=200)', 'PG-RBS (N=100)'});
    
    % Save it
    matlab2tikz('figurehandle', gcf, ...
    'filename', 'mean_acf_plot.tikz', ...
    'height', '5cm', ...
    'width', '5cm', ...
    'parseStrings', false);
    
end

%% Make an illustative plot of poor BS
rng(1)

figure, hold on
K = 10;
N = 10;

X = zeros(N,K);
W = zeros(N,K);
A = zeros(N,K);

for kk = 1:K
    
    if kk > 1
        an = sample_weights(W(:,kk-1),N);
        A(:,kk) = an;
    end 
    
    for ii = 1:N
        
        if kk > 1
            X(ii,kk) = normrnd(X(an(ii),kk-1),0.03);
        else
            X(ii,kk) = normrnd(0,1);
        end
        
        W(ii,kk) = log(normpdf(X(ii,kk),0,1));
        
    end
    
end

for ii = 1:N
    an = sample_weights(W(:,K),N);
    b = an(ii);
    traj = zeros(1,K);
    traj(K) = X(b,K);
    for kk = K-1:-1:1
        b = A(b,kk+1);
        traj(kk) = X(b,kk);
    end
    plot(traj, ':xk')
end
plot(traj, '-xb')
xlabel('time')
ylabel('state')

% Save it
matlab2tikz('figurehandle', gcf, ...
    'filename', 'bs_fail_example.tikz', ...
    'height', '5cm', ...
    'width', '5cm', ...
    'parseStrings', false);
