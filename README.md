
# Computer Organization - Spring 2024 - IUST
==============================================================
## Assembly Assignment 2

### Project Contributors

- Student Name : Yazdan Seyed Babaei
- Team Members: Yazdan Seyed babaei - Amirmohhammad jamshidi
- Student ID: 400412328
- Date: 13/04/1403

# LUMOS RISC-V Processor with Fixed-Point Unit

## Project Overview

This project aims to study the multi-cycle implementation of a RISC-V processor, specifically adding a fixed-point arithmetic unit. The processor is designed to execute RISC-V assembly code to calculate the distance between points on a map.

### Key Components:
- **LUMOS RISC-V Core:** Multi-cycle implementation of a subset of the 32-bit base integer ISA of RISC-V.
- **Fixed-Point Unit (FPU):** Adds support for fixed-point arithmetic operations including addition, subtraction, multiplication, and square root.

## Repository Structure

- `LUMOS.v`: Top module where the datapath and controller are located.
- `Fixed_Point_Unit.v`: Module implementing the fixed-point arithmetic operations.
- `Fixed_Point_Unit_Testbench.v`: Testing environment for the FPU.
- `Firmware/Assembly.S`: Assembly code for calculating distances.

## Fixed-Point Unit Description

### FPU Operations
- **Addition and Subtraction:** Directly performed on the operands.
- **Multiplication:** Implemented using a 16-bit multiplier to handle 32-bit operands in multiple stages.
- **Square Root:** Utilizes a digit-by-digit approach to calculate the square root of fixed-point numbers.

### Code Explanation

#### Fixed_Point_Unit Module
```verilog
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

// Operation handling
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

// Reset handling
always @(posedge reset)
begin
    if (reset)  ready = 0;
    else        ready = 'bz;
end

// Square Root Circuit
// ...
```
#### Multiplication Circuit
```verilog
reg [64 - 1 : 0] product;
reg product_ready;

reg [15 : 0] multiplierCircuitInput1;
reg [15 : 0] multiplierCircuitInput2;
wire [31 : 0] multiplierCircuitResult;

Multiplier multiplier_circuit
(
    .operand_1(multiplierCircuitInput1),
    .operand_2(multiplierCircuitInput2),
    .product(multiplierCircuitResult)
);

// Partial Products
reg [31 : 0] partialProduct1;
reg [31 : 0] partialProduct2;
reg [31 : 0] partialProduct3;
reg [31 : 0] partialProduct4;

reg [2 : 0] multiplication_stage;
reg [2 : 0] next_multiplication_stage;

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
```

### Multiplier Module
```verilog
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
```

