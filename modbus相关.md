modbus相关

官方函数手册[(59条消息) libmodbus官方手册中文翻译_modbus_read_bits_跃动的风的博客-CSDN博客](https://blog.csdn.net/qq_23670601/article/details/82155378)

ubuntu串口操作[(62条消息) Ubuntu关于串口的操作(查看串口信息、串口助手、串口权限)_ubuntu 查看串口_万俟淋曦的博客-CSDN博客](https://blog.csdn.net/maizousidemao/article/details/103236666)

modbus读传感器流程[使用libmodbus读传感器流程-stuyou-ChinaUnix博客](http://blog.chinaunix.net/uid-11829250-id-5750606.html)

ros中读取[在ROS中使用libmodbus读取传感器数据-CSDN博客](https://blog.csdn.net/qq_45446095/article/details/130273284?ops_request_misc=&request_id=&biz_id=102&utm_term=modbus读传感器&utm_medium=distribute.pc_search_result.none-task-blog-2~all~sobaiduweb~default-2-130273284.142^v96^pc_search_result_base3&spm=1018.2226.3001.4187)

（建议先看这个）***详细的使用流程***：[Ubuntu下libmodbus的应用_ubuntu modbus-CSDN博客](https://blog.csdn.net/Witty_Hou/article/details/123577265?spm=1001.2014.3001.5501)





modbus读取ros下的代码：

```c++
//talker.cpp
#include <unistd.h>
#include "modbus.h"
#include "ros/ros.h"
#include "std_msgs/String.h"
#include "modbus/push.h"
#include <cmath>
#include <sstream>
#include <serial/serial.h>
#include <string>
#include <std_msgs/UInt64.h>
#include <chrono>
#include <vector>
using namespace std;


int main(int argc, char **argv)
{
	ros::init(argc,argv,"talker");
	ros::NodeHandle nh;
		
	uint16_t tab_reg1[10] = {0};
	uint16_t tab_reg2[10] = {0};
	uint16_t tab_reg3[10] = {0};
	uint16_t tab_reg4[10] = {0};
	uint16_t tab_reg5[10] = {0};
	modbus_t* mb1 = modbus_new_rtu("/dev/ttyUSB0", 115200, 'N', 8, 1);  
	modbus_t* mb2= modbus_new_rtu("/dev/ttyUSB1", 115200, 'N', 8, 1);
	
	if (mb1 == NULL) {
		ROS_INFO( "Unable to create the libmodbus(mb) context\n");
		return -1;
	}
	
	if (mb2 == NULL) {
		ROS_INFO( "Unable to create the libmodbus(mb2) context\n");
		return -1;
	}
	int rc1 = modbus_set_slave(mb1, 01);  
	int rc2 = modbus_set_slave(mb2, 01);  
	
	if (rc1 == -1) {
		ROS_INFO( "Invalid slave ID1\n");
		modbus_free(mb1);
		return -1;
	}
	
	if (rc2 == -1) {
		ROS_INFO( "Invalid slave ID2\n");
		modbus_free(mb2);
		return -1;
	}
	
	if (modbus_connect(mb1) == -1) {
		ROS_INFO("Connection1 failed\n");
		modbus_free(mb1);
		return -1;
	}
	
	if (modbus_connect(mb2) == -1) {
		ROS_INFO("Connection2 failed\n");
		modbus_free(mb2);
		return -1;
	}
	
	struct timeval t1;
        t1.tv_sec=0;
        t1.tv_usec=1000000;        //set modbus time 1000ms
        modbus_set_response_timeout(mb1,&t1);
        
        //设置第二个环境的t
        struct timeval t2;
        t2.tv_sec=0;
        t2.tv_usec=1000000;        //set modbus time 1000ms
        modbus_set_response_timeout(mb2,&t2);
       
	ros::Publisher pub = nh.advertise<modbus::push>("chatter", 10);
	//创建timeout  ms
    	serial::Timeout to = serial::Timeout::simpleTimeout(1000);
    	serial::Serial sp;
    	//设置要打开的串口名称
    	sp.setPort("/dev/ttyS1");
    	//设置串口通信的波特率
    	sp.setBaudrate(115200);
    	//串口设置timeout
    	sp.setTimeout(to);
    	try
    	{
        //打开串口
        	sp.open();
    	}
    	catch(serial::IOException& e)
    	{
        	ROS_ERROR_STREAM("Unable to open port.");
        	return -1;
    	}
 
    	//传感器归零	
    	modbus_write_register(mb1, 80, 1);
    	modbus_write_register(mb1, 594, 1);
    	modbus_write_register(mb1, 1094, 1);
    	modbus_write_register(mb1, 1594, 1);

    	//判断串口是否打开成功
    	if(sp.isOpen())
    	{
        	ROS_INFO_STREAM("/dev/ttyS1 is opened.");
    	}
    	else
    	{
        	return -1;
    	}

	ros::Rate loop_rate(100);
        while(ros::ok()) 
        {

    	    
	    modbus::push msg;

	    
	   	    
	    int du1 = modbus_read_registers(mb2, 80, 2, tab_reg1); 
	    
	    int du2 = modbus_read_registers(mb1, 80, 2, tab_reg2); 
	    int du3 = modbus_read_registers(mb1, 580, 2, tab_reg3);
	    int du4 = modbus_read_registers(mb1, 1080, 2, tab_reg4);
	    int du5 = modbus_read_registers(mb1, 1580, 2, tab_reg5);
	    msg.data1=tab_reg1[1];   //测力平台数据
	
	    msg.data2=tab_reg2[1];  //ch1数据，对应电机4
	    msg.data3=tab_reg3[1]; //ch2数据，对应电机1
	    msg.data4=tab_reg4[1]; //ch3数据，对应电机2
	    msg.data5=tab_reg5[1]; //ch4数据，对应电机3
	    
	    unsigned short crc1 = CRC_Check(tab_reg1,10);
	    unsigned short crc2 = CRC_Check(tab_reg5,10);
	    ROS_INFO("CRC1:%u,CRC2:%u\n",crc1,crc2);
	    

            string result=" "+to_string(msg.data1)+" "+to_string(msg.data5)+"\n";//只发送测力平台数据和ch4的数据
            sp.write(reinterpret_cast<const uint8_t*>(result.c_str()), result.length());


   	    pub.publish(msg);     
            loop_rate.sleep();
         }

         modbus_close(mb1);
         modbus_free(mb1);
         modbus_close(mb2);
         modbus_free(mb2);
         sp.close();
         return 0;
}

```

```c++
//listener.cpp
//这个节点专门用于扭矩传感器，因为扭矩传感器涉及方向正负号
//扭矩传感器中msg.data1为符号位，转换为十进制显示只有0或者-1
 //msg.data2为数据位，显示具体数值，由于msg消息为int16型，所以二进制转换成%d输出后自带正负号
 //扭矩传感器最大显示10000，原数据是uint16_t转化成int16存储不会发生数据丢失
#include <unistd.h>
#include "modbus.h"
#include "ros/ros.h"
#include "std_msgs/String.h"
#include "modbus/push.h"



void twistCallback(const modbus::push& msg)
{ 
    setlocale(LC_ALL, "");
    	ROS_INFO("传感器数据显示:%d,  %d,  %d,  %d,  %d",(int)msg.data1,(int)msg.data2,(int)msg.data3,(int)msg.data4,(int)msg.data5);
    /*}else
    {
      ROS_INFO("传感器显示数据:%d%d",msg.data1, msg.data2);
    }*/
}



int main(int argc, char **argv)
{
    ros::init(argc,argv,"listener");
    ros::NodeHandle nh;
    ros::Subscriber sub=nh.subscribe("chatter",10,twistCallback);
    ros::spin();
    return 0;
}
```

