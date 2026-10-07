module pc{
    input logic clk, n_rst, 
    input logic jalr, jal, branch_taken, //branch has to be taken
    input logic [31:0] rs1_data, immediate,
    output logic [31:0] pc

};
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
        pc_next= pc +32'd4;//default case just move up by 4

        if(jalr) begin
            pc_next={jalr_address[31:1],1'b0}; //LSB of calc target set to 0
        end else if (jal || branch_taken) begin
            pc_next= pc + immediate;
        end

    end
        
endmodule