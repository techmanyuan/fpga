module  dds
(
    input   wire            sys_clk     ,
    input   wire            sys_rst_n   ,
    input   wire            sel         ,
    input   wire  [6:0]     freq        ,
    input   wire  [4:0]     phase_ctrl  ,
    input   wire            key_flag    ,

    output  wire    [7:0]   dac_data
);



dds_ctrl    dds_ctrl_inst
(
    .sys_clk     (sys_clk),
    .sys_rst_n   (sys_rst_n),
    .wave_sel    (sel),
    .freq        (freq),
    .phase_ctrl  (phase_ctrl),
    .key_flag    (key_flag),

    .dac_data    (dac_data)
);

endmodule
