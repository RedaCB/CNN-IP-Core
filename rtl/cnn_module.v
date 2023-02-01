`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.01.2023 17:36:10
// Design Name: 
// Module Name: cnn_module
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

module cnn_module #(parameter DATA_WIDTH = 8)(
        res_conv,
        clk, resetn,
        img_r0_c0, img_r0_c1, img_r0_c2, img_r1_c0, img_r1_c1, img_r1_c2, img_r2_c0, img_r2_c1, img_r2_c2,
        ker_r0_c0, ker_r0_c1, ker_r0_c2, ker_r1_c0, ker_r1_c1, ker_r1_c2, ker_r2_c0, ker_r2_c1, ker_r2_c2
    );

    input clk, resetn;
    input [DATA_WIDTH-1:0] img_r0_c0, img_r0_c1, img_r0_c2, img_r1_c0, img_r1_c1, img_r1_c2, img_r2_c0, img_r2_c1, img_r2_c2;
    input [DATA_WIDTH-1:0] ker_r0_c0, ker_r0_c1, ker_r0_c2, ker_r1_c0, ker_r1_c1, ker_r1_c2, ker_r2_c0, ker_r2_c1, ker_r2_c2;
    output wire [(DATA_WIDTH*2)-1+4:0] res_conv;
    wire carry_out;
    
    wire [(DATA_WIDTH*2)-1:0] mem_reg_in [8:0];
    wire [(DATA_WIDTH*2)-1+2:0] mem_reg_fi [2:0];
    
    // Structure of 9 Array Multipliers
    array_mult am_r0_c0 (mem_reg_in[0], img_r0_c0, ker_r0_c0);
    array_mult am_r0_c1 (mem_reg_in[1], img_r0_c1, ker_r0_c1);
    array_mult am_r0_c2 (mem_reg_in[2], img_r0_c2, ker_r0_c2);
    array_mult am_r1_c0 (mem_reg_in[3], img_r1_c0, ker_r1_c0);
    array_mult am_r1_c1 (mem_reg_in[4], img_r1_c1, ker_r1_c1);
    array_mult am_r1_c2 (mem_reg_in[5], img_r1_c2, ker_r1_c2);
    array_mult am_r2_c0 (mem_reg_in[6], img_r2_c0, ker_r2_c0);
    array_mult am_r2_c1 (mem_reg_in[7], img_r2_c1, ker_r2_c1);
    array_mult am_r2_c2 (mem_reg_in[8], img_r2_c2, ker_r2_c2);
    
    // Accumulation of initial registers
    sum_3regs s3r_in_0 (mem_reg_fi[0], mem_reg_in[0], mem_reg_in[1], mem_reg_in[2]);
    sum_3regs s3r_in_1 (mem_reg_fi[1], mem_reg_in[3], mem_reg_in[4], mem_reg_in[5]);
    sum_3regs s3r_in_2 (mem_reg_fi[2], mem_reg_in[6], mem_reg_in[7], mem_reg_in[8]);
    
    // Accumulation of final registers
    sum_3regs #(18) s3r_fi (res_conv, mem_reg_fi[0], mem_reg_fi[1], mem_reg_fi[2]);

endmodule
