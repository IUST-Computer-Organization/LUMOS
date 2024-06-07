//  LUMOS - Light Utilization with Multicycle Operational Stages
//  A RISC-V RV32I Processor Core

//  Description: LUMOS Processor Core
//  Copyright 2024 Iran University of Science and Technology. <iustCompOrg@gmail.com>

//  Permission to use, copy, modify, and/or distribute this software for any
//  purpose with or without fee is hereby granted, provided that the above
//  copyright notice and this permission notice appear in all copies.

`ifndef OPCODES
    `define LOAD        7'b00_000_11
    `define LOAD_FP     7'b00_001_11
    `define custom_0    7'b00_010_11
    `define MISC_MEM    7'b00_011_11
    `define OP_IMM      7'b00_100_11
    `define AUIPC       7'b00_101_11
    `define OP_IMM_32   7'b00_110_11

    `define STORE       7'b01_000_11
    `define STORE_FP    7'b01_001_11
    `define custom_1    7'b01_010_11
    `define AMO         7'b01_011_11
    `define OP          7'b01_100_11
    `define LUI         7'b01_101_11
    `define OP_32       7'b01_110_11

    `define MADD        7'b10_000_11
    `define MSUB        7'b10_001_11
    `define NMSUB       7'b10_010_11
    `define NMADD       7'b10_011_11
    `define OP_FP       7'b10_100_11
    `define custom_2    7'b10_110_11

    `define BRANCH      7'b11_000_11
    `define JALR        7'b11_001_11
    `define JAL         7'b11_011_11
    `define SYSTEM      7'b11_100_11
    `define custom_3    7'b11_110_11
`endif /*OPCODES*/

`ifndef INSTRUCTION_TYPES
    `define R_TYPE      0
    `define I_TYPE      1
    `define S_TYPE      2
    `define B_TYPE      3
    `define U_TYPE      4
    `define J_TYPE      5
`endif /*INSTRUCTION_TYPES*/

`ifndef I_INSTRUCTIONS
    `define ADDI        3'b000
    `define SLTI        3'b010
    `define SLTIU       3'b011
    `define XORI        3'b100
    `define ORI         3'b110
    `define ANDI        3'b111
    `define SLLI        3'b001      // Shift Left Immediate -> Logical
    `define SRI         3'b101      // Shift Right Immediate -> Logical & Arithmetic
`endif /*I_INSTRUCTIONS*/

`ifndef R_INSTRUCTIONS
    `define ADDSUB      3'b000
    `define SLL         3'b001      // Shift Left -> Logical   
    `define SLT         3'b010
    `define SLTU        3'b011    
    `define XOR         3'b100    
    `define SR          3'b101      // Shift Right -> Logical & Arithmetic   
    `define OR          3'b110    
    `define AND         3'b111
`endif /*R_INSTRUCTIONS*/

`ifndef MUL_DIV_INSTRCUTIONS
    `define MUL         3'b000
    `define MULH        3'b001
    `define MULHSU      3'b010
    `define MULHU       3'b011 

    `define DIV         3'b100
    `define DIVU        3'b101
    `define REM         3'b110
    `define REMU        3'b111

    `define MULDIV      7'b0000001
`endif /*MUL_DIV_INSTRCUTIONS*/

`ifndef FIXED_POINT_INSTRUCTIONS
    `define FADD        7'b000_0000
    `define FSUB        7'b000_0100

    `define FMUL        7'b000_1000
    `define FDIV        7'b000_1100 

    `define FSQRT       7'b010_1100
`endif /*FIXED_POINT_INSTRUCTIONS*/

`ifndef BRANCH_INSTRUCTIONS
    `define BEQ         3'b000
    `define BNE         3'b001
    `define BLT         3'b100
    `define BGE         3'b101
    `define BLTU        3'b110
    `define BGEU        3'b111
`endif /*BRANCH_INSTRUCTIONS*/

`ifndef ALU_OPERATIONS
    `define ALU_ADD     4'b0000
    `define ALU_SUB     4'b0001
    `define ALU_AND     4'b0010
    `define ALU_OR      4'b0011
    `define ALU_XOR     4'b0100
    `define ALU_SLT     4'b0101 
    `define ALU_SLTU    4'b0110
    `define ALU_SLL     4'b0111 
    `define ALU_SRL     4'b1000
    `define ALU_SRA     4'b1001
`endif /*ALU_OPERATIONS*/

`ifndef ALU_AUXILIARY_DEFINES
    `define LOGICAL     7'b000_0000
    `define ARITHMETIC  7'b010_0000
    `define ADD         7'b000_0000     
    `define SUB         7'b010_0000
`endif /*ALU_AUXILIARY_DEFINES*/

`ifndef FPU_OPERATIONS
    `define FPU_ADD     2'b00
    `define FPU_SUB     2'b01
    `define FPU_MUL     2'b10
    `define FPU_SQRT    2'b11
`endif /*FPU_OPERATIONS*/

`ifndef ALU_SRC_SELECT
    `define PC          2'b00
    `define RS1         2'b01
    `define ALU_RESULT  2'b10
    `define ZERO        2'b11

    `define RS2         2'b00
    `define FOUR        2'b01
    `define IMMEDIATE   2'b10
`endif /*ALU_SRC_SELECT*/

`ifndef REGISTER_FILE_WRITE_SOURCE
    `define MEMORY      2'b00
    `define ALU         2'b01
    `define NEXT_PC     2'b10
    `define FPU         2'b11
`endif /*REGISTER_FILE_WRITE_SOURCE*/

`ifndef CONTROL_SIGNALS
    `define INSTRUCTION     1'b0
    `define DATA            1'b1

    `define READ            1'b0
    `define WRITE           1'b1

    `define DISABLE         1'b0
    `define ENABLE          1'b1
`endif /*CONTROL_SIGNALS*/

`ifndef CONTROLLER_STATES
    `define RESET               0
    `define FETCH_BEGIN         1
    `define FETCH_WAIT          2
    `define FETCH_DONE          3
    `define DECODE              4
    `define EXECUTE             5
    `define EXECUTE_BRANCH      6
    `define TAKE_BRANCH         7
    `define EXECUTE_JUMP        8
    `define MEMORY_WRITE        9
    `define MEMORY_READ_BEGIN   10
    `define MEMORY_READ_WAIT    11
    `define MEMORY_READ_DONE    12
    `define EXECUTE_FP          13
`endif /*CONTROLLER_STATES*/

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

    reg [31 : 0] pc;
    reg [31: 0] ir;
    reg [31 : 0] memoryDataRegister;

    wire [31 : 0] readData1;
    wire [31 : 0] readData2;
    reg  [31 : 0] writeData;

    reg [31 : 0] RS1;
    reg [31 : 0] RS2;

    wire [31 : 0] fixedPointReadData1;
    wire [31 : 0] fixedPointReadData2;
    reg  [31 : 0] fixedPointWriteData;

    reg [31 : 0] FRS1;
    reg [31 : 0] FRS2;

    wire [31 : 0] immediate;

    reg  [31 : 0] aluOperand1;
    reg  [31 : 0] aluOperand2;
    wire [31 : 0] aluResult;
    wire aluZero;  
    wire aluSign;

    reg [31 : 0] aluResultRegister;
    reg aluZeroRegister;
    reg aluSignRegister;

    wire [31 : 0] fpuResult;
    reg  [31 : 0] fpuResultRegister;

    wire fpuReady;

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
    always @(posedge clk) 
    begin
        RS1 <= readData1;
        RS2 <= readData2;    
    end

    // ------------------------- //
    // Fixed Point Register File //
    // ------------------------- //   
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
    always @(posedge clk) 
    begin
        FRS1 <= fixedPointReadData1;
        FRS2 <= fixedPointReadData2;    
    end

    // ------------------- //
    // Immediate Generator //
    // ------------------- //
    Immediate_Generator immediate_generator
    (
        .instruction(ir),
        .instruction_type(instructionType),
        .immediate(immediate)
    );
    
    // --------------------- //
    // Arithmetic Logic Unit //
    // --------------------- //
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

    //always @(posedge reset or negedge fixedPointRegisterWriteEnable) fpuOperation <= 'bz;
endmodule

module Register_File
#(
    parameter WIDTH = 32,
    parameter DEPTH = 5
)
(
    input wire clk,
    input wire reset,
    
    input wire read_enable_1,
    input wire read_enable_2,
    input wire write_enable,
    
    input wire [DEPTH - 1 : 0] read_index_1,
    input wire [DEPTH - 1 : 0] read_index_2,
    input wire [DEPTH - 1 : 0] write_index,

    input wire [WIDTH - 1 : 0] write_data,

    output reg [WIDTH - 1 : 0] read_data_1,
    output reg [WIDTH - 1 : 0] read_data_2
);
	reg [WIDTH - 1 : 0] Registers [0 : 2 ** DEPTH - 1];      

    integer i;    		
    always @(posedge clk or posedge reset)
    begin
        if (reset)
        begin
            for (i = 0; i < 2 ** DEPTH; i = i + 1)
                Registers[i] <= {WIDTH{1'b0}};
        end
        else
        if (write_enable == 1'b1)
        begin
            Registers[write_index] <= write_data;
        end
    end

    always @(*) 
    begin
        if (read_enable_1 == 1'b1 && read_index_1 != {DEPTH{1'bz}})
            read_data_1 <= Registers[read_index_1];
        else
            read_data_1 <= {WIDTH{1'bz}};

        if (read_enable_2 == 1'b1 && read_index_2 != {DEPTH{1'bz}})
            read_data_2 <= Registers[read_index_2];
        else
            read_data_2 <= {WIDTH{1'bz}};
    end
endmodule

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

module Fixed_Point_Unit 
#(
    parameter WIDTH = 32,
    parameter FBITS = 10
)
(
    input wire clk,
    input wire reset,
    
    input wire [WIDTH - 1 : 0] operand_1,
    input wire [WIDTH - 1 : 0] operand_2,
    
    input wire [ 1 : 0] operation,

    output reg [WIDTH - 1 : 0] result,
    output reg ready
);

    reg [WIDTH - 1 : 0] root;
    reg root_ready;

    reg [1 : 0] square_root_stage;
    reg [1 : 0] next_square_root_stage;

    reg sqrt_start;
    reg sqrt_busy;
    
    reg [WIDTH - 1 : 0] x, x_next;              
    reg [WIDTH - 1 : 0] q, q_next;              
    reg [WIDTH + 1 : 0] ac, ac_next;            
    reg [WIDTH + 1 : 0] test_res;               

    reg valid;

    localparam ITER = (WIDTH + FBITS) >> 1;     
    reg [4 : 0] i = 0; 

    reg [64 - 1 : 0] product;
    reg product_ready;

    reg     [15 : 0] multiplierCircuitInput1;
    reg     [15 : 0] multiplierCircuitInput2;
    wire    [31 : 0] multiplierCircuitResult;

    reg     [31 : 0] partialProduct1;
    reg     [31 : 0] partialProduct2;
    reg     [31 : 0] partialProduct3;
    reg     [31 : 0] partialProduct4;

    reg [2 : 0] multiplication_stage;
    reg [2 : 0] next_multiplication_stage;
    
    always @(*)
    begin
        case (operation)
            `FPU_ADD    : begin result = operand_1 + operand_2; ready = 1; end
            `FPU_SUB    : begin result = operand_1 - operand_2; ready = 1; end
            `FPU_MUL    : begin result = product[WIDTH + FBITS - 1 : FBITS]; ready = product_ready; end
            `FPU_SQRT   : begin result = root; ready = root_ready; end
            default     : begin result = 'bz; ready = 0; end
        endcase
    end

//    always @(posedge reset)
//    begin
//        if (reset)  ready = 0;
//        else        ready = 'bz;
//    end

    // ------------------- //
    // Square Root Circuit //
    // ------------------- //
    always @(posedge clk) 
    begin
        if (operation == `FPU_SQRT) square_root_stage <= next_square_root_stage;
        else                        
        begin
            square_root_stage <= 2'b00;
            root_ready <= 0;
        end
    end 

    always @(*) 
    begin
        next_square_root_stage <= 'bz;
        case (square_root_stage)
            2'b00 : begin sqrt_start <= 0; next_square_root_stage <= 2'b01; end
            2'b01 : begin sqrt_start <= 1; next_square_root_stage <= 2'b10; end
            2'b10 : begin sqrt_start <= 0; next_square_root_stage <= 2'b10; end
        endcase    
    end                             

    always @(*)
    begin
        test_res = ac - {q, 2'b01};

        if (test_res[WIDTH + 1] == 0) 
        begin
            {ac_next, x_next} = {test_res[WIDTH - 1 : 0], x, 2'b0};
            q_next = {q[WIDTH - 2 : 0], 1'b1};
        end 
        else 
        begin
            {ac_next, x_next} = {ac[WIDTH - 1 : 0], x, 2'b0};
            q_next = q << 1;
        end
    end
    
    always @(posedge clk) 
    begin
        if (sqrt_start)
        begin
            sqrt_busy <= 1;
            root_ready <= 0;
            i <= 0;
            q <= 0;
            {ac, x} <= {{WIDTH{1'b0}}, operand_1, 2'b0};
        end

        else if (sqrt_busy)
        begin
            if (i == ITER-1) 
            begin  // we're done
                sqrt_busy <= 0;
                root_ready <= 1;
                root <= q_next;
            end

            else 
            begin  // next iteration
                i <= i + 1;
                x <= x_next;
                ac <= ac_next;
                q <= q_next;
                root_ready <= 0;
            end
        end
    end

    // ------------------ //
    // Multiplier Circuit //
    // ------------------ //   
    Multiplier multiplier_circuit
    (
        .operand_1(multiplierCircuitInput1),
        .operand_2(multiplierCircuitInput2),
        .product(multiplierCircuitResult)
    );

    always @(posedge clk) 
    begin
        if (operation == `FPU_MUL)  multiplication_stage <= next_multiplication_stage;
        else                        multiplication_stage <= 'b0;
    end

    always @(*) 
    begin
        next_multiplication_stage <= 'bz;
        case (multiplication_stage)
            3'b000 :
            begin
                product_ready <= 0;

                multiplierCircuitInput1 <= 'bz;
                multiplierCircuitInput2 <= 'bz;

                partialProduct1 <= 'bz;
                partialProduct2 <= 'bz;
                partialProduct3 <= 'bz;
                partialProduct4 <= 'bz;

                next_multiplication_stage <= 3'b001;
            end 
            3'b001 : 
            begin
                multiplierCircuitInput1 <= operand_1[15 : 0];
                multiplierCircuitInput2 <= operand_2[15 : 0];
                partialProduct1 <= multiplierCircuitResult;
                next_multiplication_stage <= 3'b010;
            end
            3'b010 : 
            begin
                multiplierCircuitInput1 <= operand_1[31 : 16];
                multiplierCircuitInput2 <= operand_2[15 : 0];
                partialProduct2 <= multiplierCircuitResult;
                next_multiplication_stage <= 3'b011;
            end
            3'b011 : 
            begin
                multiplierCircuitInput1 <= operand_1[15 : 0];
                multiplierCircuitInput2 <= operand_2[31 : 16];
                partialProduct3 <= multiplierCircuitResult;
                next_multiplication_stage <= 3'b100;
            end
            3'b100 : 
            begin
                multiplierCircuitInput1 <= operand_1[31 : 16];
                multiplierCircuitInput2 <= operand_2[31 : 16];
                partialProduct4 <= multiplierCircuitResult;
                next_multiplication_stage <= 3'b101;
            end
            3'b101 :
            begin
                product <= partialProduct1 + (partialProduct2 << 16) + (partialProduct3 << 16) + (partialProduct4 << 32);
                next_multiplication_stage <= 3'b000;
                product_ready <= 1;
            end

            default: next_multiplication_stage <= 3'b000;
        endcase    
    end
endmodule

module Multiplier
(
    input wire [15 : 0] operand_1,
    input wire [15 : 0] operand_2,

    output reg [31 : 0] product
);

    always @(*)
    begin
        product <= operand_1 * operand_2;
    end
endmodule
