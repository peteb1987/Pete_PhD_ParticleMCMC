% Batch testing script for particle Gibbs

% Add toolboxes to path
addpath('../toolbox/user');
addpath('../toolbox/lightspeed');
addpath('../toolbox/ekfukf');
addpath('../toolbox/imported');

% Clean up
clup

% Get environment variable specifying test number
sys_num = str2double(getenv('SGE_TASK_ID'));
if isnan(sys_num)
    sys_num = 0;
end

fprintf(1, 'System count number: %u.\n', sys_num);

% Function handles for the model
addpath('tracking')
fh.model = 'tracking_setmodel';
fh.algo = 'tracking_setalgo';
fh.gendata = 'tracking_generatedata';
fh.stateprior = 'tracking_stateprior';
fh.transition = 'tracking_transition';
fh.observation = 'tracking_observation';
fh.stateproposal = 'tracking_stateproposal';
fh.paramconditional = 'tracking_paramconditional';

% Set display options
display.text = true;
display.plot = false;

% Set test flags
test.batch = true;
test.model = 2;             % tracking

% Test number
test_num = rem(sys_num-1,5)+1;
rpt_num = floor((sys_num+4)/5);

%%% TEST CASES %%%
algos = [1 1 2 2 3];
parts = [100 200 100 200 100];

test.algorithms = algos(test_num);
test.filter_particles = parts(test_num);
rand_seed = rpt_num;
test.name = ['PGtests_' num2str(test.algorithms) '_' num2str(test.filter_particles) '_' num2str(rpt_num)];

% Run the script
particle_gibbs_test;

% Save results
save(test.name, 'rand_seed', 'algo', 'model', 'known', 'state', 'observ', 'rt', 'mc');

% SHOW WE'VE FINISHED
disp(['Test:' num2str(sys_num) ' - DONE!']);
