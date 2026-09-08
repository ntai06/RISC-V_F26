module register_file(
    input logic clk, n_rst, reg_write,
    input logic [4:0] read_reg1, read_reg2, write_reg,
    input logic [31:0] write_data,
    output logic [31:0] read_data1, read_data2
);
    logic [31:0] rf [31:0];

    always_ff @(posedge clk, negedge n_rst) begin
        if(!n_rst) begin
            for (int i =0;i<32;i++) begin
                rf[i] <=32'b0;
            end
        end else if (reg_write && (reg_write !=0)) begin //reg 0 is hardwired to 0
            rf[write_reg] <= write_data;
        end
    end

    assign read_data1 = (read_reg1 == 0) ? 32'b0 : rf[read_reg1]; //reg 0 is hardwired to 0
    assign read_data1 = (read_reg2 == 0) ? 32'b0 : rf[read_reg2]; //reg 0 is hardwired to 0


endmodule
