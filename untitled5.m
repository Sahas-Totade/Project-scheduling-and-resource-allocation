%% Optimized Project Scheduling and Resource Allocation Matrix
% Author: Goldfish Prodigy
% Description: Implements the Critical Path Method (CPM) using topological 
%              sorting and poset relations to optimize project timelines, 
%              isolate bottlenecks, and compute task float (slack).

clear; clc; close all;

%% 1. Define Task Set and Dependencies (Poset Representation)
% Tasks: A=1, B=2, C=3, D=4, E=5, F=6
task_names = {'Task A: Requirements', 'Task B: Architecture Design', ...
              'Task C: Core Algorithmic Engine', 'Task D: GUI Implementation', ...
              'Task E: Integration Testing', 'Task F: System Deployment'};
          
durations = [5, 7, 10, 4, 6, 2]; % Time units (e.g., days)
num_tasks = length(durations);

% Adjacency Matrix defining dependency relations (Partial Ordering)
% If adj(i, j) == 1, then task i must finish before task j can begin.
adj = zeros(num_tasks, num_tasks);
adj(1, 2) = 1; % A -> B
adj(2, 3) = 1; % B -> C
adj(2, 4) = 1; % B -> D
adj(3, 5) = 1; % C -> E
adj(4, 5) = 1; % D -> E
adj(5, 6) = 1; % E -> F

%% 2. Forward Pass: Compute Earliest Start (ES) and Earliest Finish (EF)
ES = zeros(1, num_tasks);
EF = zeros(1, num_tasks);

% Simple topological approach assuming tasks are ordered logically in indices
for i = 1:num_tasks
    % Earliest Start is the maximum Earliest Finish of all immediate predecessors
    predecessors = find(adj(:, i) == 1);
    if isempty(predecessors)
        ES(i) = 0;
    else
        ES(i) = max(EF(predecessors));
    end
    EF(i) = ES(i) + durations(i);
end

total_project_duration = max(EF);

%% 3. Backward Pass: Compute Latest Finish (LF) and Latest Start (LS)
LF = total_project_duration * ones(1, num_tasks);
LS = zeros(1, num_tasks);

for i = num_tasks:-1:1
    % Latest Finish is the minimum Latest Start of all immediate successors
    successors = find(adj(i, :) == 1);
    if ~isempty(successors)
        LF(i) = min(LS(successors));
    end
    LS(i) = LF(i) - durations(i);
end

%% 4. Calculate Slack (Total Float) and Identify Critical Path
% Slack = LF - EF (or LS - ES). If slack is 0, the task is on the critical path.
slack = LF - EF;
critical_path_mask = (slack == 0);

%% 5. Visualization: Gantt Chart Generation
figure('Name', 'Project Scheduling Optimization Framework', 'Position', [100, 100, 900, 450]);
hold on;

for i = 1:num_tasks
    % Assign red for critical bottleneck tasks, green for flexible tasks
    if critical_path_mask(i)
        bar_color = [0.85 0.33 0.10]; % Red/Orange
    else
        bar_color = [0.47 0.67 0.19]; % Muted Green
    end
    
    % Plot active working duration bar
    rectangle('Position', [ES(i), i-0.25, durations(i), 0.5], 'FaceColor', bar_color, 'EdgeColor', 'k');
    
    % Plot slack line if it exists
    if slack(i) > 0
        line([EF(i), LF(i)], [i, i], 'Color', 'k', 'LineWidth', 1.5, 'LineStyle', ':');
        plot(LF(i), i, 'k|', 'MarkerSize', 8);
    end
end

grid on;
set(gca, 'YTick', 1:num_tasks, 'YTickLabel', task_names, 'YDir', 'reverse');
xlabel('Project Timeline Horizon (Days)');
title('Critical Path Optimization and Slack Distribution Profile');
xlim([0, total_project_duration + 2]);

%% 6. Diagnostic Console Report
fprintf('=== Critical Path Management Metrics ===\n');
fprintf('Minimum Total Project Duration: %d Days\n\n', total_project_duration);
fprintf('%-32s | %-4s | %-4s | %-5s\n', 'Task Name', 'ES', 'LF', 'Slack Status');
fprintf('-----------------------------------------------------------------\n');
for i = 1:num_tasks
    if critical_path_mask(i)
        status = 'CRITICAL PATH';
    else
        status = sprintf('Flexible (+%dd)', slack(i));
    end
    fprintf('%-32s | %-4d | %-4d | %-s\n', task_names{i}, ES(i), LF(i), status);
end