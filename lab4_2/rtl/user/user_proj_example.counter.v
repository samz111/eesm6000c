// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_proj_example
 *
 * This is an example of a (trivially simple) user project,
 * showing how the user project can connect to the logic
 * analyzer, the wishbone bus, and the I/O pads.
 *
 * This project generates an integer count, which is output
 * on the user area GPIO pads (digital output only).  The
 * wishbone connection allows the project to be controlled
 * (start and stop) from the management SoC program.
 *
 * See the testbenches in directory "mprj_counter" for the
 * example programs that drive this user project.  The three
 * testbenches are "io_ports", "la_test1", and "la_test2".
 *
 *-------------------------------------------------------------
 */

module user_proj_example #(
    parameter BITS = 32,
    parameter DELAYS=10
)(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // IRQ
    output [2:0] irq
);
    wire clk;
    wire rst;

    wire [`MPRJ_IO_PADS-1:0] io_in;
    wire [`MPRJ_IO_PADS-1:0] io_out;
    wire [`MPRJ_IO_PADS-1:0] io_oeb;

//-----------sampled signal---------
    reg        wbs_stb_i_d;
    reg        wbs_cyc_i_d;
    reg        wbs_we_i_d;
    reg [3:0]  wbs_sel_i_d;
    reg [31:0] wbs_dat_i_d;
    reg [31:0] wbs_adr_i_d;
    reg        wbs_user_bram_sel;
    reg        wbs_fir_sel;
    reg        wbs_ack_o_d;
//-----------------------------------------


//-----------exmem internal signal---------
    reg [31:0] 	delay_counter; 
    reg [31:0]         delay_counter_nxt;
    wire 		user_bram_valid;
    reg                user_bram_done;
    wire 		user_bram_ce;
    wire [3:0] 	user_bram_we;
    wire [31:0] 	user_bram_addr;
    wire [31:0]        user_bram_data_o;    
    reg  [31:0]        user_bram_data_saved;
    wire               delay_finished;
//-----------------------------------------

//--------verilog fir internal signal------

    parameter pADDR_WIDTH = 12;
    parameter pDATA_WIDTH = 32;
    parameter Tape_Num    = 11;
    parameter Data_Num    = 64;

    wire                                awready;
    wire                                wready;
    wire                                awvalid;
    wire        [(pADDR_WIDTH-1):0]     awaddr;
    wire                                wvalid;
    wire signed  [(pDATA_WIDTH-1):0]    wdata;
    wire                                arready;
    wire                                rready;
    wire                                arvalid;
    wire        [(pADDR_WIDTH-1):0]     araddr;
    wire                                rvalid;
    wire signed [(pDATA_WIDTH-1):0]     rdata;
    wire                                ss_tvalid;
    wire signed  [(pDATA_WIDTH-1):0]    ss_tdata;
    wire                                ss_tlast;
    wire                                ss_tready;
    wire                                sm_tready;
    wire                                sm_tvalid;
    wire signed [(pDATA_WIDTH-1):0]     sm_tdata;
    wire                                sm_tlast;

// ram for tap
    wire [3:0]               tap_WE;
    wire                     tap_EN;
    wire [(pDATA_WIDTH-1):0] tap_Di;
    wire [(pADDR_WIDTH-1):0] tap_A;
    wire [(pDATA_WIDTH-1):0] tap_Do;

// ram for data RAM
    wire [3:0]               data_WE;
    wire                     data_EN;
    wire [(pDATA_WIDTH-1):0] data_Di;
    wire [(pADDR_WIDTH-1):0] data_A;
    wire [(pDATA_WIDTH-1):0] data_Do;

    reg                     wb_axi_sel;
    reg                     wb_xin_sel;
    reg                     wb_yout_sel;
    wire 		     wb_fir_done;
    reg [1:0]               wb_axi_fsm;
    reg [1:0]               wb_axi_fsm_nxt;
    reg [1:0]               wb_xin_fsm;
    reg [1:0]               wb_xin_fsm_nxt;
    reg [6:0]               wb_xin_counter;
    reg [6:0]               wb_xin_counter_nxt;
    reg [1:0]               wb_yout_fsm;
    reg [1:0]               wb_yout_fsm_nxt;
    reg [(pADDR_WIDTH-1):0] reg_addr;  
    
    reg                     read_to_clear;
    reg                     sm_last_d;
//----------------------------------------- 

//-------------samping signal-------------- 

    assign clk = wb_clk_i;
    assign rst = wb_rst_i;
    
    always @ (posedge clk or posedge rst) begin
        if (rst) begin       
            wbs_we_i_d   <= 1'b0;
            wbs_sel_i_d  <= 1'b0;
            wbs_dat_i_d  <= 1'b0;
            wbs_adr_i_d  <= 1'b0;
        end else if (wbs_stb_i && wbs_cyc_i) begin;        
            wbs_we_i_d   <= wbs_we_i;
            wbs_sel_i_d  <= wbs_sel_i;
            wbs_dat_i_d  <= wbs_dat_i;
            wbs_adr_i_d  <= wbs_adr_i;       
        end
    end

    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            wbs_stb_i_d  <= 1'b0;
            wbs_cyc_i_d  <= 1'b0;        
        end else begin;
            wbs_stb_i_d  <= wbs_stb_i;
            wbs_cyc_i_d  <= wbs_cyc_i;               
        end
    end    

    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            wbs_ack_o_d <= 1'b0;  
        end else begin
            wbs_ack_o_d <= wbs_user_bram_sel ? delay_finished : wb_fir_done;;           
        end
    end      
//----------------------------------------- 


//--------------verilog fir----------------   
   
    always @ (posedge clk or posedge rst) begin 
        if (rst) begin
            wb_axi_sel <= 1'b0;
        end else if (wb_fir_done) begin
            wb_axi_sel <= 1'b0;
        end else if (wbs_cyc_i_d && wbs_stb_i_d && wbs_we_i_d && (~(wbs_ack_o_d)) && ((wbs_adr_i_d == 32'h30000000) || ((wbs_adr_i_d >= 32'h30000080) && (wbs_adr_i_d <= 32'h300000a8)) || (wbs_adr_i_d == 32'h30000010) || (wbs_adr_i_d == 32'h30000014))) begin
            wb_axi_sel <= 1'b1;
        end 
    end  
     
    always @ (posedge clk or posedge rst) begin  
        if (rst) begin
            wb_xin_sel <= 1'b0;
        end else if (wb_fir_done) begin
            wb_xin_sel <= 1'b0;
        end else if (wbs_cyc_i_d && wbs_stb_i_d && wbs_we_i_d && (~(wbs_ack_o_d)) && (wbs_adr_i_d == 32'h30000040)) begin
            wb_xin_sel <= 1'b1;
        end 
    end
    
    always @ (posedge clk or posedge rst) begin     
        if (rst) begin
            wb_yout_sel <= 1'b0;
        end else if (wb_fir_done) begin
            wb_yout_sel <= 1'b0;
        end else if (wbs_cyc_i_d && wbs_stb_i_d && (~(wbs_ack_o_d)) && (wbs_adr_i_d == 32'h30000044)) begin
            wb_yout_sel <= 1'b1;
        end 
    end

    always @ (posedge clk or posedge rst) begin 
        if (rst) begin
            wb_axi_fsm <= 2'b00;
        end else begin
            wb_axi_fsm <= wb_axi_fsm_nxt;
        end 
    end                 
            
    always @(*) begin                        
        wb_axi_fsm_nxt       <= 2'b00;        
        case (wb_axi_fsm)        
            2'b00: begin // idle
                if (wb_axi_sel) begin
                    wb_axi_fsm_nxt <= 2'b01;
                end
    	    end
    	    2'b01: begin // waiting for both ready
                if (awready && wready) begin // received both ready and return to idle
                    wb_axi_fsm_nxt <= 2'b00;                    
                end else if (awready) begin  // only receive address ready
                    wb_axi_fsm_nxt <= 2'b10;
                end else if (wready) begin   // only receive write ready
                    wb_axi_fsm_nxt <= 2'b11;
                end else begin
                    wb_axi_fsm_nxt <= 2'b01;
                end                                	         
    	    end
    	    2'b10: begin // waiting for write ready
                if (wready) begin
                    wb_axi_fsm_nxt <= 2'b00;                    
                end else begin
                    wb_axi_fsm_nxt <= 2'b10;
                end        	    
    	    end
    	    2'b11: begin // waiting for address ready
                if (awready) begin
                    wb_axi_fsm_nxt <= 2'b00;                    
                end else begin
                    wb_axi_fsm_nxt <= 2'b11;
                end        	    
    	    end
    	    default: begin
    	        wb_axi_fsm_nxt <= 2'b00;    	        
    	    end
        endcase            
    end
    
    always @ (posedge clk or posedge rst) begin 
        if (rst) begin
            wb_xin_fsm <= 2'b00;
        end else begin
            wb_xin_fsm <= wb_xin_fsm_nxt;
        end 
    end 
         
    always @ (posedge clk or posedge rst) begin 
        if (rst) begin
            wb_xin_counter <= 2'b00;
        end else begin
            wb_xin_counter <= wb_xin_counter_nxt;
        end 
    end 
        
    always @(*) begin
        wb_xin_fsm_nxt     <= 2'b00;
        wb_xin_counter_nxt <= wb_xin_counter;
        case (wb_xin_fsm)
            2'b00: begin
                if (wb_xin_sel) begin
                    wb_xin_fsm_nxt     <= 2'b01;
                    wb_xin_counter_nxt <= wb_xin_counter + 1'b1;
                end
            end
            2'b01: begin
                if (ss_tready && (wb_xin_counter == Data_Num)) begin
                    wb_xin_counter_nxt <= 7'b0;
                end
                
                if (ss_tready) begin
                    wb_xin_fsm_nxt <= 2'b00;
                end else begin
                    wb_xin_fsm_nxt <= 2'b01;
                end   
            end
            2'b10:    wb_xin_fsm_nxt <= 2'b00;
            2'b11:    wb_xin_fsm_nxt <= 2'b00;
            default:  wb_xin_fsm_nxt <= 2'b00;
        endcase
    end
    
    always @ (posedge clk or posedge rst) begin 
        if (rst) begin
            wb_yout_fsm <= 2'b00;
        end else begin
            wb_yout_fsm <= wb_yout_fsm_nxt;
        end 
    end 
         
    always @(*) begin
        wb_yout_fsm_nxt     <= 2'b00;
        case (wb_yout_fsm)
            2'b00: begin
                if (wb_yout_sel) begin
                    wb_yout_fsm_nxt     <= 2'b01;
                end
            end
            2'b01: begin                
                if (sm_tvalid) begin
                    wb_yout_fsm_nxt <= 2'b00;
                end else begin
                    wb_yout_fsm_nxt <= 2'b01;
                end   
            end
            2'b10:    wb_yout_fsm_nxt <= 2'b00;
            2'b11:    wb_yout_fsm_nxt <= 2'b00;
            default:  wb_yout_fsm_nxt <= 2'b00;
        endcase
    end
    
    always @(*) begin  
        case (wbs_adr_i_d)
            32'h30000000: reg_addr <= 12'h0;
            32'h30000010: reg_addr <= 12'h10;
            32'h30000014: reg_addr <= 12'h14;                        
            default: begin
                reg_addr <= wbs_adr_i_d - 12'h80 + 12'h40; // verilog fir assumed the input base addr of tap is 12'h40
            end
        endcase
    end

    always @ (posedge clk or posedge rst) begin 
        if (rst) begin
            sm_last_d <= 1'b0;
        end else begin
            sm_last_d <= sm_tlast;
        end 
    end 
    
    always @ (posedge clk or posedge rst) begin 
        if (rst) begin
            read_to_clear <= 1'b0;
        end else if (sm_last_d)begin
            read_to_clear <= 1'b1;
        end else if (arready) begin
            read_to_clear <= 1'b1;
        end
    end 

    assign awvalid = (wb_axi_fsm == 2'b01) || (wb_axi_fsm == 2'b11);
    assign awaddr  = reg_addr;
    assign wvalid  = (wb_axi_fsm == 2'b01) || (wb_axi_fsm == 2'b10);
    assign wdata   = wbs_dat_i_d;    
    
    assign arvalid = read_to_clear;
    assign araddr  = 12'b0;
    assign rready  = 1'b1;
    
    assign ss_tvalid = (wb_xin_fsm == 2'b01);
    assign ss_tlast  = (wb_xin_counter == Data_Num);
    assign ss_tdata  = wbs_dat_i_d;
    
    assign sm_tready = (wb_yout_fsm == 2'b01);
    
    assign wbs_ack_o = wbs_user_bram_sel ? delay_finished : wb_fir_done;
    
    assign wb_fir_done = ((wb_axi_fsm != 2'b00) && (wb_axi_fsm_nxt == 2'b00)) || ((wb_xin_fsm != 2'b00) && (wb_xin_fsm_nxt == 2'b00)) || ((wb_yout_fsm != 2'b00) && (wb_yout_fsm_nxt == 2'b00));
        
    assign wbs_dat_o = wbs_user_bram_sel ? user_bram_data_saved : sm_tdata & {32{sm_tvalid}};
    
    fir fir_DUT(
        .awready(awready),
        .wready(wready),
        .awvalid(awvalid),
        .awaddr(awaddr),
        .wvalid(wvalid),
        .wdata(wdata),
        .arready(arready),
        .rready(rready),
        .arvalid(arvalid),
        .araddr(araddr),
        .rvalid(rvalid),
        .rdata(rdata),
        .ss_tvalid(ss_tvalid),
        .ss_tdata(ss_tdata),
        .ss_tlast(ss_tlast),
        .ss_tready(ss_tready),
        .sm_tready(sm_tready),
        .sm_tvalid(sm_tvalid),
        .sm_tdata(sm_tdata),
        .sm_tlast(sm_tlast),

        // ram for tap
        .tap_WE(tap_WE),
        .tap_EN(tap_EN),
        .tap_Di(tap_Di),
        .tap_A(tap_A),
        .tap_Do(tap_Do),

        // ram for data
        .data_WE(data_WE),
        .data_EN(data_EN),
        .data_Di(data_Di),
        .data_A(data_A),
        .data_Do(data_Do),

        .axis_clk(clk),
        .axis_rst_n(!rst)

        );
    
    // RAM for tap:  
    bram11 tap_RAM (
        .CLK(clk),
        .WE(tap_WE),
        .EN(tap_EN),
        .Di(tap_Di),
        .A(tap_A),
        .Do(tap_Do)
    );

    // RAM for data: choose bram11 or bram12
    bram11 data_RAM(
        .CLK(clk),
        .WE(data_WE),
        .EN(data_EN),
        .Di(data_Di),
        .A(data_A),
        .Do(data_Do)
    );

//-----------------------------------------



//------------------exmem -----------------
    assign user_bram_addr = ((wbs_adr_i_d - 32'h38000000) >> 2);
    
    assign delay_finished = (delay_counter == 32'd10);
    
    assign user_bram_we = wbs_sel_i_d & {4{wbs_we_i_d}};
    assign user_bram_valid = wbs_cyc_i_d && wbs_stb_i_d && (~(wbs_ack_o_d)) && (wbs_adr_i_d >= 32'h38000000) && (wbs_adr_i_d <= 32'h38400000);
    assign user_bram_ce = user_bram_valid;
    
    always @ (posedge clk or posedge rst) begin
	if (rst) begin
	    delay_counter_nxt = 32'b0;
	end else if (delay_finished) begin
	    delay_counter_nxt = 32'b0;
	end else if (user_bram_valid) begin
	    delay_counter_nxt = delay_counter + 1'b1;
	end
    end
	
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wbs_user_bram_sel <= 1'b0;
        end else if (delay_finished) begin
            wbs_user_bram_sel <= 1'b0;
        end else if (user_bram_valid)begin
            wbs_user_bram_sel <= 1'b1;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            user_bram_data_saved <= 1'b0;
        end else if (user_bram_valid && user_bram_done) begin
            user_bram_data_saved <= user_bram_data_o;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            user_bram_done <= 1'b0;
        end else begin
            user_bram_done <= user_bram_valid;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            delay_counter <= 1'b0;
        end else begin
            delay_counter <= delay_counter_nxt;
        end
    end

    bram user_bram (
        .CLK(clk),
        .WE0(user_bram_we),
        .EN0(user_bram_ce),
        .Di0(wbs_dat_i_d),
        .Do0(user_bram_data_o),
        .A0(user_bram_addr)
    );
//-----------------------------------------  
    


endmodule



`default_nettype wire
