% Code for Koopman operator learning and CBF based safety filtering
% Written by Yuxiao Chen and Carl Folkestad
% California Institute of Technology, 2020

clc; clear; clf; close all; addpath('controllers','dynamics','koopman_learning','utils','utils/qpOASES-3.1.0/interfaces/matlab')

%% Define experiment parameters:

%State constraints and backup controller parameters:
global Ts T_max vm rm am x_bdry
Ts = 0.1;                                           % Sampling interval
T_max = 2;
vm = 0.15;                                          % Maximum velocity
rm = 3*pi/2;                                        % Maximum yaw rate
am = 0.1;                                           % Maximum acceleration
x_bdry = [-1.6 1.6;-1 1;vm vm;0 2*pi];              % State constraints
ts = 0.02;
N_max = ceil(vm/am/Ts);                             % Maximum backup controller horizon

affine_dynamics = @(x) dubin(x);                    % System dynamics, returns [f,g] with x_dot = f(x) + g(x)u
                                                    % State is defined as x = [X,Y,v,theta], u = [a,r]
backup_controller = @(x) [-am*sign(x(3));rm];        % Backup controller (max brake and max turn)
controller_process = @(u) u;
stop_crit1 = @(t,x)(abs(x(3))<=0);                  % Stop if velocity is zero
sim_dynamics = @(x,u) dubin_sim(x,u);               % System dynamics used for simulation
sim_process = @(x,ts) dubin_sim_process(x,ts);      % Processing of states while simulating
initial_condition = @() x_bdry(:,1)+...
    (x_bdry(:,2)-x_bdry(:,1)).*rand(4,1);           % Sample random initial value of x inside x_bdry

%Koopman learning parameters:
dubin_dictionary;                                   % Generate dictionary for Dubin's car system
func_dict = @(x) dubin_D(x(1),x(2),x(3),x(4));      % Function dictionary, returns [D,J] = [dictionary, jacobian of dictionary]
n_samples = 100;                                    % Number of initial conditions to sample for training

%Collision avoidance experiment parameters:
global T_exp obs r
x0 = [0;0;vm;0];                                    % Initial condition for experiment
x_des = [1;0;0;0];                                  % Desired state for legacy controller
mpc_horizon = 20;                                   % Time horizon of legacy controller
legacy_controller = @(x) MIQP_MPC_v3(x,x_des,20);   % Legacy controller (MPC)
options = qpOASES_options('printLevel',0);          % Solver options for supervisory controller
T_exp = 10;                                         % Experiment length
alpha = 2;                                          % CBF strengthening parameter
obs = [0.5;0];                                      % Center of circular obstacle
r = 0.05;                                           % Radius of circular obstacle
barrier_func = @(x) round_obs(x,obs,r);             % Barrier function

%% Learn approximated discrete-time Koopman operator:

[T_train, X_train] = collect_data(sim_dynamics, sim_process, backup_controller, controller_process, stop_crit1, initial_condition, n_samples, ts); 
[K, C] = edmd(X_train, func_dict);
K_pows = precalc_matrix_powers(N_max,K);

%L = calc_lipschitz(4,2, affine_dynamics, con1); 
L = 0;  
e_max = calc_max_residual(X_train, func_dict, K, C);
tt = 0:Ts:Ts*N_max;
error_bound = @(x) koopman_error_bound(x,X_train,L,e_max,tt,K_pows,C,func_dict);

plot_training_fit(X_train, K_pows, C, func_dict, error_bound);

%% Evaluate Koopman approximation on test data:

[T_test, X_test] = collect_data(sim_dynamics, sim_process, backup_controller, controller_process, stop_crit1, initial_condition, n_samples, ts); 
plot_test_fit(X_train, X_test, K_pows, C, func_dict, error_bound);

%% Evaluate Koopman based CBF safety filter:

supervisory_controller = @(x,u0,N) koopman_qp_cbf_static(x, u0, N, affine_dynamics, barrier_func, alpha, func_dict, K_pows, C, options); 
[x_rec, u_rec, u0_rec] = run_experiment(x0, sim_dynamics, sim_process, legacy_controller, supervisory_controller); 
plot_experiment(x_rec, u_rec, u0_rec, func_dict, K_pows, C);

%% Save learned matrices to use in other experiments:
close all;
save('data/dubin_learned_koopman.mat','K_pows','C','N_max')