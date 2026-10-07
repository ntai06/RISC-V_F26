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
            string current_test_name;
            

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
                logic [31:0] expected_result;
                logic expected_zero;
                string desc;
            } test_vector_t;

            
            test_vector_t test_vectors[]='{
                '{4'b0000,32'd10,32'd20,32'd30,1'b0,"Addition"},//ADD
                '{4'b0001,32'd20,32'd10,32'd10,1'b0,"Subtraction"},//SUB
                '{4'b0000,32'hFFFF_FFFF,32'd1,32'd0,1'b1,"Overflow and Zero Flag"}, //overflow + zero flag
                '{4'b0010,32'hFFFF_FFF0,32'hFFFF_F0F0,32'hFFFF_F0F0,1'b0,"AND"}, //AND
                '{4'b0011,32'hFFFF_0000,32'h0000_FFFF,32'hFFFF_FFFF,1'b0,"OR"},//or
                '{4'b0100,32'hF0F0_0F0F,32'h0FF0_F0FF,32'hFF00_FFF0,1'b0,"XOR"},//xor
                '{4'b0101,32'd0,32'hFFFF_FFFF,32'd0,1'b1 ,"SLT 0<-1 Check"},//set less than signed 0 and -1
                '{4'b0110,32'd0,32'hFFFF_FFFF,32'd1,1'b0,"SLTU 0<max check"},
                '{4'b0111,32'd1,32'd31,32'h8000_0000,1'b0,"SLL max 31 shift"},
                '{4'b0111,32'd1,32'd32,32'd1,1'b0,"SLL shift 32"},//shift 32= bottom5  bits are 0, cant see
                '{4'b1000,32'h8000_0000,32'd31,32'd1,1'b0,"SRR max 31 shift"},
                '{4'b1000,32'h4000_0000,32'd31,32'd0,1'b1,"SRR shifts out"},
                '{4'b1001, 32'h8000_0000, 32'd1,32'hC000_0000, 1'b0, "SRA negative value"},
                '{4'b1001, 32'h7FFF_FFFF, 32'd1, 32'h3FFF_FFFF, 1'b0, "SRA positive value"}
            };
            initial begin
                // Initialize stimulus lines
                foreach(test_vectors[i]) begin
                    alu_contr=test_vectors[i].alu_op;
                    a=test_vectors[i].a;
                    b=test_vectors[i].b;
                    current_test_name = test_vectors[i].desc;
                    #10;
                    $display("Test case: %s",test_vectors[i].desc);
                    if(result!==test_vectors[i].expected_result || zero !== test_vectors[i].expected_zero) begin

                        $display("Expected Result : %h, Actual result: %h",test_vectors[i].expected_result,result);
                        $display("Expected Zero: %b, Actual Zero: %b", test_vectors[i].expected_zero, zero);
                    end else begin
                        $display("Test Case: %s worked!",test_vectors[i].desc);
                    end
                end 
                
                $stop;
            end

        endmodule

        /* verilator coverage_on */