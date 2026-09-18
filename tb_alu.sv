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
            typedef struct packed{
                logic [3:0] alu_op;
                logic [31:0] a,b;
                logic [31:0] expected_result;
                logic expected_zero;
                logic [32*8-1:0]desc;
            } test_vector_t;

            localparam int NUM_TESTS=5;
            test_vector_t test_vectors[0:NUM_TESTS-1]='{
                '{4'b0000,32'd10,32'd20,32'd30,1'b0,"Addition"},//ADD
                '{4'b0001,32'd20,32'd10,32'd10,1'b0,"Subtraction"},//SUB
                '{4'b0000,32'hFFFF_FFFF,32'd1,32'd0,1'b1,"Overflow and Zero Flag"}, //overflow + zero flag
                '{4'b0010,32'hFFFF_FFF0,32'hFFFF_F0F0,32'hFFFF_F0F0,1'b0,"AND"}, //AND
                '{4'b0011,32'hFFFF_0000,32'h0000_FFFF,32'hFFFF_FFFF,1'b0,"OR"}
            };
            initial begin
                // Initialize stimulus lines
                foreach(test_vectors[i]) begin
                    alu_contr=test_vectors[i].alu_op;
                    a=test_vectors[i].a;
                    b=test_vectors[i].b;
                    #10;
                    $display("Test case: %s",test_vectors[i].desc);
                    if(result!==test_vectors[i].expected_result || zero !== test_vectors[i].expected_zero) begin

                        $display("Expected Result : %h, Actual result: %h",test_vectors[i].expected_result,result);
                        $display("Expected Zero: %b, Actual Zero: %b", test_vectors[i].expected_zero, zero);
                    end
                end 
                
                $finish;
            end

        endmodule

        /* verilator coverage_on */