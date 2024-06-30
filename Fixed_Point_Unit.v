`include "Defines.vh"

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

    always @(*)
    begin
        case (operation)
            `FPU_ADD    : begin result <= operand_1 + operand_2; ready <= 1; end
            `FPU_SUB    : begin result <= operand_1 - operand_2; ready <= 1; end
            `FPU_MUL    : begin result <= product[WIDTH + FBITS - 1 : FBITS]; ready <= product_ready; end
            `FPU_SQRT   : begin result <= root; ready <= root_ready; end
            default     : begin result <= 'bz; ready <= 0; end
        endcase
    end

    always @(posedge reset)
    begin
        if (reset)  ready = 0;
        else        ready = 'bz;
    end
    // ------------------- //
    // Square Root Circuit //
    // ------------------- //
    reg [WIDTH - 1 : 0] root;
    reg root_ready;

        /*
         *  Describe Your Square Root Calculator Circuit Here.
         *
         module sqrt16 (
    input [15:0] radicand,
    output [7:0] root
);
    reg [15:0] remainder;
    reg [7:0] root_reg;
    reg [3:0] i;
    
    always @(*) begin
        remainder = 0;
        root_reg = 0;
        for (i = 4'hF; i >= 0; i = i - 1) begin
            root_reg = {root_reg[6:0], 1'b1};
            if (remainder >= (root_reg << 1)) begin
                remainder = remainder - (root_reg << 1);
                root_reg = root_reg + 1;
            end else begin
                root_reg = root_reg - 1;
            end
            root_reg = root_reg >> 1;
            remainder = (remainder << 2) | (radicand >> (i * 2) & 2'b11);
        end
    end
    
    assign root = root_reg;
endmodule
/

    // ------------------ //
    // Multiplier Circuit //
    // ------------------ //   
    reg [64 - 1 : 0] product;
    reg product_ready;

    reg     [15 : 0] multiplierCircuitInput1;
    reg     [15 : 0] multiplierCircuitInput2;
    wire    [31 : 0] multiplierCircuitResult;

    Multiplier multiplier_circuit
    (
        .operand_1(multiplierCircuitInput1),
        .operand_2(multiplierCircuitInput2),
        .product(multiplierCircuitResult)
    );

    reg     [31 : 0] partialProduct1;
    reg     [31 : 0] partialProduct2;
    reg     [31 : 0] partialProduct3;
    reg     [31 : 0] partialProduct4;

        /*
         *  Describe Your 32-bit Multiplier Circuit Here.
         */
         module Multiplier32
         (
            input wire [31:0] operand_1,
            input wire  [31:0] operand_2,
            output reg [63:0] product
          );
       wire [31:0] product0, product1, product2, product3;
       wire [31:0] operand_1_high = operand_1[31:16];
       wire [31:0] operand_1_low = operand_1[15:0];
       wire [31:0] operand_2_high = operand_2[31:16];
       wire [31:0] operand_2_low = operand_2[15:0];
    
    
    Multiplier m1 (.operand_1(operand_1_low), .operand_2(operand_2_low), .product(product0));     
    Multiplier m2 (.operand_1(operand_1_high), .operand_2(oprand2_low), .product(product1));  
    Multiplier m3 (.operand_1(operand_1_low), .operand_2(operand_2_high), .product(product2));   
    Multiplier m4 (.operand_1(operand_1_high), .operand_2(operand_2_high), .product(product3));  
    

endmodule 
         
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
