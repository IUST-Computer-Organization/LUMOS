//  LUMOS - Light Utilization with Multicycle Operational Stages
//  A RISC-V RV32I Processor Core

//  Description: LUMOS Core Arithmetic Logic Unit Module
//  Copyright 2024 Iran University of Science and Technology. <iustCompOrg@gmail.com>

//  Permission to use, copy, modify, and/or distribute this software for any
//  purpose with or without fee is hereby granted, provided that the above
//  copyright notice and this permission notice appear in all copies.

`include "Defines.vh"

module Arithmetic_Logic_Unit
(
    input wire [ 3 : 0] operation,

    input wire [31 : 0] operand_1,
    input wire [31 : 0] operand_2,

    output reg [31 : 0] result,
    output reg zero,
    output reg sign
);

    always @(*)
    begin
        case (operation)
            `ALU_ADD    : result = operand_1 + operand_2;
            `ALU_SUB    : result = operand_1 - operand_2;         
            `ALU_AND    : result = operand_1 & operand_2;         
            `ALU_OR     : result = operand_1 | operand_2;         
            `ALU_XOR    : result = operand_1 ^ operand_2;             

            `ALU_SLT    : result = $signed(operand_1) < $signed(operand_2) ? 1 : 0; 
            `ALU_SLTU   : result = operand_1 < operand_2 ? 1 : 0;

            `ALU_SLL    : result = operand_1 << operand_2[4 : 0];
            `ALU_SRL    : result = operand_1 >> operand_2[4 : 0];
            `ALU_SRA    : result = operand_1 >>> operand_2[4 : 0];
            default     : result = 'bz; 
        endcase
    end

    always @(*) 
    begin
        sign <= result[31];
        if (result == 0)
            zero <= 1;
        else 
            zero <= 0;
    end
endmodule