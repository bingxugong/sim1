clear; clc; close all;
% ===== 自动切换到m文件所在目录，slx、图片和m同文件夹 =====
mfilepath = mfilename('fullpath');
[mfolder,~,~] = fileparts(mfilepath);
cd(mfolder);

modelname = 'second_order_impulse';
slx_path = [modelname '.slx'];

%% ========== 分段：存在slx就跳过建模 ==========
if ~isfile(slx_path)
    disp('slx不存在，开始新建、搭建模型...');
    if bdIsLoaded(modelname)
        close_system(modelname,0);
    end
    new_system(modelname);
    open_system(modelname);
    %% 添加模块
    add_block('simulink/Sources/Pulse Generator',        [modelname '/Pulse Generator']);
    add_block('simulink/Continuous/Transfer Fcn',       [modelname '/Transfer Fcn']);
    add_block('simulink/Sinks/Scope',                    [modelname '/Scope']);
    add_block('simulink/Sinks/To Workspace',             [modelname '/To Workspace']);
    %% 连线
    add_line(modelname,'Pulse Generator/1','Transfer Fcn/1');
    add_line(modelname,'Transfer Fcn/1','Scope/1');
    add_line(modelname,'Transfer Fcn/1','To Workspace/1');
    %% 参数
    set_param([modelname '/Pulse Generator'], ...
        'Amplitude','1000', ...
        'Period','20', ...
        'PulseWidth','0.001');
    set_param([modelname '/To Workspace'], ...
        'VariableName','yout', ...
        'SaveFormat','Array');
    save_system(modelname, slx_path);
    disp(['模型已新建保存：',pwd,filesep,slx_path]);
else
    disp('slx文件已存在，跳过建模，直接加载模型！');
    if ~bdIsLoaded(modelname)
        open_system(slx_path);
    end
end

%% 仿真循环
wn = 1;
zeta_list = [0, 0.3, 0.707, 1, 1.5, 2];
t_end = 15;

fig = figure('Color','w'); hold on; grid on;
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
ylabel('近似单位脉冲响应 $y(t)$','Interpreter','latex');
title('二阶系统脉冲响应 $\omega_n=1\ \mathrm{rad/s}$','Interpreter','latex');
legend('Location','best');
hold off;

%% 保存图片
pic_name = 'second_order_impulse_response.png';
exportgraphics(fig, pic_name, 'Resolution',300);
disp(['图片已保存到：',pwd,filesep,pic_name]);

disp('仿真绘图完成！');
