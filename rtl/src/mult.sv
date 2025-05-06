// конвееризованного умножения , quartus должен сам распределять на несколько стадий
//в данном случае на две стадии  
module mult #(
    parameter int DATA_WIDTH       = 64,
    parameter int BLOCK_WIDTH = 16
) (
    input logic clk
    , input logic  reset  // Асинхронный сброс (активный высокий)
    , input logic valid_in // Разрешение приема новых данных

    , input logic signed [DATA_WIDTH-1:0] a_in
    , input logic signed [DATA_WIDTH-1:0] b_in
    , output logic [DATA_WIDTH*2-1:0] p_out
    , output logic valid_out
);


localparam N_STAGES = DATA_WIDTH / BLOCK_WIDTH;



logic signed [DATA_WIDTH-1:0] a_reg;
logic signed [DATA_WIDTH-1:0] b_reg;
logic signed [DATA_WIDTH*2-1:0] mult_out;

assign mult_out = a_reg * b_reg;

always_ff @( posedge clk ) begin : Multiplier
  if(reset) begin
    p_out <= 0;
    valid_out <= 0;
    a_reg <= 0;
    b_reg <= 0;
    // mult_out <=0;
  end
  else begin
        a_reg <= a_in;
      b_reg <= b_in;
      p_out <= mult_out;
  end

end

/*
genvar i=0;
generate
    for (i = 0;i< ; ) begin
        
    end
always_ff @( posedge clk ) begin : blockName
    
end
endgenerate
  */  
endmodule