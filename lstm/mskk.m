%%输一个行数据data，转换为一个窗口长度为k的元胞数组
function cellArray = mskk(data, k)
    dataSize = size(data, 2);  % 获取数据的长度,（1）获取数组的行号size(data,1)（2）获取数组的列号size(data,2)
    number=dataSize-k+1;    
    windowResult = zeros(number, k);  % 初始化存储窗口数据的矩阵,number组数据，每组数据长度为k    
    for i = 1:dataSize-k+1
        startIdx = i;  % 计算窗口起始索引
        endIdx = i+k - 1;  % 计算窗口终止索引        
        windowResult(i, :) = data(startIdx:endIdx);  % 提取窗口数据
    end
%创建一个空的cell数组，用于存储变换后的每一行元胞数组：
    cellArray = cell(number, 1);
    for i = 1:number
        cellArray{i} = windowResult(i, :);
    end
end