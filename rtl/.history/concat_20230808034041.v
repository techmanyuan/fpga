module concat (
    input   wire         sys_clk,
    input   wire         sys_rst_n,
    input   wire [7:0]   sig,
    input   wire         flag ,
    
    output  reg [15:0]   out  
);

reg cnt;
reg [7:0] temp2;
reg [7:0] temp1;

always@(posedge flag or negedge sys_rst_n)
    if (sys_rst_n==1'b0)
        cnt <= 2'd0;
    else begin
            case(cnt)
                1'd0: begin 
                    temp1<=sig;
                    cnt<=1'd1;
                end
                1'd1: begin
                        temp2 <= sig;
                        if (temp1>temp2) begin
                            begin
                                out[7:0]<=temp1;
                            end
                            begin
                                out[15:8]<=temp2;
                            end
                         end 
                         else begin
                            begin
                                out[15:8]<=temp1;
                            end
                            begin
                                out[7:0]<=temp2;
                            end
                         end
                    cnt<=1'd0;
                    end
                default: ;
            endcase
        end
        

endmodule