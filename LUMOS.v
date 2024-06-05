//  LUMOS - Light Utilization with Multicycle Operational Stages
//  A RISC-V RV32I Processor Core

//  Description: LUMOS Core Top-level Module
//  Copyright 2024 Iran University of Science and Technology. <iustCompOrg@gmail.com>

//  Permission to use, copy, modify, and/or distribute this software for any
//  purpose with or without fee is hereby granted, provided that the above
//  copyright notice and this permission notice appear in all copies.

`include "Defines.vh"
`include "Register_File.v"
`include "Arithmetic_Logic_Unit.v"
`include "Immediate_Generator.v"
`include "Fixed_Point_Unit.v"

module LUMOS
#(
    parameter RESET_ADDRESS = 32'h0000_0000
)
(
    input clk,
    input reset,
    output reg trap,

    inout   [31 : 0] memoryData,
    input   memoryReady,
    output  reg memoryEnable,
    output  reg memoryReadWrite,
    output  reg [31 : 0] memoryAddress
);

    ////////////////
    // Controller //
    ////////////////

    reg [4 : 0] state;
    reg [4 : 0] nextState;

    reg [6 : 0] opcode;
    reg [2 : 0] funct3;
    reg [6 : 0] funct7;

    always @(*) 
    begin
        opcode = ir[ 6 :  0];
        funct3 = ir[14 : 12];
        funct7 = ir[31 : 25];    
    end

    reg pcWrite;
    reg irWrite;
    reg memoryDataRegisterWrite;

    reg instructionOrData;
    
    reg [1 : 0] registerWriteSource;
    reg [1 : 0] fixedPointRegisterWriteSource;

    reg registerWriteEnable;
    reg fixedPointRegisterWriteEnable;

    reg [2 : 0] instructionType;

    reg [1 : 0] aluSrcA;
    reg [1 : 0] aluSrcB;
    reg [3 : 0] aluOperation;

    reg [1 : 0] fpuOperation;
    
    always @(posedge clk or posedge reset)
    begin
        if(reset)
            state <= `RESET;
        else
            state <= nextState;
    end

    always @(*) 
    begin
        nextState <= 'bz;

        memoryReadWrite <= 'bz;
        pcWrite <= 'bz;
        irWrite <= 'bz;

        aluOperation <= 'bz;
        aluSrcA <= 'bz;
        aluSrcB <= 'bz;
        
        registerWriteSource <= 'bz;
        registerWriteEnable <= 'bz;

        fixedPointRegisterWriteSource <= 'bz;
        fixedPointRegisterWriteEnable <= 'bz;
        
        instructionOrData <= 'bz;

        case (state)
            `RESET :   
            begin
                nextState <= `FETCH_BEGIN;
                memoryEnable <= `DISABLE;
            end
            
            `FETCH_BEGIN :   
            begin
                memoryEnable <= `ENABLE;
                memoryReadWrite <= `READ;
                instructionOrData <= `INSTRUCTION;
                nextState <= `FETCH_WAIT;
            end

            `FETCH_WAIT :
            begin
                memoryEnable <= `ENABLE;
                memoryReadWrite <= `READ;
                instructionOrData <= `INSTRUCTION;

                if (memoryReady)
                begin
                    irWrite <= `ENABLE;
                    nextState <= `FETCH_DONE;
                end
                else
                    nextState <= `FETCH_WAIT;
            end

            `FETCH_DONE :
            begin
                memoryEnable <= `DISABLE;
                aluSrcA <= `PC;
                aluSrcB <= `FOUR;
                aluOperation <= `ALU_ADD;
                pcWrite <= `ENABLE;
                nextState <= `DECODE;
            end
            
            `DECODE :
            begin
                if (opcode == `SYSTEM)
                    trap <= `ENABLE;
                // else 
                //     trap <= `DISABLE;

                case (opcode)
                    `OP         : instructionType <= `R_TYPE;
                    `OP_FP      : instructionType <= `R_TYPE;

                    `LOAD       : instructionType <= `I_TYPE;
                    `LOAD_FP    : instructionType <= `I_TYPE;
                    `OP_IMM     : instructionType <= `I_TYPE;
                    `OP_IMM_32  : instructionType <= `I_TYPE;
                    `JALR       : instructionType <= `I_TYPE;
                    `SYSTEM     : instructionType <= `I_TYPE; 

                    `STORE      : instructionType <= `S_TYPE;
                    `STORE_FP   : instructionType <= `S_TYPE;

                    `BRANCH     : instructionType <= `B_TYPE;

                    `AUIPC      : instructionType <= `U_TYPE;
                    `LUI        : instructionType <= `U_TYPE;

                    `JAL        : instructionType <= `J_TYPE;
                    default     : instructionType <= 3'bz;
                endcase
                nextState <= `EXECUTE;
            end

            `EXECUTE :
            begin
                case (opcode)
                    `OP : 
                    begin 
                        aluSrcA <= `RS1;  
                        aluSrcB <= `RS2;        
                        case ({funct7, funct3})
                            {`ADD, `ADDSUB} : 
                            begin 
                                aluOperation <= `ALU_ADD; 
                                registerWriteSource <= `ALU; 
                                registerWriteEnable <= `ENABLE; 
                            end 
                            
                            {`SUB, `ADDSUB} : 
                            begin 
                                aluOperation <= `ALU_SUB; 
                                registerWriteSource <= `ALU; 
                                registerWriteEnable <= `ENABLE; 
                            end

                            {7'b0, `SLL} :
                            begin
                                aluOperation <= `ALU_SLL;
                                registerWriteSource <= `ALU;
                                registerWriteEnable <= `ENABLE;
                            end

                            {7'b0, `SLT} :
                            begin
                                aluOperation <= `ALU_SLT;
                                registerWriteSource <= `ALU;
                                registerWriteEnable <= `ENABLE;
                            end

                            {7'b0, `SLTU} :
                            begin
                                aluOperation <= `ALU_SLTU;
                                registerWriteSource <= `ALU;
                                registerWriteEnable <= `ENABLE;
                            end

                            {7'b0, `XOR} :
                            begin
                                aluOperation <= `ALU_XOR; 
                                registerWriteSource <= `ALU; 
                                registerWriteEnable <= `ENABLE; 
                            end
                            
                            {`LOGICAL, `SR} :
                            begin
                                aluOperation <= `ALU_SRL;
                                registerWriteSource <= `ALU;
                                registerWriteEnable <= `ENABLE;
                            end

                            {`ARITHMETIC, `SR} :
                            begin
                                aluOperation <= `ALU_SRA;
                                registerWriteSource <= `ALU;
                                registerWriteEnable <= `ENABLE;
                            end

                            {7'b0, `OR} :
                            begin
                                aluOperation <= `ALU_OR; 
                                registerWriteSource <= `ALU; 
                                registerWriteEnable <= `ENABLE; 
                            end

                            {7'b0, `AND} :
                            begin
                                aluOperation <= `ALU_AND; 
                                registerWriteSource <= `ALU; 
                                registerWriteEnable <= `ENABLE; 
                            end
                        endcase  
                        nextState <= `FETCH_BEGIN;                           
                    end
                    
                    `OP_IMM : 
                    begin 
                        aluSrcA <= `RS1;  
                        aluSrcB <= `IMMEDIATE;  
                        
                        case (funct3)
                            `ADDI : 
                            begin 
                                aluOperation <= `ALU_ADD; 
                                registerWriteSource <= `ALU; 
                                registerWriteEnable <= `ENABLE; 
                            end

                            `SLTI : 
                            begin
                                aluOperation <= `ALU_SLT;
                                registerWriteSource <= `ALU;
                                registerWriteEnable <= `ENABLE;
                            end

                            `SLTIU :
                            begin
                                aluOperation <= `ALU_SLTU;
                                registerWriteSource <= `ALU;
                                registerWriteEnable <= `ENABLE;
                            end

                            `XORI :
                            begin
                                aluOperation <= `ALU_XOR;
                                registerWriteSource <= `ALU;
                                registerWriteEnable <= `ENABLE;
                            end

                            `ORI : 
                            begin
                                aluOperation <= `ALU_OR;
                                registerWriteSource <= `ALU;
                                registerWriteEnable <= `ENABLE;
                            end

                            `ANDI :
                            begin
                                aluOperation <= `ALU_AND;
                                registerWriteSource <= `ALU;
                                registerWriteEnable <= `ENABLE;
                            end

                            `SLLI :
                            begin
                                aluOperation <= `ALU_SLL;
                                registerWriteSource <= `ALU;
                                registerWriteEnable <= `ENABLE;
                            end

                            `SRI :
                            begin
                                case (funct7)
                                    `LOGICAL :
                                    begin
                                        aluOperation <= `ALU_SRL;
                                        registerWriteSource <= `ALU;
                                        registerWriteEnable <= `ENABLE;
                                    end 

                                    `ARITHMETIC :
                                    begin
                                        aluOperation <= `ALU_SRA;
                                        registerWriteSource <= `ALU;
                                        registerWriteEnable <= `ENABLE;
                                    end 
                                endcase
                            end
                        endcase

                        nextState <= `FETCH_BEGIN;
                    end

                    `OP_FP :
                    begin
                        case (funct7)
                            `FADD  : fpuOperation <= `FPU_ADD;
                            `FSUB  : fpuOperation <= `FPU_SUB;
                            `FMUL  : fpuOperation <= `FPU_MUL;
                            `FSQRT : fpuOperation <= `FPU_SQRT;
                        endcase

                        nextState <= `EXECUTE_FP;
                    end

                    `BRANCH : 
                    begin 
                        aluSrcA <= `RS1;  
                        aluSrcB <= `RS2; 
                        
                        case ({funct3})
                            `BNE : 
                            begin
                                aluOperation <= `ALU_SUB;
                            end

                            `BEQ : 
                            begin
                                aluOperation <= `ALU_SUB;
                            end

                            `BLT : 
                            begin
                                aluOperation <= `ALU_SUB;
                            end 
                        endcase
                        nextState <= `EXECUTE_BRANCH; 
                    end

                    `AUIPC :
                    begin
                        aluSrcA <= `PC;
                        aluSrcB <= `IMMEDIATE;
                        aluOperation <= `ALU_ADD;
                        registerWriteSource <= `ALU; 
                        registerWriteEnable <= `ENABLE; 
                        nextState <= `FETCH_BEGIN;
                    end

                    `JAL :
                    begin
                        registerWriteSource <= `NEXT_PC; 
                        registerWriteEnable <= `ENABLE; 

                        nextState <= `EXECUTE_JUMP;
                    end

                    `JALR :
                    begin

                        registerWriteSource <= `NEXT_PC; 
                        registerWriteEnable <= `ENABLE; 

                        nextState <= `EXECUTE_JUMP;
                    end

                    `LUI : 
                    begin
                        aluSrcA <= `ZERO;
                        aluSrcB <= `IMMEDIATE;
                        aluOperation <= `ALU_ADD;
                        registerWriteSource <= `ALU; 
                        registerWriteEnable <= `ENABLE; 
                        nextState <= `FETCH_BEGIN;
                    end

                    `LOAD :
                    begin
                        aluSrcA <= `RS1;
                        aluSrcB <= `IMMEDIATE;
                        aluOperation <= `ALU_ADD;
                        nextState <= `MEMORY_READ_BEGIN;
                    end

                    `LOAD_FP :
                    begin
                        aluSrcA <= `RS1;
                        aluSrcB <= `IMMEDIATE;
                        aluOperation <= `ALU_ADD;
                        nextState <= `MEMORY_READ_BEGIN;
                    end

                    `STORE :
                    begin
                        aluSrcA <= `RS1;
                        aluSrcB <= `IMMEDIATE;
                        aluOperation <= `ALU_ADD;

                        memoryReadWrite <= `WRITE;
                        memoryDataRegisterWrite <= `ENABLE;

                        nextState <= `MEMORY_WRITE;
                    end

                    `STORE_FP :
                    begin
                        aluSrcA <= `RS1;
                        aluSrcB <= `IMMEDIATE;
                        aluOperation <= `ALU_ADD;

                        memoryReadWrite <= `WRITE;
                        memoryDataRegisterWrite <= `ENABLE;

                        nextState <= `MEMORY_WRITE;
                    end
                endcase
            end

            `EXECUTE_FP :
            begin
                if (!fpuReady)
                    nextState <= `EXECUTE_FP;
                else
                begin
                    fixedPointRegisterWriteSource <= `FPU;
                    fixedPointRegisterWriteEnable <= `ENABLE;
                    nextState <= `FETCH_BEGIN;
                end
            end

            `MEMORY_READ_BEGIN :
            begin
                memoryEnable <= `ENABLE;
                memoryReadWrite <= `READ;
                instructionOrData <= `DATA;

                aluSrcA <= `ALU_RESULT;
                aluSrcB <= `ZERO;
                aluOperation <= `ALU_ADD;

                nextState <= `MEMORY_READ_WAIT;    
            end

            `MEMORY_READ_WAIT :
            begin
                memoryEnable <= `ENABLE;
                memoryReadWrite <= `READ;
                instructionOrData <= `DATA;

                aluSrcA <= `ALU_RESULT;
                aluSrcB <= `ZERO;
                aluOperation <= `ALU_ADD;


                if (memoryReady)
                begin
                    memoryDataRegisterWrite <= `ENABLE;
                    nextState <= `MEMORY_READ_DONE;
                end
                else
                    nextState <= `MEMORY_READ_WAIT;
            end

            `MEMORY_READ_DONE :
            begin
                if (opcode == `LOAD)
                begin
                    registerWriteSource <= `MEMORY;
                    registerWriteEnable <= `ENABLE;
                end
                else if (opcode == `LOAD_FP)
                begin
                    fixedPointRegisterWriteSource <= `MEMORY;
                    fixedPointRegisterWriteEnable <= `ENABLE;
                end
                
                memoryEnable <= `DISABLE;   
                nextState <= `FETCH_BEGIN;
            end
            
            `MEMORY_WRITE :
            begin
                memoryEnable <= `ENABLE;
                memoryReadWrite <= `WRITE;
                instructionOrData <= `DATA;

                nextState <= `FETCH_BEGIN;
            end
            
            `EXECUTE_BRANCH :
            begin
                case ({funct3})
                    `BNE : 
                    begin
                        if (!aluZeroRegister)
                        begin
                            aluSrcA <= `PC;
                            aluSrcB <= `IMMEDIATE;
                            aluOperation <= `ALU_ADD;
                            nextState <= `TAKE_BRANCH;
                        end
                        else
                            nextState <= `FETCH_BEGIN;
                    end        
                    
                    `BEQ : 
                    begin
                        if (aluZeroRegister)
                        begin
                            aluSrcA <= `PC;
                            aluSrcB <= `IMMEDIATE;
                            aluOperation <= `ALU_ADD;
                            nextState <= `TAKE_BRANCH;
                        end
                        else
                            nextState <= `FETCH_BEGIN;
                    end

                    `BLT : 
                    begin
                        if (aluSignRegister)
                        begin
                            aluSrcA <= `PC;
                            aluSrcB <= `IMMEDIATE;
                            aluOperation <= `ALU_ADD;
                            nextState <= `TAKE_BRANCH;
                        end
                        else
                            nextState <= `FETCH_BEGIN;
                    end         
                endcase
            end

            `TAKE_BRANCH :
            begin
                aluSrcA <= `ALU_RESULT;
                aluSrcB <= `FOUR;
                aluOperation <= `ALU_SUB;
                pcWrite <= `ENABLE;
                nextState <= `FETCH_BEGIN;
            end

            `EXECUTE_JUMP :
            begin
                case (opcode)
                    `JAL :
                    begin
                        aluSrcA <= `PC;
                        aluSrcB <= `IMMEDIATE;
                        aluOperation <= `ALU_ADD;
                        pcWrite <= `ENABLE;
                        nextState <= `FETCH_BEGIN;
                    end 
                    `JALR : 
                    begin

                        aluSrcA <= `RS1;
                        aluSrcB <= `IMMEDIATE;
                        aluOperation <= `ALU_ADD;
                        pcWrite <= `ENABLE;
                        nextState <= `FETCH_BEGIN;
                    end
                endcase
            end
        endcase        
    end

    //////////////
    // Datapath //
    //////////////

    // ------------------------ //
    // Program Counter Register //
    // ------------------------ //
    reg [31 : 0] pc;
    
    always @(posedge clk)
    begin
        if (reset)
            pc <= RESET_ADDRESS;
        else if (pcWrite)
            pc <= aluResult; 
    end

    // -------------------- //
    // Instruction Register //
    // -------------------- //
    reg [31: 0] ir;
    always @(posedge clk) 
    begin
        if (reset)
            ir <= 'bz;
        if (irWrite)
            ir <= memoryData;
    end

    // -------------------- //
    // Memory Data Register //
    // -------------------- //
    reg [31 : 0] memoryDataRegister;
    always @(posedge clk) 
    begin
        if (memoryDataRegisterWrite && memoryReadWrite == `READ)
            memoryDataRegister <= memoryData;    
        if (memoryDataRegisterWrite && memoryReadWrite == `WRITE && opcode == `STORE)
            memoryDataRegister <= RS2;
        if (memoryDataRegisterWrite && memoryReadWrite == `WRITE && opcode == `STORE_FP)
            memoryDataRegister <= FRS2;
    end

    assign memoryData = (memoryEnable == `ENABLE) ? 
                        (memoryReadWrite == `WRITE) ? memoryDataRegister : 'bz : 'bz;

    // ------------- //
    // Register File //
    // ------------- //
    wire [31 : 0] readData1;
    wire [31 : 0] readData2;
    reg  [31 : 0] writeData;

    always @(*) 
    begin
        case (registerWriteSource)
            `NEXT_PC    :   writeData <= pc;
            `MEMORY     :   writeData <= memoryDataRegister;
            `ALU        :   writeData <= aluResult;
            default     :   writeData <= 'bz;
        endcase    
    end

    Register_File 
    #(
        .WIDTH(32),
        .DEPTH(5)
    )
    register_file
    (
        .clk(clk),
        .reset(reset),

        .read_enable_1(1'b1),
        .read_enable_2(1'b1),
        .write_enable(registerWriteEnable && (ir[11 : 7] != 0)),

        .read_index_1(ir[19 : 15]),
        .read_index_2(ir[24 : 20]),
        .write_index(ir[11 : 7]),

        .write_data(writeData),

        .read_data_1(readData1),
        .read_data_2(readData2)
    );

    // ------------------- //
    // RS1 & RS2 Registers //
    // ------------------- //
    reg [31 : 0] RS1;
    reg [31 : 0] RS2;

    always @(posedge clk) 
    begin
        RS1 <= readData1;
        RS2 <= readData2;    
    end

    // ------------------------- //
    // Fixed Point Register File //
    // ------------------------- //
    wire [31 : 0] fixedPointReadData1;
    wire [31 : 0] fixedPointReadData2;
    reg  [31 : 0] fixedPointWriteData;
    
    always @(*) 
    begin
        case (fixedPointRegisterWriteSource)
            `MEMORY     :   fixedPointWriteData <= memoryDataRegister;
            `FPU        :   fixedPointWriteData <= fpuResult;
            default     :   fixedPointWriteData <= 'bz;
        endcase    
    end

    Register_File 
    #(
        .WIDTH(32),
        .DEPTH(5)
    )
    fixed_point_register_file
    (
        .clk(clk),
        .reset(reset),

        .read_enable_1(1'b1),
        .read_enable_2(1'b1),
        .write_enable(fixedPointRegisterWriteEnable),

        .read_index_1(ir[19 : 15]),
        .read_index_2(ir[24 : 20]),
        .write_index(ir[11 : 7]),

        .write_data(fixedPointWriteData),

        .read_data_1(fixedPointReadData1),
        .read_data_2(fixedPointReadData2)
    );

    // --------------------- //
    // FRS1 & FRS2 Registers //
    // --------------------- //
    reg [31 : 0] FRS1;
    reg [31 : 0] FRS2;

    always @(posedge clk) 
    begin
        FRS1 <= fixedPointReadData1;
        FRS2 <= fixedPointReadData2;    
    end

    // ------------------- //
    // Immediate Generator //
    // ------------------- //
    wire [31 : 0] immediate;

    Immediate_Generator immediate_generator
    (
        .instruction(ir),
        .instruction_type(instructionType),
        .immediate(immediate)
    );
    
    // --------------------- //
    // Arithmetic Logic Unit //
    // --------------------- //
    reg  [31 : 0] aluOperand1;
    reg  [31 : 0] aluOperand2;
    wire [31 : 0] aluResult;
    wire aluZero;  
    wire aluSign;

    always @(*) 
    begin
        case (aluSrcA)
            `PC         : aluOperand1 <= pc;
            `RS1        : aluOperand1 <= RS1; 
            `ALU_RESULT : aluOperand1 <= aluResultRegister;
            `ZERO       : aluOperand1 <= 0;
            default     : aluOperand1 <= 'bz;
        endcase

        case (aluSrcB)
            `RS2        : aluOperand2 <= RS2;
            `FOUR       : aluOperand2 <= 32'd4; 
            `IMMEDIATE  : aluOperand2 <= immediate;
            `ZERO       : aluOperand2 <= 0;
            default     : aluOperand2 <= 'bz;
        endcase
    end

    Arithmetic_Logic_Unit arithmetic_logic_unit
    (
        .operation(aluOperation),
        .operand_1(aluOperand1),
        .operand_2(aluOperand2),
        .result(aluResult),
        .zero(aluZero),
        .sign(aluSign)
    );

    reg [31 : 0] aluResultRegister;
    reg aluZeroRegister;
    reg aluSignRegister;

    always @(posedge clk) 
    begin
        aluResultRegister <= aluResult;    
        aluZeroRegister <= aluZero;
        aluSignRegister <= aluSign;
    end

    // ----------------------- //
    // Memory Address Register //
    // ----------------------- //   
    always @(*) 
    begin
        case (instructionOrData)
            `INSTRUCTION    : memoryAddress <= pc;
            `DATA           : memoryAddress <= aluResultRegister; 
            default         : memoryAddress <= 'bz;
        endcase
    end

    // ---------------- //
    // Fixed Point Unit //
    // ---------------- // 
    wire [31 : 0] fpuResult;
    reg  [31 : 0] fpuResultRegister;

    wire fpuReady;

    Fixed_Point_Unit
    #(
        .WIDTH(32),
        .FBITS(10)
    )
    fixed_point_unit
    (
        .clk(clk),
        .reset(reset),

        .operand_1(FRS1),
        .operand_2(FRS2),

        .operation(fpuOperation),
        
        .result(fpuResult),
        .ready(fpuReady)
    );

    always @(posedge clk) 
    begin
        fpuResultRegister <= fpuResult;    
    end

    always @(posedge reset or negedge fixedPointRegisterWriteEnable) fpuOperation <= 'bz;
endmodule