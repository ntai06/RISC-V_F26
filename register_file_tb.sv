`timescale 1ns / 10ps
/* verilator coverage_off */

module tb_<module_name> ();

    localparam CLK_PERIOD = 10ns;
    localparam TIMEOUT    = 1000;

    initial begin
        $dumpfile("waveform.fst");
        $dumpvars;
    end

    logic clk, n_rst;

    // Clock generator
    always begin
        clk = 0;
        #(CLK_PERIOD / 2.0);
        clk = 1;
        #(CLK_PERIOD / 2.0);
    end

    // Active-low synchronous/asynchronous reset task
    task reset_dut;
    begin
        n_rst = 0;
        @(posedge clk);
        @(posedge clk);
        @(negedge clk);
        n_rst = 1;
        @(negedge clk);
        @(negedge clk);
    end
    endtask
    
    task write_register(
        input logic [4:0] write_addr,
        input logic [31:0] write_datas
    );
    begin
        @(negedge clk);
        reg_write=1'b1;
        write_reg=write_addr;
        write_data=write_datas;
        @(negedge clk);
        reg_write=1'b0;

    end
    endtask
    task read_register(
        input logic [4:0] read_addr1,
        input logic [4:0] read_addr2,
        input logic [31:0] exp_1,
        input logic [31:0] exp_2
    );
    begin
        @(negedge clk);
        
        read_reg1=read_addr1;
        read_reg2=read_addr2;
        #(1);
        if(read_data1!==exp_1) begin
            $display("Expected %h, %h",exp_1, read_data1);
        end else begin
            $display("Register1 returned correct value!");
        end
        if(read_data2!==exp_2) begin
            $display("Expected %h, %h", exp_2, read_data2);
        end else begin
            $display("Register2 returned correct value!");
        end


    end
    endtask
    // User signals declaration
    // logic ...

    // DUT Instantiation placeholder
    // <module_name> DUT (
    //     .clk(clk),
    //     .n_rst(n_rst)
    // );

    register_file DUT(
        .clk(clk),
        .n_rst(n_rst),
        .reg_write(reg_write),
        .read_reg1(read_reg1),
        .read_reg2(read_reg2),
        .write_reg(write_reg),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    )
    initial begin
        // Initialize signals
        n_rst = 1'b1;

        // Apply reset sequence
        reset_dut();

        // Stimulus and checks go here

        #(CLK_PERIOD * 2);
        $finish;
    end

endmodule

/* verilator coverage_on */