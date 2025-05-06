module top #(parameter DATA_WIDTH = 64) (
    input clk
    , input rst
    , input signed [DATA_WIDTH-1:0] A_i, B_i, C_i, D_i
    , output signed [DATA_WIDTH*2-1:0] Q_o 
);


logic spCLk;

pll pll_inst (
    .areset(rst)
    , .inclk0(clk)
    , .c0(spCLk)
);

QAccel accel (
    .clk(spCLk)
    , .reset(rst)
    , .valid_in(1'b1)
    , .a_in(A_i)
    , .b_in(B_i)
    , .c_in(C_i)
    , .d_in(D_i)
    , .q_out(Q_o)
);

    
endmodule