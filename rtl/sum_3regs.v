`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.01.2023 18:05:12
// Design Name: 
// Module Name: sum_3regs
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module sum_3regs #(parameter DATA_WIDTH = 16)(
        output [DATA_WIDTH-1+2 : 0] result,
        input [DATA_WIDTH-1 : 0] reg1,
        input [DATA_WIDTH-1 : 0] reg2,
        input [DATA_WIDTH-1 : 0] reg3
    );

/*    
wire [DATA_WIDTH-1+1 : 0] s1;
wire [DATA_WIDTH-1 : 0] carry;
wire [DATA_WIDTH-1 : 0] carry2;

// Sumar reg1 y reg2: Full adder loop
genvar i;

full_adder fadd1(s1[0], carry[0], reg1[0], reg2[0], 1'b0);
for (i = 1; i < DATA_WIDTH; i = i + 1) begin
    full_adder fa (s1[i], carry[i], reg1[i], reg2[i], carry[i-1]);
end

// Sumar reg3 y el resultado de sumar reg1 y reg2
full_adder fadd2(result[0], carry2[0], s1[0], reg3[0], carry[DATA_WIDTH-1]);
for (i = 1; i < DATA_WIDTH; i = i + 1) begin
    full_adder fa (result[i], carry2[i], s1[i], reg3[i], carry2[i-1]);
end

assign result[i+1] = carry2[DATA_WIDTH-1];
*/

assign result = reg1 + reg2 + reg3;

endmodule
