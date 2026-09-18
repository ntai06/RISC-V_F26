        `timescale 1ns / 10ps
        /* verilator coverage_off */

        module tb_alu ();

            initial begin
                $dumpfile("waveform.vcd");
                $dumpvars;
            end

            
            // DUT interface signals
            logic [31:0] a, b, result;
            logic [3:0] alu_contr;
            logic zero;

            

            alu DUT (
                .a(a),
                .b(b),
                .alu_contr(alu_contr),
                .result(result),
                .zero(zero)
            );
            typedef struct {
                logic [3:0] alu_op;
                logic [31:0] a,b;
                logic [31:0] expected_result
                logic expected_zero;
            } test_vector_t;

            test_vector_t test_vectors[]='{
                '{4'b0000,32'd10,32'd20,32'd30,1'b0},//ADD
                '{4'b0001,32'd20,32'd10,32'd10,1'b0},//SUB
                '{4'b0001,32'd20,32'd20,32'd0,1'b1},//zero flag
                
            };
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