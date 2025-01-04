//  LUMOS - Light Utilization with Multicycle Operational Stages
//  A RISC-V RV32I Processor Core

//  Description: LUMOS Core Testbench Module
//  Copyright 2024 Iran University of Science and Technology. <iustCompOrg@gmail.com>

//  Permission to use, copy, modify, and/or distribute this software for any
//  purpose with or without fee is hereby granted, provided that the above
//  copyright notice and this permission notice appear in all copies.

`timescale 1 ns / 1 ns

`include "Defines.vh"
`include "LUMOS.v"

`ifndef FIRMWARE
    `define FIRMWARE "Firmware\\Firmware.hex"
`endif /*FIRMWARE*/

`ifndef MEMORY_ACCESS_TIME
    `define MEMORY_ACCESS_TIME  #14
`endif /*FIRMWARE*/


module LUMOS_Testbench;
    
    /////////////////////////////
    // Multiplier Verification //
    /////////////////////////////
    reg  [ 7 : 0] test_operand_1;
    reg  [ 7 : 0] test_operand_2;
    wire [15 : 0] test_product;

    Multiplier multiplier_8bit
    (
        .operand_1(test_operand_1),
        .operand_2(test_operand_2),
        .product(test_product)
    );

    integer i;
    integer j;

    initial
    begin
        for (i = 0; i < 255; i = i + 1)
        begin
            for (j = 0; j < 255; j = j + 1)
            begin
                test_operand_1 = i;
                test_operand_2 = j;
                #1;
                if (test_product != i * j)
                begin
                    $display("\n\n\tMultiplier Verification Failed.\n\n");
                    $finish;
                end
            end
        end
    end

    //////////////////////
    // Clock Generation //
    //////////////////////
    parameter CLK_PERIOD = 4;
    reg clk = 1'b1;
    initial begin forever #(CLK_PERIOD/2) clk = ~clk; end
    initial #(8000 * CLK_PERIOD) $finish;
    reg reset = `ENABLE;    

    wire trap;

    //////////////////////////////
    // Memory Interface Signals //
    //////////////////////////////
    wire [31 : 0] memoryData;
    reg  [31 : 0] memoryData_reg;
    assign memoryData = memoryData_reg;

    wire [31 : 0] memoryAddress;
    wire memoryReadWrite;
    wire memoryEnable;
    reg memoryReady;

    LUMOS 
    #(
        .RESET_ADDRESS(32'h0000_0000)
    )
    uut
    (
        .clk(clk),
        .reset(reset),
        .trap(trap),

        .memoryData(memoryData),
        .memoryReady(memoryReady),
        .memoryEnable(memoryEnable),
        .memoryReadWrite(memoryReadWrite),
        .memoryAddress(memoryAddress)
    );

    // Debug Wires for Register File
    `ifndef DISABLE_DEBUG
        wire [31 : 0] x0_zero 	= uut.register_file.Registers[0];
        wire [31 : 0] x1_ra 	= uut.register_file.Registers[1];
        wire [31 : 0] x2_sp 	= uut.register_file.Registers[2];
        wire [31 : 0] x3_gp 	= uut.register_file.Registers[3];
        wire [31 : 0] x4_tp 	= uut.register_file.Registers[4];
        wire [31 : 0] x5_t0 	= uut.register_file.Registers[5];
        wire [31 : 0] x6_t1 	= uut.register_file.Registers[6];
        wire [31 : 0] x7_t2 	= uut.register_file.Registers[7];
        wire [31 : 0] x8_s0 	= uut.register_file.Registers[8];
        wire [31 : 0] x9_s1 	= uut.register_file.Registers[9];
        wire [31 : 0] x10_a0 	= uut.register_file.Registers[10];
        wire [31 : 0] x11_a1 	= uut.register_file.Registers[11];
        wire [31 : 0] x12_a2 	= uut.register_file.Registers[12];
        wire [31 : 0] x13_a3 	= uut.register_file.Registers[13];
        wire [31 : 0] x14_a4 	= uut.register_file.Registers[14];
        wire [31 : 0] x15_a5 	= uut.register_file.Registers[15];
        wire [31 : 0] x16_a6 	= uut.register_file.Registers[16];
        wire [31 : 0] x17_a7 	= uut.register_file.Registers[17];
        wire [31 : 0] x18_s2 	= uut.register_file.Registers[18];
        wire [31 : 0] x19_s3 	= uut.register_file.Registers[19];
        wire [31 : 0] x20_s4 	= uut.register_file.Registers[20];
        wire [31 : 0] x21_s5 	= uut.register_file.Registers[21];
        wire [31 : 0] x22_s6 	= uut.register_file.Registers[22];
        wire [31 : 0] x23_s7 	= uut.register_file.Registers[23];
        wire [31 : 0] x24_s8 	= uut.register_file.Registers[24];
        wire [31 : 0] x25_s9 	= uut.register_file.Registers[25];
        wire [31 : 0] x26_s10 	= uut.register_file.Registers[26];
        wire [31 : 0] x27_s11 	= uut.register_file.Registers[27];
        wire [31 : 0] x28_t3 	= uut.register_file.Registers[28];
        wire [31 : 0] x29_t4 	= uut.register_file.Registers[29];
        wire [31 : 0] x30_t5 	= uut.register_file.Registers[30];
        wire [31 : 0] x31_t6 	= uut.register_file.Registers[31];

        wire [31 : 0] f0 	= uut.fixed_point_register_file.Registers[0];
        wire [31 : 0] f1	= uut.fixed_point_register_file.Registers[1];
        wire [31 : 0] f2	= uut.fixed_point_register_file.Registers[2];
        wire [31 : 0] f3	= uut.fixed_point_register_file.Registers[3];
        wire [31 : 0] f4	= uut.fixed_point_register_file.Registers[4];
        wire [31 : 0] f5	= uut.fixed_point_register_file.Registers[5];
        wire [31 : 0] f6	= uut.fixed_point_register_file.Registers[6];
        wire [31 : 0] f7	= uut.fixed_point_register_file.Registers[7];
        wire [31 : 0] f8	= uut.fixed_point_register_file.Registers[8];
        wire [31 : 0] f9	= uut.fixed_point_register_file.Registers[9];
        wire [31 : 0] f10	= uut.fixed_point_register_file.Registers[10];
        wire [31 : 0] f11	= uut.fixed_point_register_file.Registers[11];
        wire [31 : 0] f12	= uut.fixed_point_register_file.Registers[12];
        wire [31 : 0] f13	= uut.fixed_point_register_file.Registers[13];
        wire [31 : 0] f14	= uut.fixed_point_register_file.Registers[14];
        wire [31 : 0] f15	= uut.fixed_point_register_file.Registers[15];
        wire [31 : 0] f16	= uut.fixed_point_register_file.Registers[16];
        wire [31 : 0] f17	= uut.fixed_point_register_file.Registers[17];
        wire [31 : 0] f18	= uut.fixed_point_register_file.Registers[18];
        wire [31 : 0] f19	= uut.fixed_point_register_file.Registers[19];
        wire [31 : 0] f20	= uut.fixed_point_register_file.Registers[20];
        wire [31 : 0] f21	= uut.fixed_point_register_file.Registers[21];
        wire [31 : 0] f22	= uut.fixed_point_register_file.Registers[22];
        wire [31 : 0] f23	= uut.fixed_point_register_file.Registers[23];
        wire [31 : 0] f24	= uut.fixed_point_register_file.Registers[24];
        wire [31 : 0] f25	= uut.fixed_point_register_file.Registers[25];
        wire [31 : 0] f26 	= uut.fixed_point_register_file.Registers[26];
        wire [31 : 0] f27 	= uut.fixed_point_register_file.Registers[27];
        wire [31 : 0] f28	= uut.fixed_point_register_file.Registers[28];
        wire [31 : 0] f29	= uut.fixed_point_register_file.Registers[29];
        wire [31 : 0] f30	= uut.fixed_point_register_file.Registers[30];
        wire [31 : 0] f31	= uut.fixed_point_register_file.Registers[31];
    `endif /*DISABLE_DEBUG*/
    
    initial 
    begin
        $dumpfile("LUMOS.vcd");    
        $dumpvars(0, LUMOS_Testbench);
        repeat (5) @(posedge clk);
        reset <= `DISABLE;
    end

    // Check trap at end of execution 
    always @(*) 
    begin
        if (trap == `ENABLE)
            reset <= `ENABLE;    
        repeat (100) @(posedge clk);
        
        $display("\n\n\tExecution Finished.\n\n");
        $finish;
    end

    ////////////
    // Memory //
    ////////////

    reg [31 : 0] Memory [0 : 4 * 1024 - 1];
    initial $readmemh(`FIRMWARE, Memory);

    // Memory Interface Behaviour
    always @(*)
    begin
        if (!memoryEnable)
        begin
            memoryData_reg <= 32'bz;
            memoryReady <= `DISABLE;
        end
    end

    always @(posedge clk)
    begin
        if (memoryEnable)
        begin
            if (memoryReadWrite == `WRITE)
                Memory[memoryAddress >> 2] <= memoryData;
            if (memoryReadWrite == `READ & !memoryReady)
            begin
                `MEMORY_ACCESS_TIME
                memoryData_reg <= Memory[memoryAddress >> 2];
                memoryReady <= `ENABLE;
            end
        end
    end

    always @(posedge clk) 
    begin
        if (memoryReady)
        begin
            memoryData_reg <= 32'bz;
            memoryReady <= `DISABLE;
        end    
    end
endmodule