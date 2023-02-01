`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.12.2022 13:04:54
// Design Name: 
// Module Name: fifo_35to9
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

`define FIFO_SZ             50176//36//784 // ROWS * COLS = (28x28) // 224*224 = 50176
`define FIFO_DATA_IN_WH     32
`define FIFO_DATA_OUT_WH    8
`define BUFFER_WINDOW       451// 224(1st row) + 224(2nd row) + 3(3rd row)           15//59 for 28x28
`define DATAS               9
`define ROW_PIXELS          224

module fifo_image(
        clk, resetn,
        write_fifo, read_fifo,
        empty_fifo, full_fifo,
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
reg [`FIFO_DATA_IN_WH/2 - 1 : 0] counter_fifo, special_count;
output empty_fifo, full_fifo;
output reg [`FIFO_DATA_OUT_WH - 1 : 0]  data_out_0,
                                        data_out_1,
                                        data_out_2,
                                        data_out_3,
                                        data_out_4,
                                        data_out_5,
                                        data_out_6,
                                        data_out_7,
                                        data_out_8;

reg [`FIFO_DATA_IN_WH/4 - 1 : 0] memory_fifo [`FIFO_SZ-1 : 0];
reg [`FIFO_DATA_IN_WH/2 - 1 : 0] write_ptr;
reg [`FIFO_DATA_IN_WH/2 - 1 : 0] read_ptr;


//assign empty_fifo = (write_ptr == read_ptr) ? 1'b1 : 1'b0;
assign empty_fifo = (counter_fifo == (`ROW_PIXELS*4)-4) ? 1'b1 : 1'b0;
assign full_fifo = (counter_fifo == `FIFO_SZ) ? 1'b1 : 1'b0;
//assign read_fifo = (full_fifo == 1'b1) ? 1'b1 : 1'b0;


// Write BLOCK
always @(posedge clk) begin: write
    if (write_fifo == 1'b1 && full_fifo == 1'b0) begin
        memory_fifo[write_ptr]   <= data_in[(`FIFO_DATA_IN_WH/4)-1   : 0];
        memory_fifo[write_ptr+1] <= data_in[(`FIFO_DATA_IN_WH/2)-1   : (`FIFO_DATA_IN_WH/4)];
        memory_fifo[write_ptr+2] <= data_in[(`FIFO_DATA_IN_WH/4*3)-1 : (`FIFO_DATA_IN_WH/2)];
        memory_fifo[write_ptr+3] <= data_in[(`FIFO_DATA_IN_WH-1)     : (`FIFO_DATA_IN_WH/4*3)];
    end
end

// Pointer Write BLOCK
always @(posedge clk) begin: pointer_w
    if (resetn == 1'b0) begin
        write_ptr <= 0;
    end
    else begin
        if (write_fifo == 1'b1 && full_fifo == 1'b0) begin 
            write_ptr <= (write_ptr == `FIFO_SZ - 1) ? 0 : write_ptr + 4;
        end
    end
end

// Read BLOCK
always @(posedge clk) begin: read
    if (read_fifo == 1'b1 && empty_fifo == 1'b0) begin
        data_out_0 <= memory_fifo[read_ptr];
        data_out_1 <= memory_fifo[read_ptr+1];
        data_out_2 <= memory_fifo[read_ptr+2];
        data_out_3 <= memory_fifo[read_ptr+3 + ((`BUFFER_WINDOW-`DATAS)/2)];
        data_out_4 <= memory_fifo[read_ptr+4 + ((`BUFFER_WINDOW-`DATAS)/2)];
        data_out_5 <= memory_fifo[read_ptr+5 + ((`BUFFER_WINDOW-`DATAS)/2)];
        data_out_6 <= memory_fifo[read_ptr+6 + (`BUFFER_WINDOW-`DATAS)];
        data_out_7 <= memory_fifo[read_ptr+7 + (`BUFFER_WINDOW-`DATAS)];
        data_out_8 <= memory_fifo[read_ptr+8 + (`BUFFER_WINDOW-`DATAS)];
    end
end



// Pointer Read BLOCK
always @(posedge clk) begin: pointer_r
    if (resetn == 1'b0) begin
       read_ptr <= -1;
    end
    else begin
        if (read_fifo == 1'b1 && empty_fifo == 1'b0) begin
            if (special_count == `ROW_PIXELS-2) begin
                read_ptr <= read_ptr + 3;
            end else
                read_ptr <= (read_ptr == `FIFO_SZ - 1) ? -1 : read_ptr + 1;
            end
        end
    end


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
            2'b01 : counter_fifo <= (counter_fifo-`BUFFER_WINDOW-`DATAS+3 == 0) ? 0 : counter_fifo - 1;
            2'b10 : counter_fifo <= (counter_fifo == `FIFO_SZ) ? `FIFO_SZ : counter_fifo + 4;
            2'b11 : counter_fifo <= counter_fifo;
            default : counter_fifo <= counter_fifo;
        endcase
    end
end

// Special Counter BLOCK
always @(posedge clk) begin: special_counter
    if (resetn == 1'b0) begin
        special_count <= 0;
    end
    else begin
        case (read_fifo)
            1'b0 : special_count <= special_count;
            1'b1 : special_count <= (special_count == `ROW_PIXELS-2) ? 1 : special_count + 1;
            default : special_count <= special_count;
        endcase
    end
end

endmodule

