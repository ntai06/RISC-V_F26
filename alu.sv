module alu(
    input logic [31:0] a, b, 
    input logic [3:0] alu_contr,
    output logic [31:0] result,
    output logic zero
);
    //riscv does not handle overflow
    typedef enum logic [3:0]{
        ALU_ADD= 4'b0000,
        ALU_SUB= 4'b0001,
        ALU_AND= 4'b0010,
        ALU_OR= 4'b0011,
        ALU_XOR= 4'b0100,
        ALU_SLT= 4'b0101, //set less than (signed)
        ALU_SLTU= 4'b0110, //set less than (unsigned)
        ALU_SLL= 4'b0111,//logical left shift *all shifts based on bottom 5 bits of operand 2
        ALU_SRL= 4'b1000, //logical right shift
        ALU_SRA= 4'b1001 //arithmetic right shift
    } type_name_t;
    
    always_comb begin
        case (alu_contr) 
            ALU_ADD: result = a + b;
            ALU_SUB: result = a - b;
            ALU_AND: result = a & b;
            ALU_OR: result = a | b;
            ALU_XOR: result = a ^ b;
            ALU_SLT: result = ($signed(a) < $signed(b)) ? 32'd1 : '0;
            ALU_SLTU: result = (a < b) ? 32'd1 : '0;
            ALU_SLL: result = a << b[4:0];
            ALU_SRL: result = a >> b [4:0];
            ALU_SRA: result = $signed(a) >>> b[4:0]; // signed needed bc >>> only works if operand is explicitly signed
        endcase

    end

    assign zero = result ==32'b0;


endmodule