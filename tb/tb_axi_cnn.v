`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.01.2023 12:29:46
// Design Name: 
// Module Name: tb_axi_cnn
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


module tb_axi_cnn(

    );

// Local Parameters
localparam period = 10; // Duration for each bit = period * timescale = period * 1ns = 10ns
localparam TOTAL_PIXELS = 50176;
reg clk, resetn;


// WRITE CHANNELS
// Inputs of AXI4 - WRITE (reg)
reg [5 : 0] addrw_addr;
reg [7 : 0] addrw_numTranfers;
reg [2 : 0] addrw_size;
reg [1 : 0] addrw_burst;
reg [0 : 0] addrw_id;

reg [31 : 0] dataw_data;
reg dataw_last;
reg [3 : 0] dataw_flash;

reg addrw_valid, dataw_valid, respw_ready;

// Outputs of AXI4 - WRITE (wire)
wire addrw_ready, dataw_ready, respw_valid;

wire [1 : 0] respw_resp;
wire respw_id;


// READ CHANNELS
// Inputs of AXI4 - READ
reg [5 : 0] addrr_addr;
reg [2 : 0] addrr_size;
reg [7 : 0] addrr_len;
reg [1 : 0] addrr_burst;
reg addrr_valid;

reg datar_ready;

// Outputs of AXI4 - READ
wire addrr_ready;

wire [1 : 0] datar_resp;
wire [31 : 0] datar_data;
wire datar_valid;
wire datar_last;
wire kg_fin;

// Registers
wire [31 : 0] reg_status;
wire [31 : 0] reg_control;
reg [127 : 0] iv_key;


// Instance of module AXI4
myip_axi_v1_0 UUT(
    .s00_axi_aclk(clk),
    .s00_axi_aresetn(resetn),
    
    // SIGNALS of Write Address Channel
    .s00_axi_awaddr(addrw_addr),        // Input    - Write Address Channel
    .s00_axi_awsize(addrw_size),        // Input    - Write Address Channel
    .s00_axi_awlen(addrw_numTranfers),  // Input    - Write Address Channel
    .s00_axi_awburst(addrw_burst),      // Input    - Write Address Channel
    .s00_axi_awvalid(addrw_valid),      // Input    - Write Address Channel
    .s00_axi_awready(addrw_ready),      // Output   - Write Address Channel
    .s00_axi_awid(addrw_id),            // Input    - Write Address Channel
    
    // SIGNALS of Write Data Channel
    .s00_axi_wdata(dataw_data),         // Input    - Write Data Channel
    .s00_axi_wvalid(dataw_valid),       // Input    - Write Data Channel
    .s00_axi_wready(dataw_ready),       // Output   - Write Data Channel
    .s00_axi_wlast(dataw_last),         // Input    - Write Data Channel
    .s00_axi_wstrb(dataw_flash),
    
    // SIGNALS of Write Response Channel
    .s00_axi_bresp(respw_resp),         // Output   - Write Response Channel
    .s00_axi_bvalid(respw_valid),       // Output   - Write Response Channel
    .s00_axi_bready(respw_ready),       // Input    - Write Response Channel
    .s00_axi_bid(respw_id),             // Output   - Write Response Channel
    
    
    // SIGNALS of Read Address Channel
    .s00_axi_araddr(addrr_addr),        // Input    - Read Address Channel
    .s00_axi_arlen(addrr_len),          // Input    - Read Address Channel
    .s00_axi_arsize(addrr_size),        // Input    - Read Address Channel
    .s00_axi_arburst(addrr_burst),      // Input    - Read Address Channel
    .s00_axi_arvalid(addrr_valid),      // Input    - Read Address Channel
    .s00_axi_arready(addrr_ready),      // Output   - Read Address Channel
    
    // SIGNALS of Read Data Channel
    .s00_axi_rdata(datar_data),
    .s00_axi_rresp(datar_resp),
    .s00_axi_rlast(datar_last),
    .s00_axi_rvalid(datar_valid),
    .s00_axi_rready(datar_ready),
    
    // Reg Signals
    .s01_reg_status(reg_status),
    .s02_reg_control(reg_control)
    
);

// Clock
always begin
    clk = 1'b1; 
    #(period/2); // high for period * timescale = 20 ns

    clk = 1'b0;
    #(period/2); // low for period * timescale = 20 ns
end

// Set initial state
task initialState;
    begin 
        // Write Channels
        addrw_valid <= 1'b0;
        addrw_numTranfers = 8'b00000000;
        addrw_size <= 3'b000;
        addrw_burst <= 2'b00;
        addrw_id <= 1'b0;
        
        dataw_valid <= 1'b0;
        dataw_last <= 1'b0;
        
        respw_ready = 1'b0;
        
        // Read Channels
        addrr_addr <= 'h00;
        addrr_len <= 1'b0;
        addrr_size <= 1'b0;
        addrr_burst <= 1'b0;
        addrr_valid <= 1'b0;
        
        datar_ready <= 1'b1;
        
    end
endtask

// Set enable reset
task enableResetn;
    begin
        #period;
        @(posedge clk)
        resetn = 1'b1;
        #period;
    end
endtask

// Task for write on AXI4 Full
task axi_write(
    input [5:0] i_addr,
    input [31:0] i_data
);
//fork : f
    begin
        // Configure Address of Write
        addrw_id = 1'b1;
        addrw_valid <= 1'b1;
        assign addrw_addr  = i_addr;
        addrw_numTranfers = 8'b00000000;
        addrw_size = 3'b010;
        //addrw_burst = 2'b01;
        respw_ready <= 1'b1;
        #period;
        
        addrw_valid <= 1'b0;
        addrw_id <= 1'b0;
        
        // Send Data
        dataw_valid <= 1'b1;
        #(period);
        
        dataw_data  <= i_data;
        dataw_last <= 1'b1;
        dataw_flash <= 4'hf;
        #period;

        dataw_valid <= 1'b0;
        dataw_last <= 1'b0;
        while(dataw_ready == 1'b0) begin
            #period;
        end

    end
endtask

// Task for read on AXI4 Full
task axi_read(
    input [5:0] i_addr
);
    begin
        // Configure Address of Read
        #period;
        addrr_valid <= 1'b1;
        addrr_addr <= i_addr;
        #(period*2);
        addrr_valid <= 1'b0;
        #period;
        datar_ready <= 1'b1;
        #period;
        datar_ready <= 1'b0;
    end
endtask

reg [7:0] i = 1'b0;
reg [31:0] var_i = 1'b0;
integer count = 0;

// loop of writes
always @(posedge clk) begin
    //for (i=0; i<256; i=i+1) begin
    if (dataw_last) begin
        var_i <= {(i+2'b11), (i+2'b10), (i+1'b1), i};
        //i = i + 1'b1;
    end
end

always @(posedge clk)
begin
    // ------------------------------------------
	// -- Phase 0: Active System
	// ------------------------------------------
    resetn = 1'b0;
    initialState();
    #period;
    enableResetn();
    #period;
    axi_read('h0C);

    /*
    if ( datar_data == 'h0C) begin
        $display ("[Time %0t ps] IntReg value = %x", $time, DUT.IntModule.IntReg);
    end else
        $display ("[Time %0t ps] IntReg value = %x", $time, DUT.IntModule.IntReg);
    end
    */
    axi_write('h00, var_i);
	#(period*3);
    
    // ------------------------------------------
	// -- Phase 1: Send Image
	// ------------------------------------------
    //for (i = 0; i < 196/4; i = i + 1) begin
    
    axi_write('h00, var_i);
    //axi_write('h00, var_i);
    
    for (i = 0; count <= TOTAL_PIXELS/4; i = i + 4) begin: bucle_for
        axi_write('h04, var_i);
        count = count + 1;
        //axi_write('h04, 'hDDDDDDDD);
        //#period;
    end
    
    // ------------------------------------------
	// -- Phase 2: Send Kernel
	// ------------------------------------------
    axi_write('h08, 'h00);
    #period;
    axi_write('h08, 'h01);
    #period;
    axi_write('h08, 'h00);
    #period;
    axi_write('h08, 'h01);
    #period;
    axi_write('h08, 'h00);
    #period;
    axi_write('h08, 'h01);
    #period;
    axi_write('h08, 'h00);
    #period;
    axi_write('h08, 'h01);
    #period;
    axi_write('h08, 'h00);
    #(period*10);
    
    
    /* ACTIVAMOS CONVOLUTION */
    axi_write('h00, 'h00000001);
    #period;
    
    // Wait CONV_FIN
    while(reg_status[0] == 1) begin
       #period; 
    end
    #(period*10);
    
    
    // ------------------------------------------
	// -- Phase 4: Read results from FIFO_OUT
	// ------------------------------------------
    axi_read('h04);
    #(period*3);
    axi_read('h04);
    #(period*3);
    axi_read('h04);
    #(period*3);
    axi_read('h04);
    #(period*20);
    $stop;
    
    // ENCRYPTION WITH SEED_1
	/// TEST 2: Input Encryption (Device)  ->  AAAAAAAA BBBBBBBB AAAAAAAA BBBBBBBB
	/// TEST 2: Input Encryption (CT-O)    ->  BBBBBBBB AAAAAAAA BBBBBBBB AAAAAAAA
	/// TEST 2: Result Encryption (Device) ->  ec37ecb9 92740bec 68a69ef7 e863935c
	/// TEST 2: Result Encryption (CT-O)   ->  5c9363e8 f79ea668 ec0b7492 b9ec37ec
    /* CARGAMOS FIFO_DATA_IN */
    axi_write('h04, 'hAAAAAAAA);
    #period;
    axi_write('h04, 'hBBBBBBBB);
    #period;
    axi_write('h04, 'hAAAAAAAA);
    #period;
    axi_write('h04, 'hBBBBBBBB);
    #(period*10);
    /* ACTIVAMOS ENCRIPTACIÓN */
    //axi_write('h0C, 'h00000001);    // ECB Mode
    axi_write('h0C, 'h00000041); // CBC Mode
    #period;
    
    // Wait ENCRYPT_FIN
    while(reg_status[0] == 1) begin
       #period; 
    end
    #(period*10);
    
    // ------------------------------------------
	// -- Phase 3: Decryption Something
	// ------------------------------------------
		// DESENCRYPTION WITH SEED_1
	/// TEST 3: Input Desencryption (Device)   ->  deae1a89 b07f6e26 246b3283 cef7b78c
	/// TEST 3: Input Desencryption (CT-O)     ->  8cb7f7ce 83326b24 266e7fb0 891aaede 
	/// TEST 3: Result Desencryption (Device)  ->  00010203 04050607 08090a0b 0c0d0e0f  
	/// TEST 3: Result Desencryption (CT-O)    ->  0f0e0d0c 0b0a0908 07060504 03020100
    /* CARGAMOS FIFO_DATA_IN */
    //axi_write('h04, 'hdeae1a89);
    axi_write('h04, 'h80881c6b);
    #period;
    //axi_write('h04, 'hb07f6e26);
    axi_write('h04, 'he80f33d1);
    #period;
    //axi_write('h04, 'h246b3283);
    axi_write('h04, 'he7cdaf01);
    #period;
    //axi_write('h04, 'hcef7b78c);
    axi_write('h04, 'ha2e89dee);
    #(period*10);
    /* ACTIVAMOS DESENCRIPTACIÓN */
    //axi_write('h0C, 'h00000001);    // ECB Mode
    axi_write('h0C, 'h00000042); // CBC Mode
    #period;
    
    // Wait ENCRYPT_FIN
    while(reg_status[1] == 1) begin
       #period; 
    end
    #(period*10);
	
	// ------------------------------------------
	// -- Phase 4: Read results from FIFO_OUT
	// ------------------------------------------
	axi_read('h0C);
	#(period*3);
    axi_read('h04);
    #(period*3);
    axi_read('h04);
    #(period*3);
    axi_read('h04);
    #(period*3);
    axi_read('h04);
    #(period*3);
    axi_read('h04);
    #(period*3);
    axi_read('h04);
    #(period*3);
    axi_read('h04);
    #(period*3);
    axi_read('h04);
    #(period*3);
    axi_read('h04);
    #(period*3);
    axi_read('h04);
    #(period*3);
    axi_read('h04);
    #(period*3);
    axi_read('h04);
    #(period*10);
    $stop;
end

endmodule
