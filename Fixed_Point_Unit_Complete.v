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
            `FPU_ADD    : begin result = operand_1 + operand_2; ready = 1; end
            `FPU_SUB    : begin result = operand_1 - operand_2; ready = 1; end
            `FPU_MUL    : begin result = product[WIDTH + FBITS - 1 : FBITS]; ready = product_ready; end
            `FPU_SQRT   : begin result = root; ready = root_ready; end
            default     : begin result = 'bz; ready = 0; end
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

    reg [1 : 0] square_root_stage;
    reg [1 : 0] next_square_root_stage;

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
    reg sqrt_start;
    reg sqrt_busy;
    
    reg [WIDTH - 1 : 0] x, x_next;              
    reg [WIDTH - 1 : 0] q, q_next;              
    reg [WIDTH + 1 : 0] ac, ac_next;            
    reg [WIDTH + 1 : 0] test_res;               

    reg valid;

    localparam ITER = (WIDTH + FBITS) >> 1;     
    reg [4 : 0] i = 0;                              

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
            begin  
                sqrt_busy <= 0;
                root_ready <= 1;
                root <= q_next;
            end

            else 
            begin  
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
    reg [64 - 1 : 0] product;
    reg product_ready;

    reg     [15 : 0] multiplierCircuitInput1;
    reg     [15 : 0] multiplierCircuitInput2;
    wire    [31 : 0] multiplierCircuitResult;

    Multiplier_16bit multiplier_circuit
    (
        .operand_1(multiplierCircuitInput1),
        .operand_2(multiplierCircuitInput2),
        .product(multiplierCircuitResult)
    );

    reg     [31 : 0] partialProduct1;
    reg     [31 : 0] partialProduct2;
    reg     [31 : 0] partialProduct3;
    reg     [31 : 0] partialProduct4;

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
endmodule

module Multiplier_16bit 
(
    input   wire    [15 : 0] operand_1, 
    input   wire    [15 : 0] operand_2, 
    output  wire    [31 : 0] product 
);
    wire [7 : 0] operand_1_low  = operand_1[ 7 : 0];
    wire [7 : 0] operand_1_high = operand_1[15 : 8];
    wire [7 : 0] operand_2_low  = operand_2[ 7 : 0];
    wire [7 : 0] operand_2_high = operand_2[15 : 8];
    
    wire [15 : 0] partial_product_0; 
    wire [15 : 0] partial_product_1; 
    wire [15 : 0] partial_product_2; 
    wire [15 : 0] partial_product_3; 

    Multiplier MUL_PP_0 (.operand_1(operand_1_low),     .operand_2(operand_2_low),  .product(partial_product_0));
    Multiplier MUL_PP_1 (.operand_1(operand_1_low),     .operand_2(operand_2_high), .product(partial_product_1));
    Multiplier MUL_PP_2 (.operand_1(operand_1_high),    .operand_2(operand_2_low),  .product(partial_product_2));
    Multiplier MUL_PP_3 (.operand_1(operand_1_high),    .operand_2(operand_2_high), .product(partial_product_3));

    assign product =  partial_product_0 + 
                    ({partial_product_1, 8'b0}) + 
                    ({partial_product_2, 8'b0}) + 
                    ({partial_product_3, 16'b0}); 
endmodule

module Multiplier
(
    input wire [7 : 0] operand_1,
    input wire [7 : 0] operand_2,

    output reg [15 : 0] product
);

    always @(*)
    begin
        product <= operand_1 * operand_2;
    end
endmodule