//****************************************Copyright (c)***********************************//                             
//----------------------------------------------------------------------------------------
// File name:           uart_loop
// Last modified Date:  2023/4/27 15:02:00
// Last Version:        V1.1
// Descriptions:        UART串口数据处理模块
//----------------------------------------------------------------------------------------
// Created by:          技术小董
// Created date:        2023/4/27 15:02:00
// Version:             V1.0
// Descriptions:        The original version
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module uart_loop(
    input	         sys_clk,                   //系统时钟
    input            sys_rst_n,                 //系统复位，低电平有效
     
    input            recv_done,                 //接收一帧数据完成标志
    input      [7:0] recv_data,                 //接收的数据
	 
	input            start_status,              //定义启动状态
	input            stop_status,               //定义停止状态
     
    input            tx_busy,                   //发送忙状态标志      
    output reg       send_en,                   //发送使能信号
    output reg [7:0] send_data,                 //待发送数据 
	output reg [23:0]freq,                      //频率数据
	output reg [7:0] wave                       //波形数据
    );
reg [7:0] message[0:3];                         //存储数据的地址
reg [3:0] message_count;
//reg define
reg recv_done_d0;
reg recv_done_d1;
reg recv_done_d2;
reg start_done_d0;
reg start_done_d1;
reg stop_done_d0;
reg stop_done_d1;
reg tx_ready;
//wire define
wire recv_done_flag;
wire start_done_flag;
wire stop_done_flag;
//*****************************************************
//**                    main code
//*****************************************************
//捕获recv_done上升沿，得到一个时钟周期的脉冲信号
assign recv_done_flag = (~recv_done_d1) & recv_done_d0;
assign start_done_flag = (~start_done_d1) & start_done_d0;
assign stop_done_flag = (~stop_done_d1) & stop_done_d0;                                       
//对发送使能信号recv_done延迟两个时钟周期
always @(posedge sys_clk or negedge sys_rst_n) begin         
    if (!sys_rst_n) begin
        recv_done_d0 <= 1'b0;                                  
        recv_done_d1 <= 1'b0;
		  recv_done_d2 <= 1'b0;
    end                                                      
    else begin                                               
        recv_done_d0 <= recv_done;                               
        recv_done_d1 <= recv_done_d0; 
        recv_done_d2	<= recv_done_flag;	  
    end
end
//对发送使能信号recv_done延迟两个时钟周期
always @(posedge sys_clk or negedge sys_rst_n) begin         
    if (!sys_rst_n) begin
        start_done_d0 <= 1'b0;                                  
        start_done_d1 <= 1'b0;
    end                                                      
    else begin                                               
        start_done_d0 <= start_status;                               
        start_done_d1 <= start_done_d0;                            
    end
end
//对停止处理信号stop_status延迟两个时钟周期
always @(posedge sys_clk or negedge sys_rst_n) begin         
    if (!sys_rst_n) begin
        stop_done_d0 <= 1'b0;                                  
        stop_done_d1 <= 1'b0;
    end                                                      
    else begin                                               
        stop_done_d0 <= stop_status;                               
        stop_done_d1 <= stop_done_d0;                            
    end
end
//状态的切换
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)begin
	     freq <= 24'd500_000;
		  wave <= 8'd0;
		  message_count <= 1'b0;
	 end
    else if(start_done_flag && message_count == 4'd0)
		  message_count <= 1'b1;	 
	 else if(stop_done_flag && message_count == 4'd5)begin
	     message_count <= 1'b0;
		  freq[23:16] <= message[0];
		  freq[15:8]  <= message[1];
		  freq[7:0]   <= message[2];
		  wave        <= message[3];       
	 end
	 else if(recv_done_flag && message_count)begin
	     message[message_count-1'b1] <= recv_data;
		  message_count <= message_count + 1'b1;
	 end 

end
//判断接收完成信号，并在串口发送模块空闲时给出发送使能信号
always @(posedge sys_clk or negedge sys_rst_n) begin         
    if (!sys_rst_n) begin
        tx_ready  <= 1'b0; 
        send_en   <= 1'b0;
        send_data <= 8'd0;
    end                                                      
    else begin         
        if(recv_done_d2)begin            //检测串口接收到数据
            tx_ready  <= 1'b1;                  //准备启动发送过程
            send_en   <= 1'b0;
				case (message_count)
				  4'd2 : send_data <= freq[23:16];
				  4'd3 : send_data <= freq[15:8];
				  4'd4 : send_data <= freq[7:0];
				  default : send_data <= recv_data;             //寄存串口接收的数据
            endcase
        end
        else if(tx_ready && (~tx_busy)) begin   //检测串口发送模块空闲
            tx_ready <= 1'b0;                   //准备过程结束
            send_en  <= 1'b1;                   //拉高发送使能信号
        end
    end
end

endmodule 
