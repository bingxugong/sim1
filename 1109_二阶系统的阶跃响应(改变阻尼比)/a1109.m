clear; clc; close all;
% ===== 自动切换到m文件所在目录，slx、图片和m同文件夹 =====
mfilepath = mfilename('fullpath');
[mfolder,~,~] = fileparts(mfilepath);
cd(mfolder);
modelname = 'second_order_step';
slx_path = [modelname '.slx'];
%% ========== 分段：存在slx就跳过建模 ==========
if ~isfile(slx_path)
    disp('slx不存在，开始新建、搭建模型...');
    if bdIsLoaded(modelname)
        close_system(modelname,0);
    end
    new_system(modelname);
    open_system(modelname);
    %% 添加模块（Step）
    add_block('simulink/Sources/Step',                  [modelname '/Step']);
    add_block('simulink/Continuous/Transfer Fcn',       [modelname '/Transfer Fcn']);
    add_block('simulink/Sinks/Scope',                    [modelname '/Scope']);
    add_block('simulink/Sinks/To Workspace',             [modelname '/To Workspace']);
    %% 连线
    add_line(modelname,'Step/1','Transfer Fcn/1');
    add_line(modelname,'Transfer Fcn/1','Scope/1');
    add_line(modelname,'Transfer Fcn/1','To Workspace/1');
    %% Step 正确底层参数 Time / Before / After
    set_param([modelname '/Step'], ...
        'Time','0', ...
        'Before','0', ...
        'After','1');
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
%% 仿真循环，改变阻尼比zeta，绘制单位阶跃响应
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
ylabel('单位阶跃响应 $y(t)$','Interpreter','latex');
title('二阶系统阶跃响应 $\omega_n=1\ \mathrm{rad/s}$','Interpreter','latex');
legend('Location','best');
hold off;
%% 保存图片
pic_name = 'second_order_step_response.png';
exportgraphics(fig, pic_name, 'Resolution',300);
disp(['图片已保存到：',pwd,filesep,pic_name]);
disp('仿真绘图完成！');
