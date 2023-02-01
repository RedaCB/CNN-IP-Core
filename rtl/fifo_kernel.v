`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.12.2022 20:28:36
// Design Name: 
// Module Name: fifo_kernel
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

`define FIFO_SZ_KERNEL      9   // ROWS * COLS = (3x3)
`define FIFO_DATA_IN_WH     32
`define DATAS               9


module fifo_kernel(
        clk, resetn,
        write_fifo, read_fifo,
        empty_fifo, full_fifo,
        //counter_fifo,
        data_in,
        data_out_0,
        data_out_1,
        data_out_2,
        data_out_3,
        data_out_4,
        data_out_5,
        data_out_6,
        data_out_7,
        data_out_8
    );
    
input clk, resetn;
input write_fifo;
input read_fifo;
input [`FIFO_DATA_IN_WH - 1 : 0] data_in;
/*output*/ reg [9 : 0] counter_fifo;
output empty_fifo, full_fifo;
output reg [`FIFO_DATA_IN_WH/4 - 1 : 0]  data_out_0,
                                        data_out_1,
                                        data_out_2,
                                        data_out_3,
                                        data_out_4,
                                        data_out_5,
                                        data_out_6,
                                        data_out_7,
                                        data_out_8;

reg [`FIFO_DATA_IN_WH/4 - 1 : 0] memory_fifo [`FIFO_SZ_KERNEL-1 : 0];
reg [9 : 0] write_ptr;
reg [9 : 0] read_ptr;


//assign empty_fifo = (write_ptr == read_ptr) ? 1'b1 : 1'b0;
assign empty_fifo = (counter_fifo == 0) ? 1'b1 : 1'b0;
assign full_fifo = (counter_fifo == `FIFO_SZ_KERNEL) ? 1'b1 : 1'b0;
//assign read_fifo = (full_fifo == 1'b1) ? 1'b1 : 1'b0;

// Write BLOCK
always @(posedge clk) begin: write
    if (write_fifo == 1'b1 && full_fifo == 1'b0) begin
        memory_fifo[write_ptr] <= data_in;
    end
end

// Pointer Write BLOCK
always @(posedge clk) begin: pointer_w
    if (resetn == 1'b0) begin
        write_ptr <= 0;
    end
    else begin
        if (write_fifo == 1'b1 && full_fifo == 1'b0) begin 
            write_ptr <= (write_ptr == `FIFO_SZ_KERNEL - 1) ? 0 : write_ptr + 1;
        end
    end
end

// Read BLOCK
always @(posedge clk) begin: read
    if (read_fifo == 1'b1) begin
        data_out_0 <= memory_fifo[0];
        data_out_1 <= memory_fifo[1];
        data_out_2 <= memory_fifo[2];
        data_out_3 <= memory_fifo[3];
        data_out_4 <= memory_fifo[4];
        data_out_5 <= memory_fifo[5];
        data_out_6 <= memory_fifo[6];
        data_out_7 <= memory_fifo[7];
        data_out_8 <= memory_fifo[8];
    end
end



// Pointer Read BLOCK
/*
always @(posedge clk) begin: pointer_r
    if (resetn == 1'b0) begin
       read_ptr <= 8'h0;
    end
    else begin
        if (read_fifo == 1'b1 && empty_fifo == 1'b0) begin
            read_ptr <= (read_ptr == `FIFO_SZ_KERNEL - 1) ? 0 : 0;
        end
    end
end
*/

/*
always @(posedge clk, posedge full_fifo) begin
    if (resetn == 1'b0) begin
        // Estado inicial
        read_fifo <= 1'b0;
    end else begin
        if (full_fifo == 1'b1 && ~read_fifo) begin
            read_fifo <= 1'b1;
        end else begin
            read_fifo <= 1'b0;
        end
    end
end
*/

// Counter BLOCK
always @(posedge clk) begin: counter
    if (resetn == 1'b0) begin
        counter_fifo <= 0;
    end
    else begin
        case ({write_fifo, read_fifo})
            2'b00 : counter_fifo <= counter_fifo;
            2'b01 : counter_fifo <= (counter_fifo == 0) ? 0 : counter_fifo - 1;
            2'b10 : counter_fifo <= (counter_fifo == `FIFO_SZ_KERNEL) ? `FIFO_SZ_KERNEL : counter_fifo + 1;
            2'b11 : counter_fifo <= counter_fifo;
            default : counter_fifo <= counter_fifo;
        endcase
    end
end

endmodule
