# 神经网络入门

神经网络快速入门：[神经网络15分钟入门！足够通俗易懂了吧 - 知乎 (zhihu.com)](https://zhuanlan.zhihu.com/p/65472471)

[神经网络15分钟入门！——反向传播到底是怎么传播的？ - 知乎 (zhihu.com)](https://zhuanlan.zhihu.com/p/66534632)

（选看）torch环境安装：[PyTorch环境配置及安装_pytorch配置-CSDN博客](https://blog.csdn.net/weixin_43507693/article/details/109015177)

# LSTM概念

lstm讲解[LSTM - 长短期记忆递归神经网络 - 知乎 (zhihu.com)](https://zhuanlan.zhihu.com/p/123857569)

[史上最详细循环神经网络讲解（RNN/LSTM/GRU） - 知乎 (zhihu.com)](https://zhuanlan.zhihu.com/p/123211148)

# 具体实战

一般而言使用滑动窗口的方式来实现，比如现在有1-100天得数据，假设是降雨量，想预测之后的降雨量，就可以把100天数据按照1-10,2-11,3-12.。。。。。。。这样划分直到91-100划分为91组，对应的输出就是11,12,13，。。。。100天的数据，就是用1-10天的数据转换成元胞数组作为一维的输入，第十一天的数据作为一维的输出，以此类推

滑动窗口概念

[用LSTM进行时间序列预测（单步，多步，单变量，多变量）_lstm时间序列预测-CSDN博客](https://blog.csdn.net/baidu_39332177/article/details/129312922)

[lstm滑动窗口原理 - 百度文库 (baidu.com)](https://wenku.baidu.com/view/d10fd3f76b0203d8ce2f0066f5335a8103d26637.html?_wkts_=1703075398025&bdQuery=lstm滑动窗口是什么意思)

lstm参数设置

[【深度学习】——LSTM参数设置-CSDN博客](https://blog.csdn.net/qq_48108092/article/details/129897604)