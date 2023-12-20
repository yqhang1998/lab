%% LSTM 多变量单输出滑动窗口
clear all;
clc;
close all;

filename = '500 2.xls'; % 替换为您的表格文件路径，数据类型为左边一列是测力平台，右边数据是绳子拉力
sheet = 1; % 表示第一个工作表
data = xlsread(filename, sheet);

%% 数据处理
% 归一化（全部特征 均归一化）
output_data =data(:,end-1);%输出的数据，是测力平台数据
input_data =data(:,end);%输入的数据，就是绳子拉力

%% 进行归一化


%output_normdata:归一化后的输出数据
%output_normopt：输出数据的归一化参数
%input_normdata：归一化后的输入数据
%input_normopt：输入数据的归一化参数
[input_normdata,input_normopt] =mapminmax(input_data',0,1);
[output_normdata,output_normopt] = mapminmax(output_data',0,1);

%% 滑动窗口,将数据处理为元胞数组，滑动窗口大小为k
%输入数据变成input_normdatacell，输出数据变成output_normdatacell
k =20;                                                               
%[input_normdatacell,output_normdatacell]=msk(k);
input_normdatacell=mskk(input_normdata,k);
output_normdatacell=nkk(output_normdata,k);                                                                    


% %% 打乱数据
% random_order = randperm(numel(input_normdatacell));
% 
% % 根据随机顺序重新排序元胞数组
% input_normdatacell = input_normdatacell(random_order);
% 
% output_normdatacell = output_normdatacell(random_order);


%% 划分数据集
n = floor(0.85*size(input_normdatacell,1));                          %训练集，测试集样本数目划分
input_xtraincell = input_normdatacell(1:n,:);%训练集输入为前面80%行的数据                                
output_ytraincell = output_normdatacell(1:n,:);%训练集输出
input_xtestcell = input_normdatacell(n+1:end,:);%测试集输入
output_ytestcell = output_normdatacell(n+1:end,:);%测试集输出


%% 生成随机的索引顺序
random_order = randperm(numel(input_xtraincell));

% 根据随机顺序重新排序元胞数组
input_xtraincell = input_xtraincell(random_order);

output_ytraincell = output_ytraincell(random_order);
%% lstm参数设置
% LSTM 层设置，参数设置
inputSize = size(input_normdata,1);   %数据输入x的特征维度，目前是1
outputSize = size(output_normdata,1);  %数据输出y的特征维度，目前是1  
numhidden_units1=128;%设置隐藏层单元数128
numhidden_units2=128;
% lstm
layers = [ ...
    sequenceInputLayer(inputSize,'name','input')                             %输入层设置
    lstmLayer(numhidden_units1,'Outputmode','sequence')     %隐藏层1
    dropoutLayer(0.3,'name','dropout_1')                                     %隐藏层1权重丢失率，防止过拟合
    lstmLayer(numhidden_units2,'Outputmode','last')     %隐藏层2
    dropoutLayer(0.3,'name','dropout_2')                                    %隐藏层2权重丢失率，防止过拟合
    fullyConnectedLayer(outputSize,'name','fullconnect')                     %全连接层设置（outputsize:预测值的特征维度）
    regressionLayer];                                          %回归层（因为负荷预测值为连续值，所以为回归层） 

% trainoption
opts = trainingOptions('adam', ...        %优化算法
    'MaxEpochs',100, ...                   %遍历样本最大循环数
    'GradientThreshold',1,...             %梯度阈值
    'ExecutionEnvironment','cpu',...      %运算环境
    'InitialLearnRate',0.001, ...         %初始学习率
    'LearnRateSchedule','piecewise', ...  % 学习率计划
    'LearnRateDropPeriod',2, ...          %2个epoch后学习率更新
    'LearnRateDropFactor',0.9, ...        %学习率衰减速度
    'MiniBatchSize',64,...             % 批处理样本大小
    'Verbose',0, ...                      %命令控制台是否打印训练过程
    'Plots','training-progress'...        % 打印训练进度
    );
   % 'Shuffle','once',...                  % 是否重排数据顺序，防止数据中因连续异常值而影响预测精度
   % 'SequenceLength',1,...               %LSTM时间步长


%% 网络训练
net = trainNetwork(input_xtraincell,output_ytraincell,layers,opts);      %网络训练


%% 保存模型参数
save('lstm_model.mat','net')
disp('网络已保存')
save('lstm_modelpara.mat','input_normopt','output_normopt')
disp('归一化参数已保存')
                                         
%% 预测
yprenorm = net.predict(input_xtestcell);   %动态更新，预测

ypre = mapminmax('reverse',yprenorm',output_normopt);          %预测值反归一化
yytest = mapminmax('reverse',output_ytestcell',output_normopt); 

for i =1:1
    subplot(2,1,1)  
%plot(yprenorm','r:o','Color',[255 0 0]./255,'linewidth',0.8,'Markersize',4,'MarkerFaceColor',[255 0 0]./255)
plot(ypre,'r:o','Color',[255 0 0]./255,'linewidth',0.8,'Markersize',4,'MarkerFaceColor',[255 0 0]./255)
hold on;
%plot(output_ytestcell','k-s','Color',[0 0 0]./255,'linewidth',0.8,'Markersize',5,'MarkerFaceColor',[0 0 0]./255)
plot(yytest,'k:s','Color',[0 0 0]./255,'linewidth',0.4,'Markersize',5,'MarkerFaceColor',[0 0 0]./255)
legend('预测值','实际值')
xlabel('测试集序列号');
ylabel('末端接触力大小(cN)');
title('测试集预测结果');
subplot(2,1,2)
stem(ypre-yytest,'b','linewidth',0.8);
%stem(yprenorm'-output_ytestcell','b','linewidth',0.8);
legend('绝对误差')
xlabel('测试集序列号');
 axis([0 2500 -15 40]);
ylabel('绝对误差(cN)');
title('测试集绝对误差');
end

%RMSE  = sqrt(mean((yprenorm'-output_ytestcell').^2));
RMSE  = sqrt(mean((ypre-yytest).^2));
MAPE  = mean((ypre-yytest)./yytest);
disp(["RMSE2  ",RMSE ])
disp(["MAPE2 ", MAPE])






