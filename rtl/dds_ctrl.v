`timescale  1ns/1ns

module  dds_ctrl
(
    input   wire            sys_clk     ,   //系统时钟,50MHz
    input   wire            sys_rst_n   ,   //复位信号,低电平有效
    input   wire    [3:0]   wave_sel ,   //输出波形选择
    input   wire    [6:0]   freq        ,
    input   wire  [4:0]     phase_ctrl  ,
    input   wire            key_flag    ,

    output  wire    [7:0]   dac_data        //波形输出

);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter define

parameter   sin_wave    =   4'b0001     ,   //正弦波
            squ_wave    =   4'b0010     ,   //方波
            tri_wave    =   4'b0100     ,   //三角波
            saw_wave    =   4'b1000     ;   //锯齿波
      //相位累加器单次累加值

//reg   define
reg     [31:0]  fre_add     ;   //相位累加器
reg     [11:0]  rom_addr_reg;   //相位调制后的相位码
reg     [13:0]  rom_addr    ;   //ROM读地址
reg     [31:0]  FREQ_CTRL;
reg     [14:0]  phase_append;

//***************************** Main Code ****************************//
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n==1'b0)
        FREQ_CTRL = 32'd42949;
    else begin
            case(freq)
                7'd20:FREQ_CTRL   <=   32'b00011010001101101110111110000011     ;
                7'd25:FREQ_CTRL   <=   32'b00100000110001001010101000101000     ;
                7'd30:FREQ_CTRL   <=   32'b00100111010100100110010110011100     ;
                7'd35:FREQ_CTRL   <=   32'b00101101111000000010000111111111     ; 
                7'd40:FREQ_CTRL   <=   32'b00110100011011011101110011000000     ;
                7'd45:FREQ_CTRL   <=   32'b00111010111110111001100011100100     ;
                7'd50:FREQ_CTRL   <=   32'b01000001100010010101010001010000     ;
                7'd55:FREQ_CTRL   <=   32'b01001000000101110001000011010010     ;
                7'd60:FREQ_CTRL   <=   32'b01001110101001001100101100110000     ;
                7'd65:FREQ_CTRL   <=   32'b01010101001100101000100001101110     ; 
                7'd70:FREQ_CTRL   <=   32'b01011011110000000100001111111111     ; 
                7'd75:FREQ_CTRL   <=   32'b01100010010011011111111001111000     ; 
                7'd80:FREQ_CTRL   <=   32'b01101000110110111011100110000000     ; 
                7'd85:FREQ_CTRL   <=   32'b01101111011010010111111111111111     ; 
                7'd90:FREQ_CTRL   <=   32'b01110101111101110011000111001000     ;  
                7'd95:FREQ_CTRL   <=   32'b01111100100001001110110101010010     ;   
                7'd100:FREQ_CTRL  <=   32'b10000011000100101010100010000000     ;   
                
                default: FREQ_CTRL <= freq*25'd21990382;
            endcase
        end

//fre_add:相位累加器
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        fre_add <=  32'd0;
    else
        fre_add <=  fre_add + (FREQ_CTRL>>8);

//rom_addr:ROM读地址
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            phase_append    <=  14'd0;
            rom_addr        <=  14'd0;
            rom_addr_reg    <=  11'd0;
        end
    else
    case(wave_sel)
        1'b0:
            begin
                if(key_flag==1'b1)
                    phase_append    <= phase_append+phase_ctrl;
                rom_addr_reg    <=  fre_add[31:20] + phase_append;
                rom_addr        <=  rom_addr_reg;
            end     //正弦波
        1'b1:
            begin
                if(key_flag==1'b1)
                    phase_append    <= phase_append+phase_ctrl;
                rom_addr_reg    <=  fre_add[31:20] + phase_append;
                rom_addr        <=  rom_addr_reg + 14'd8192;
            end     //三角波
        saw_wave:
        begin
                rom_addr_reg    <=  fre_add[31:20] ;
                rom_addr        <=  rom_addr_reg + 14'd12288;
            end     //锯齿波
        default:
            begin
                rom_addr_reg    <=  fre_add[31:20] ;
                rom_addr        <=  rom_addr_reg;
            end     //正弦波
    endcase

//*************************** Instantiation **************************//
//------------------------- rom_wave_inst ------------------------
rom_wave    rom_wave_inst
(
    .address    (rom_addr   ),  //ROM读地址
    .clock      (sys_clk    ),  //读时钟

    .q          (dac_data   )   //读出波形数据
);

endmodule
