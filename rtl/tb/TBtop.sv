typedef struct packed {
    int A;
    int B;
    int C;
    int D;
    int Q;
} pack;

program TBtop #(
    parameter DATA_WIDTH = 32;
)
();

pack que [&];
mailbox mbx_out;
mbx = new();

pack temp_pack;
pack temp_pack_2;

logic clk;
initial begin
    clk <=1'b0;
    forever begin
        clk <= ~clk;
    end
end

logic reset;
logic valid_in;
logic [DATA_WIDTH-1:0] A_i;
logic [DATA_WIDTH-1:0] B_i;
logic [DATA_WIDTH-1:0] C_i;
logic [DATA_WIDTH-1:0] D_i;
logic [DATA_WIDTH*2-1:0] Q_o;
logic valid_out;

QAccel dut (
    .clk(clk)
    , .reset(rst)
    , .valid_in(1'b1)
    , .a(A_i)
    , .b(B_i)
    , .c(C_i)
    , .d(D_i)
    , .q_out(Q_o)
    , .valid_out(valid_out);
);

task  run_SIM(String in_file_path,String out_file_path );
fin = $fopen();
fout = $fopen();
reset <=1'b1
while (!$feof(file_handle)) begin
      status = $fscanf(file_handle, "%d %d %d %d %d",
                       temp_pack.A, temp_pack.B, temp_pack.C, temp_pack.D, temp_pack.Q);
        data_queue.push_back(temp_pack);
    end

endtask 

task  monitor (int out_file);
forever begin
    wait(valid_out);
      = mbx.get(temp_pack_2);
    $fprintf(out_file, "%d %d %d %d %d",
                       A_i, temp_pack.B, temp_pack.C, temp_pack.D, temp_pack.Q);
end
endtask


initial begin
    run_SIM("in.txt","out.txt");
    
end


endprogram 