module control_unit(
    input logic [31:0] instruction,
    input logic zero,
    output logic [3:0] alu_contr,
    output logic [1:0] pc_sel,
    output logic reg_write,
    output logic alu_src
);
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic funct7; 

    assign opcode = instruction[6:0];
    assign funct3= instruction[14:12];
    assign funct7_bit5=instruction[30];//only 31st bit matters for instruction decoding
    typedef enum logic [6:0]{
        R_TYPE = 7'b0110011,
        I_TYPE_LOAD = 7'b0000011,
        I_TYPE_CALC = 7'b0010011,
        I_TYPE_JALR = 7'b1100111,
        S_TYPE = 7'b0100011,
        B_TYPE = 7'b1100011,
        U_TYPE_LUI = 7'b0110111,
        U_TYPE_AUIPC = 7'b0010111,
        J_TYPE = 7'b1101111,
        SYSTEM = 7'b1110011, //ECALL, EBREAK
        MISC_MEM = 7'b0001111 //FENCE, PAUSE

    } inst_t;

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
    } alu_t;
    always_comb begin
        alu_contr= 4'b0000;//default add
        pc_sel=2'b00;//pc default
        reg_write=0;
        alu_src=0;

        case(opcode)
            R_TYPE: begin
                reg_write=1;
                alu_src=0; //uses rs2
                pc_sel=2'b00;
                case(funct3)
                    3'b000: alu_contr = funct7_bit5 ? ALU_SUB : ALU_ADD;
                    3'b001: alu_contr=ALU_SLL
                    3'b010: alu_contr=ALU_SLT;
                    3'b011: alu_contr=ALU_SLTU;
                    3'b100: alu_contr=ALU_XOR;
                    3'b101: alu_contr=funct7_bit5 ? ALU_SRA : ALU_SRL;
                    3'b110: alu_contr=ALU_OR;
                    3'b111: alu_contr=ALU_AND;
                endcase
            end
            I_TYPE_CALC: begin
                reg_write=1;
                alu_src=1; //uses immediate
                pc_sel=2'b00;
                case(funct3)
                    3'b000: alu_contr=ALU_ADD;//addi
                    3'b010: alu_contr=ALU_SLT;//slti
                    3'b011: alu_contr=ALU_SLTU;//sltiu
                    3'b100: alu_contr=ALU_XOR;//xori
                    3'b110: alu_contr=ALU_OR;//ori
                    3'b111: alu_contr=ALU_AND;//andi
                    3'b001: alu_contr=ALU_SLL;//slli
                    3'b101: alu_contr = funct7_bit5 ? ALU_SRA : ALU_SRL; //srai, srli
                endcase
            end
            B_TYPE: begin
                reg_write=0;//branches don't write
                alu_src=0;//compares rs1 and rs2
                pc_sel=2'b00;   
                case(funct3) 
                    3'b000: begin //beq
                        alu_contr=ALU_SUB;
                        if (zero): pc_sel=2'b10;//target
                    end
                    3'b001: begin //bne
                        alu_contr=ALU_SUB;
                        if(!zero) 
                            pc_sel=2'b10; //target if not equal
                        
                    end
                    3'b100: begin
                        alu_contr=ALU_SLT;//branch if less than
                        if(!zero) 
                            pc_sel=2'b10;//if rs1<rs2 from ALU_SLT
                    end
                    3'b101: begin
                        alu_contr=ALU_SLT;//brnach if greater than or equal to
                        if(zero) pc_sel=2'b10; //if rs1<rs2 not true
                    end
                    3'b110: begin
                        alu_contr=ALU_SLTU;//brnanch if less than unsigned
                        if(!zero) pc_sel=2'b10;
                    end
                    3'b111: begin
                        alu_contr=ALU_SLTU; //branch if greater than or equal to unsigned
                        if(zero) pc_sel=2'b10;
                    end
                    


                endcase
            end
        endcase


    end
endmodule