`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.01.2023 10:46:08
// Design Name: 
// Module Name: fifo_convolution
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

`define FIFO_OUT_DATA_IN_WH 20
`define FIFO_OUT_DATA_OUT_WH 32

module fifo_convolution #(
        parameter integer C_S_FIFO_OUT_SIZE	      = 49284//676
    )(
        clk, resetn,
        write_fifo, read_fifo,
        empty_fifo, full_fifo,    
        data_in,
        data_out
    );
    
input clk, resetn;
input write_fifo, read_fifo;
input [`FIFO_OUT_DATA_IN_WH - 1 : 0] data_in;
output empty_fifo, full_fifo;
output wire [`FIFO_OUT_DATA_OUT_WH - 1 : 0] data_out;

reg [`FIFO_OUT_DATA_OUT_WH/2-1 : 0] counter_fifo;
reg [`FIFO_OUT_DATA_IN_WH - 1 : 0] memory_fifo [C_S_FIFO_OUT_SIZE-1 : 0];
reg [`FIFO_OUT_DATA_OUT_WH/2-1 : 0] write_ptr;
reg [`FIFO_OUT_DATA_OUT_WH/2-1 : 0] read_ptr;


assign empty_fifo = (counter_fifo == 0) ? 1'b1 : 1'b0;
assign full_fifo  = (counter_fifo == C_S_FIFO_OUT_SIZE) ? 1'b1 : 1'b0;


// Write BLOCK
always @(posedge clk) begin: write
    if (write_fifo == 1'b1 && full_fifo == 1'b0) begin
        memory_fifo[write_ptr] = data_in;
    end
end


// Pointer Write BLOCK
always @(posedge clk) begin: pointer_w
    if (resetn == 1'b0) begin
        write_ptr <= 0;
    end
    else begin
        if (write_fifo == 1'b1 && full_fifo == 1'b0) begin 
            write_ptr <= (write_ptr == C_S_FIFO_OUT_SIZE - 1) ? 0 : write_ptr + 1;
        end
    end
end


// Read BLOCK
assign data_out = {12'b0, memory_fifo[read_ptr]};


// Pointer Read BLOCK
always @(posedge clk) begin: pointer_r
    if (resetn == 1'b0) begin
        read_ptr <= 0;
    end
    else begin      
        if (read_fifo == 1'b1 && empty_fifo == 1'b0) begin
            read_ptr <= (read_ptr == C_S_FIFO_OUT_SIZE - 1) ? 0 : read_ptr + 1;
        end
    end
end


// Counter BLOCK
always @(posedge clk) begin: counter
    if (resetn == 1'b0) begin
        counter_fifo <= 0;
    end
    else begin
        case ({write_fifo, read_fifo})
            2'b00   : counter_fifo <= counter_fifo;
            2'b01   : counter_fifo <= (counter_fifo == 0) ? 0 : counter_fifo - 1;
            2'b10   : counter_fifo <= (counter_fifo == C_S_FIFO_OUT_SIZE) ? C_S_FIFO_OUT_SIZE : counter_fifo + 1;
            2'b11   : counter_fifo <= counter_fifo;
            default : counter_fifo <= counter_fifo;
        endcase
    end
end

endmodule
