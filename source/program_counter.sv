module program_counter(
    input logic clk, n_rst, 
    input logic [1:0] pc_sel, //pc selector
    input logic [31:0] rs1_data, immediate,
    output logic [31:0] pc

);
    localparam logic [1:0] PC_DEFAULT = 2'b00;
    localparam logic [1:0] PC_JALR = 2'b01;
    localparam logic [1:0] PC_TARGET = 2'b10;


    logic [31:0] pc_next;
    logic [31:0] jalr_address;

    assign jalr_address = rs1_data + immediate;
    always_ff @(posedge clk, negedge n_rst) begin
        if(!n_rst) begin
            pc<=32'd0;
        end else begin
            pc<=pc_next;
        end
    end
    always_comb begin
        case(pc_sel)
            PC_JALR: begin
                pc_next={jalr_address[31:1],1'b0}; //LSB of calc target set to 0
            end
            PC_TARGET: begin
                pc_next= pc + immediate;
            end
            default: pc_next=pc+32'd4;
        endcase
        
    end
        
endmodule