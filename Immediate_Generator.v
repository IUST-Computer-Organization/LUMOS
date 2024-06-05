//  LUMOS - Light Utilization with Multicycle Operational Stages
//  A RISC-V RV32I Processor Core

//  Description: LUMOS Core Immediate Generator Unit Module
//  Copyright 2024 Iran University of Science and Technology. <iustCompOrg@gmail.com>

//  Permission to use, copy, modify, and/or distribute this software for any
//  purpose with or without fee is hereby granted, provided that the above
//  copyright notice and this permission notice appear in all copies.

`include "Defines.vh"

module Immediate_Generator 
(
	input   wire    [31 : 0] instruction,
	input   wire    [ 2 : 0] instruction_type,

	output  reg     [31 : 0] immediate
);
    always @(*)
    begin
        case (instruction_type)
            `I_TYPE : immediate = { {21{instruction[31]}}, instruction[30 : 20] };
            `S_TYPE : immediate = { {21{instruction[31]}}, instruction[30 : 25], instruction[11 : 7] };
            `B_TYPE : immediate = { {20{instruction[31]}}, instruction[7], instruction[30 : 25], instruction[11 : 8], 1'b0 };
            `U_TYPE : immediate = { instruction[31 : 12], {12{1'b0}} };
            `J_TYPE : immediate = { {12{instruction[31]}}, instruction[19 : 12], instruction[20], instruction[30 : 21], 1'b0 };
            default : immediate = { 32{1'bz} };
        endcase
    end
endmodule