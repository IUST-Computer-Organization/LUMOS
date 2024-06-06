`timescale 1 ns / 1 ns

`include "Fixed_Point_Unit.v"

module Fixed_Point_Unit_Testbench;

    //////////////////////
    // Clock Generation //
    //////////////////////
    parameter CLK_PERIOD = 4;
    reg clk = 1'b1;
    initial begin forever #(CLK_PERIOD/2) clk = ~clk; end
    reg reset = `ENABLE;    

    /////////////////
    // FPU Signals //
    /////////////////

    reg [31 : 0] operand_1;
    reg [31 : 0] operand_2;
    reg [ 1 : 0] operation;

    wire [31 : 0] fpu_result;
    wire fpu_ready;

    Fixed_Point_Unit 
    #(
        .WIDTH(32),
        .FBITS(10)
    )
    uut
    (
        .clk(clk),
        .reset(reset),

        .operand_1(operand_1),
        .operand_2(operand_2),
        
        .operation(operation),

        .result(fpu_result),
        .ready(fpu_ready)
    );
    
    initial 
    begin
        $dumpfile("Fixed_Point_Unit.vcd");    
        $dumpvars(0, Fixed_Point_Unit_Testbench);
        repeat (3) @(posedge clk);
        reset <= `DISABLE;

        repeat (2) @(posedge clk);
        operand_1 = 32'b0000_0011_1010_0000_00;
        operand_2 = 32'b0000_0100_0001_0000_00;
        operation = `FPU_ADD;

        repeat (1) @(posedge clk);
        operand_1 = 'bz;
        operand_2 = 'bz;
        operation = 'bz;

        repeat (1) @(posedge clk);
        operand_1 = 32'b0000_0011_1010_0000_00;
        operand_2 = 32'b0000_0001_1000_0000_00;
        operation = `FPU_SUB;

        repeat (1) @(posedge clk);
        operand_1 = 'bz;
        operand_2 = 'bz;
        operation = 'bz;

        repeat (1) @(posedge clk);
        operand_1 = 32'b0000_0011_1010_0000_00;
        operand_2 = 32'b0000_0001_1000_0000_00;
        operation = `FPU_MUL;

        repeat (1) @(posedge fpu_ready);
        repeat (1) @(posedge clk);
        operand_1 = 'bz;
        operand_2 = 'bz;
        operation = 'bz;

        repeat (1) @(posedge clk);
        operand_1 = 'b11100110000000000;
        operation = `FPU_SQRT;

        repeat (1) @(posedge fpu_ready);
        repeat (3) @(posedge clk);
        operand_1 = 'bz;
        operand_2 = 'bz;
        operation = 'bz;

        repeat (10) @(posedge clk);
        $dumpoff;
        $finish;
    end
endmodule