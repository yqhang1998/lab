%%输一个行数据data，转换为滑动窗口的输出
%获得一个行的数据1*n大小
function windowResult = nkk(data, k)
    dataSize = size(data, 2);  % 获取数据的长度,（1）获取数组的行号size(data,1)（2）获取数组的列号size(data,2)
    number=dataSize-k+1;

    %numWindows = floor((dataSize - windowSize) / stepSize) + 1;  % 计算每个窗口多少元素,向下取整，取不大于x最大整数  
    
    windowResult = zeros(number, 1);  % 初始化存储窗口数据的矩阵,number组数据，每组数据长度为k
    
    for i = 1:dataSize-k+1
        Idx = i+k-1;  % 计算窗口索引     
        windowResult(i, 1) = data(Idx);  % 提取窗口数据
    end
end