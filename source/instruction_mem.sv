module instruction_mem(
    input logic [31:0] read_address,
    output logic [31:0] instr
);

    logic [31:0] mem [0:255]; //1 KB memory, 256 words 32 bits
    assign instr = mem[read_address[9:2]];
endmodule