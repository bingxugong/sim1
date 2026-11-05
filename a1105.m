clear; clc; close all;
modelname = 'second_order_impulse';

% 如果模型已经打开，先关掉
if bdIsLoaded(modelname)
    close_system(modelname,0);
end

% 新建Simulink模型
new_system(modelname);
open_system(modelname);

%% 添加模块
add_block('simulink/Sources/Pulse Generator',        [modelname '/Pulse Generator']);
add_block('simulink/Continuous/Transfer Fcn',       [modelname '/Transfer Fcn']);
add_block('simulink/Sinks/Scope',                    [modelname '/Scope']);
add_block('simulink/Sinks/To Workspace',             [modelname '/To Workspace']);

%% 【修复连线！全部用 /1】
add_line(modelname,'Pulse Generator/1','Transfer Fcn/1');
add_line(modelname,'Transfer Fcn/1','Scope/1');
add_line(modelname,'Transfer Fcn/1','To Workspace/1');

%% 模块参数设置：窄脉冲近似单位脉冲（面积≈1）
set_param([modelname '/Pulse Generator'], ...
    'Amplitude','1000', ...
    'Period','20', ...
    'PulseWidth','0.001');

set_param([modelname '/To Workspace'], ...
    'VariableName','yout', ...
    'SaveFormat','Array');

% 保存 slx
save_system(modelname, [modelname '.slx']);
disp(['模型保存至：',pwd,filesep,modelname,'.slx']);

%% 遍历阻尼比仿真绘图
wn = 1;
zeta_list = [0, 0.3, 0.707, 1, 1.5, 2];
t_end = 15;

figure('Color','w'); hold on; grid on;
colors = lines(length(zeta_list));

for i = 1:length(zeta_list)
    zeta = zeta_list(i);
    num  = wn^2;
    den  = [1, 2*zeta*wn, wn^2];
    set_param([modelname '/Transfer Fcn'], ...
        'Numerator', mat2str(num), ...
        'Denominator', mat2str(den));
    set_param(modelname, 'StopTime', num2str(t_end));
    
    out = sim(modelname);
    t_sim = out.tout;
    y_sim = out.yout;
    
    plot(t_sim, y_sim, ...
        'Color', colors(i,:), ...
        'LineWidth',1.5, ...
        'DisplayName',sprintf('\\zeta = %.2f',zeta));
end

xlabel('t (s)');
ylabel('近似单位脉冲响应');
title('二阶系统脉冲响应（Simulink自动模型 \omega_n=1 rad/s）');
legend('Location','best');
hold off;

