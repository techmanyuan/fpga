module  key_ctrl
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    input   wire    [3:0]   key         ,

    output  reg     [4:0]   wave_sel    ,
    output  wire            key_flag
);

wire    key3;
wire    key2;
wire    key1;
wire    key0;

assign key_flag = key0|key1|key2|key3;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        wave_sel    <=  4'b0000;
    else    if(key3 == 1'b1)
        wave_sel    <=  4'd45;
    else    if(key2 == 1'b1)
        wave_sel    <=  4'd23;
    else    if(key1 == 1'b1)
        wave_sel    <=  4'd11;
    else    if(key0 == 1'b1)
        wave_sel    <=  4'd1;

key_filter
#(
    .CNT_MAX    (20'd999_999)
)
key_filter_inst3
(
    .sys_clk     (sys_clk),
    .sys_rst_n   (sys_rst_n),
    .key_in      (key[3]),

    .key_flag    (key3)
);

key_filter
#(
    .CNT_MAX    (20'd999_999)
)
key_filter_inst2
(
    .sys_clk     (sys_clk),
    .sys_rst_n   (sys_rst_n),
    .key_in      (key[2]),

    .key_flag    (key2)
);

key_filter
#(
    .CNT_MAX    (20'd999_999)
)
key_filter_inst1
(
    .sys_clk     (sys_clk),
    .sys_rst_n   (sys_rst_n),
    .key_in      (key[1]),

    .key_flag    (key1)
);

key_filter
#(
    .CNT_MAX    (20'd999_999)
)
key_filter_inst0
(
    .sys_clk     (sys_clk),
    .sys_rst_n   (sys_rst_n),
    .key_in      (key[0]),

    .key_flag    (key0)
);

endmodule
