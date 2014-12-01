% Batch testing script for particle Gibbs

% Add toolboxes to path
addpath('../toolbox/pjb-utilities');
addpath('../toolbox/lightspeed');
addpath('../toolbox/ekfukf');
addpath('../toolbox/imported');

% Clean up
clup

% Get environment variable specifying test number
sys_num = str2double(getenv('SGE_TASK_ID'));
if isnan(sys_num)
    sys_num = 5;
end

fprintf(1, 'System count number: %u.\n', sys_num);

% Set display options
display.text = true;
display.plot = false;

% Set test flags
test.batch = true;
test.model = 1;             % tracking

% Test number
test_num = rem(sys_num-1,5)+1;
rpt_num = floor((sys_num+4)/5);

%%% TEST CASES %%%
mcmc = [1 1 3 3 3];
anc_samp = [NaN NaN 2 2 3];
parts = [100 200 100 200 100];

% Model to use
test.model_flag = 1;

% Define algorithms to run. Make sure these are all the same length
test.mcmc_type = mcmc(test_num);
test.ppsl_type = 2;
test.ref_traj_type = 1;
test.anc_samp_type = anc_samp(test_num);
test.filter_particles = parts(test_num);

test.num_mc_iterations = 2500;

rand_seed = rpt_num;
test.name = ['PGtests_' num2str(test_num) '_' num2str(test.filter_particles) '_' num2str(rpt_num)];
filenameroot = test.name;

% Run the script
particle_gibbs_test;

% SHOW WE'VE FINISHED
disp(['Test:' num2str(sys_num) ' - DONE!']);
