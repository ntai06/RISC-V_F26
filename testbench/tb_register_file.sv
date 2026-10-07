        `timescale 1ns / 10ps
        /* verilator coverage_off */

        module tb_register_file ();

            localparam CLK_PERIOD = 10ns;
            localparam TIMEOUT    = 1000;

            initial begin
                $dumpfile("waveform.vcd");
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

            // DUT interface signals
            logic        reg_write;
            logic [4:0]  read_reg1, read_reg2, write_reg;
            logic [31:0] write_data;
            logic [31:0] read_data1, read_data2;

            // Active-low reset task
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
                input logic [4:0]  write_addr,
                input logic [31:0] write_datas
            );
            begin
                @(negedge clk);
                reg_write  = 1'b1;
                write_reg  = write_addr;
                write_data = write_datas;
                @(negedge clk);
                reg_write  = 1'b0;
            end
            endtask

            task read_register(
                input logic [4:0]  read_addr1,
                input logic [4:0]  read_addr2,
                input logic [31:0] exp_1,
                input logic [31:0] exp_2
            );
            begin
                @(negedge clk);
                read_reg1 = read_addr1;
                read_reg2 = read_addr2;
                #1;
                if (read_data1 !== exp_1) begin
                    $display("Expected %08h, got %08h on Port 1 (reg %0d)", exp_1, read_data1, read_addr1);
                end else begin
                    $display("Register %0d returned correct value: %08h", read_addr1, read_data1);
                end

                if (read_data2 !== exp_2) begin
                    $display("Expected %08h, got %08h on Port 2 (reg %0d)", exp_2, read_data2, read_addr2);
                end else begin
                    $display("Register %0d returned correct value: %08h", read_addr2, read_data2);
                end
            end
            endtask

            register_file DUT (
                .clk(clk),
                .n_rst(n_rst),
                .reg_write(reg_write),
                .read_reg1(read_reg1),
                .read_reg2(read_reg2),
                .write_reg(write_reg),
                .write_data(write_data),
                .read_data1(read_data1),
                .read_data2(read_data2)
            );

            initial begin
                // Initialize stimulus lines
                n_rst      = 1'b1;
                reg_write  = 1'b0;
                read_reg1  = '0;
                read_reg2  = '0;
                write_reg  = '0;
                write_data = '0;

                // Apply reset sequence
                reset_dut();

                // Verify all 32 registers retain 0 after reset release
                $display("--- Testing Post-Reset Zero State ---");
                for (int i = 0; i < 32; i = i + 2) begin
                    read_register(5'(i), 5'(i+1), 32'h0, 32'h0);
                end
                
                @(negedge clk);

                $display("--- Testing register zero after write ---");
                write_register(5'd0,32'hFFFF_FFFF);
                read_register(5'd0,5'd0,32'h0,32'h0);

                @(negedge clk);
                $display("--- Testing Indepedent Port ---");
                write_register(5'd1,32'hABCD_DBCA);
                write_register(5'd2,32'hEFDC_BCBC);

                read_register(5'd1,5'd2,32'hABCD_DBCA,32'hEFDC_BCBC);
                read_register(5'd2,5'd1,32'hEFDC_BCBC,32'hABCD_DBCA);

                #(CLK_PERIOD * 2);

                
                $finish;
            end

        endmodule

        /* verilator coverage_on */