module uart_loopback_top(
    input           sys_clk,                //外部50M时钟
    input           sys_rst_n,              //外部复位信号，低有效
    input           uart_rxd,               //UART接收端口
    input   wire    [3:0]   key         ,
    //output  wire [7:0] uart_recv_data
    output  wire            dac_clk     ,   //输入DAC模块时钟
    output  wire            dac_clk_    ,   //高频adc输出时钟
    output  wire    [7:0]   dac_data1,
    output  wire    [7:0]   dac_data2
    );

//parameter define
parameter  CLK_FREQ = 50000000;             //定义系统时钟频率
parameter  UART_BPS = 115200;               //定义串口波特率    
//wire define   
wire        uart_recv_done;                 //UART接收完成
wire        uart_start_status;
wire        uart_stop_status;
wire [7:0]  dac_data;
wire [7:0]  uart_recv_data;
wire [15:0] out;
wire [4:0]  phase_ctrl;
wire        key_flag;

//dac_clka:DAC模块时钟
assign      dac_clk  = ~sys_clk;
assign      dac_clk_ = ~sys_clk;

//*****************************************************
//**                    main code
//*****************************************************
//串口接收模块     
uart_recv #(                          
    .CLK_FREQ       (CLK_FREQ)          ,       //设置系统时钟频率
    .UART_BPS       (UART_BPS)                  //设置串口接收波特率
)         
u_uart_recv(                 
    .sys_clk        (sys_clk), 
    .sys_rst_n      (sys_rst_n),
	.start_status   (uart_start_status) ,       //定义启动状态
	.stop_status    (uart_stop_status)  ,       //定义停止状态       
    .uart_rxd       (uart_rxd)          ,
    .uart_done      (uart_recv_done)    ,
    .uart_data      (uart_recv_data)
    );

concat concat_inst(
    .sys_clk  (sys_clk  )               ,
    .sys_rst_n(sys_rst_n)               ,
    .sig      (uart_recv_data)          ,
    .flag     (uart_recv_done)          ,
    .out      (out      )    
);

dds dds_inst1(
    .sys_clk    (sys_clk)               ,
    .sys_rst_n  (sys_rst_n)             ,
    .sel        (out[7])                ,
    .freq       (out[6:0])              ,
    .phase_ctrl (phase_ctrl)            ,
    .key_flag   (key_flag)              ,
    .dac_data   (dac_data1)
);

dds dds_inst2(
    .sys_clk    (sys_clk)               ,
    .sys_rst_n  (sys_rst_n)             ,
    .sel        (out[15])               ,
    .freq       (out[14:8])             ,
    .phase_ctrl (5'd0)                  ,
    .key_flag   (1'd0)                  ,
    .dac_data   (dac_data2)   
);

key_ctrl key_ctrl_inst
(
    .sys_clk        (sys_clk    )       ,       //系统时钟,50MHz
    .sys_rst_n      (sys_rst_n  )       ,       //复位信号,低电平有效
    .key            (key        )       ,       //输入4位按键
    .wave_sel       (phase_ctrl)        ,       //输出波形选择
    .key_flag       (key_flag)
);

endmodule
