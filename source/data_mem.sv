module data_mem(
    input logic clk, mem_write, mem_read,
    input logic [31:0] data_address, write_data,
    input logic [2:0] mem_op,
    output logic [31:0] read_data
);

    logic [31:0] mem [0:255]; //1 KB memory, 256 words 32 bits
    
    assign read_data= mem_read? mem[data_address[9:2]] : 0;

    always_ff @(posedge clk) begin
        if(mem_write) begin
            mem[data_address[9:2]] <= write_data;
        end
    end





endmodule