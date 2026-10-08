        `timescale 1ns / 10ps
        /* verilator coverage_off */

        module tb_program_counter ();

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
            logic [1:0] pc_sel;
            logic [31:0] rs1_data, immediate;
            logic [31:0] pc;

            localparam logic [1:0] PC_DEFAULT = 2'b00;
            localparam logic [1:0] PC_JALR    = 2'b01;
            localparam logic [1:0] PC_TARGET  = 2'b10;

            logic [1:0]  random_sel;
            logic [31:0] random_rs1;
            logic [31:0] random_immediate;
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
            
            
            program_counter DUT (
                .clk(clk),
                .n_rst(n_rst),
                .pc_sel(pc_sel),
                .rs1_data(rs1_data),
                .immediate(immediate),
                .pc(pc)
            );

            function automatic logic [31:0] expected_next_pc(
                input logic [31:0] old_pc,
                input logic [1:0] select,
                input logic [31:0] rs1,
                input logic [31:0] imm
            );
                case(select)
                    PC_JALR: expected_next_pc=(rs1+imm) & 32'hFFFF_FFFE; //sets last bit to 0
                    PC_TARGET: expected_next_pc= old_pc+imm;
                    default: expected_next_pc = old_pc +32'd4;
                endcase
            endfunction
            //test and check task
            task automatic run_test(
                input logic [1:0] test_select,
                input logic [31:0] test_rs1,
                input logic [31:0] test_imm,
                input string test_name
            );
                logic [31:0] expected;
                begin
                    @(negedge clk);
                    pc_sel=test_select;
                    rs1_data=test_rs1;
                    immediate=test_imm;
                    expected= expected_next_pc(pc,test_select,test_rs1,test_imm);

                    @(posedge clk); //DUT updates pc
                    #1ns;
                    if(pc!=expected) begin
                        $display("Failed %s, expected %h, got %h",testname, expected,pc);
                    end else begin
                        $display("Passed %s, expected %h, got %h", testname, expected, pc);
                    end
                end

            endtask

            //CRT
            class pc_transaction;
                rand bit [1:0] select;
                rand bit [31:0] rs1;
                rand int signed offset; //immediate value
                constraint valid_select{
                    select inside{
                        PC_DEFAULT, PC_JALR,PC_TARGET
                    };
                }
                constraint offset_range{
                    offset>=-256;
                    offset<=256;
                }
                constraint target_align{
                    if(select==PC_TARGET) begin
                        offset %2 ==0;
                    end
                }
                constraint selection_distribution {//weight
                    select dist {
                        PC_DEFAULT := 1,
                        PC_JALR    := 1,
                        PC_TARGET  := 1
                    };
                }
            endclass

            pc_transaction transaction;
            initial begin
                // Initialize stimulus lines
                n_rst = 1'b1;
                pc_sel=PC_DEFAULT;
                rs1_data=32'd0;
                immediate=32'd0;

                // Apply reset sequence
                reset_dut();

               
                $finish;
            end

        endmodule

        /* verilator coverage_on */