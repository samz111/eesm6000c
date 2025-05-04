 //////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/15/2025 
// Design Name: Zhang weiye
// Module Name: fir
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

 (* use_dsp = "no" *)
module fir 
#(  parameter pADDR_WIDTH = 12,
    parameter pDATA_WIDTH = 32,
    parameter Tape_Num    = 11
)
(
    output  wire                     awready,
    output  wire                     wready,
    input   wire                     awvalid,
    input   wire [(pADDR_WIDTH-1):0] awaddr,
    input   wire                     wvalid,
    input   wire [(pDATA_WIDTH-1):0] wdata,
    output  wire                     arready,
    input   wire                     rready,
    input   wire                     arvalid,
    input   wire [(pADDR_WIDTH-1):0] araddr,
    output  wire                     rvalid,
    output  wire [(pDATA_WIDTH-1):0] rdata,    
    input   wire                     ss_tvalid, 
    input   wire [(pDATA_WIDTH-1):0] ss_tdata, 
    input   wire                     ss_tlast, 
    output  wire                     ss_tready, 
    input   wire                     sm_tready, 
    output  wire                     sm_tvalid, 
    output  wire [(pDATA_WIDTH-1):0] sm_tdata, 
    output  wire                     sm_tlast, 
    
    // bram for tap RAM
    output  wire [3:0]               tap_WE,
    output  wire                     tap_EN,
    output  wire [(pDATA_WIDTH-1):0] tap_Di,
    output  wire [(pADDR_WIDTH-1):0] tap_A,
    input   wire [(pDATA_WIDTH-1):0] tap_Do,

    // bram for data RAM
    output  wire [3:0]               data_WE,
    output  wire                     data_EN,
    output  wire [(pDATA_WIDTH-1):0] data_Di,
    output  wire [(pADDR_WIDTH-1):0] data_A,
    input   wire [(pDATA_WIDTH-1):0] data_Do,

    input   wire                     axis_clk,
    input   wire                     axis_rst_n
);


reg                      tap_awready;
reg                      tap_wready;
reg                      tap_arready;
reg [(pADDR_WIDTH-1):0]  tap_waddr;
reg [(pADDR_WIDTH-1):0]  tap_raddr;
reg [(pDATA_WIDTH-1):0]  tap_wdata;
reg [(pDATA_WIDTH-1):0]  tap_rdata;
reg [1:0]                tap_write_ready;
reg                      tap_read_ready;
reg                      tap_read_received;
reg                      tap_read_sent;
reg [1:0]                tap_write_resp_sent;  

reg [(pADDR_WIDTH-1):0]  data_waddr;
reg [(pDATA_WIDTH-1):0]  data_wdata;
reg                      data_write_ready;
reg                      ss_tready_sent;

reg [1:0]                running_fsm;
reg [1:0]                running_fsm_xnt;
reg                      ss_tlast_dly;

reg                      calc_read;
reg                      calc_read_dly;
reg                      calc_write;
wire                     calc_done; 
reg  [(pADDR_WIDTH-1):0] calc_cnt;  
wire [(pADDR_WIDTH-1):0] calc_read_addr;
wire [(pADDR_WIDTH-1):0] calc_write_addr;
reg  [2:0]               mem_ctrl_fsm;
reg  [2:0]               mem_ctrl_fsm_nxt;
reg                      first_read;
reg                      first_around;

reg [31:0]               ap_reg;
reg [31:0]               data_length;
reg [31:0]               tap_num;

reg [(pDATA_WIDTH-1):0]  calc_data;
reg [(pDATA_WIDTH-1):0]  multiply_data;
reg                      result_done;
reg                      result_done_dly;
wire [(pDATA_WIDTH-1):0] data_Do_mod;

assign awready          = tap_awready;
assign wready           = tap_wready;
assign arready          = tap_arready;

// assuming no legacy data is allowed to read from shift register and 0 is used as default value
assign data_Do_mod      =  first_around ? {(pDATA_WIDTH-1){1'b0}} : (calc_done ? ss_tdata : data_Do);
assign calc_read_addr   =  first_read ? 12'd10 : (12'd10 - calc_cnt);
assign calc_write_addr  =  (12'd10 - calc_cnt);

assign tap_WE = {4{(&tap_write_ready && ap_reg[2])}};
assign tap_EN = ((&tap_write_ready && ap_reg[2]) || (tap_read_received && ap_reg[2] && (tap_raddr != 12'b0) && (tap_raddr != 12'h10) && (tap_raddr != 12'h14)) || calc_read_dly);
assign tap_A  = (&tap_write_ready && ap_reg[2]) ? (tap_waddr -12'h40) : ((tap_read_ready && ap_reg[2]) ? (tap_raddr - 12'h40)  : ((calc_read || first_read) ? (calc_read_addr << 12'd2) : 32'b0));
assign tap_Di = (&tap_write_ready && ap_reg[2]) ? tap_wdata : 32'b0;
assign rvalid = tap_read_sent;
assign rdata  = tap_rdata;

assign data_WE = {4{calc_write}};
assign data_EN = (calc_write || calc_read_dly);
assign data_A  = (calc_write ? (calc_write_addr << 12'd2) :  (((calc_read && (!calc_done)) || first_read) ? ((calc_read_addr - 12'd1) << 12'd2) : 32'b0));
assign data_Di = (calc_write && (!calc_done)) ? data_Do_mod : data_wdata;

assign sm_tdata  = calc_data;
assign sm_tvalid = result_done;
assign sm_tlast  = result_done && ss_tlast_dly;
assign ss_tready = data_write_ready && (!ss_tready_sent);

assign calc_done = (calc_cnt == 12'd10);

// memory control fsm
// contorlling the read/write operation of  tap memory and data memory 
always @(*) begin
    mem_ctrl_fsm_nxt    <= 3'b000;
    first_read          <= 1'b0;
    calc_read           <= 1'b0;
    calc_write          <= 1'b0;
    if ((((!ap_reg[2]) && (!ap_reg[1])) || ap_reg[0]) && (data_write_ready))  begin
        case(mem_ctrl_fsm)
            3'b000: begin // mem first read
                mem_ctrl_fsm_nxt <= 3'b001;
                first_read       <= 1'b1;
            end
            3'b001: begin // first read bubble
                mem_ctrl_fsm_nxt <= 3'b010;
            end
            3'b010: begin // mem read
                mem_ctrl_fsm_nxt  <= 3'b011;                
                calc_read         <= 1'b1;
            end
            3'b011: begin // mem write
                if (calc_done) begin
                    mem_ctrl_fsm_nxt    <= 3'b100;
                end else begin
                    mem_ctrl_fsm_nxt    <= 3'b010;
                end
                calc_write              <= 1'b1;
            end                            
            3'b100: begin // wait for sm_tready       
                if (sm_tready) begin
                    mem_ctrl_fsm_nxt    <= 3'b000; 
                end else begin
                    mem_ctrl_fsm_nxt    <= 3'b100;
                end                 
            end
            default: mem_ctrl_fsm_nxt    <= 3'b000;
        endcase
    end else begin
        mem_ctrl_fsm_nxt <= 2'b00;
    end
end

// data multiplication   
always @(posedge axis_clk) begin
    if ((calc_done && (mem_ctrl_fsm == 3'b100)) || ap_reg[0]) begin
        multiply_data <= {pDATA_WIDTH{1'b0}};
    end else if (calc_read_dly) begin 
        multiply_data <= (tap_Do * data_Do_mod);
    end
end    

// data adding
always @(posedge axis_clk) begin
    if (first_read) begin
        calc_data <= {pDATA_WIDTH{1'b0}};
    end else if ((calc_read && (calc_cnt != 12'd0)) || ((mem_ctrl_fsm == 3'b100) && (!result_done))) begin
        calc_data <= calc_data + multiply_data;
    end
end  

// indicating if the final result is valid
always @(posedge axis_clk or negedge axis_rst_n) begin
    if (!axis_rst_n) begin
        result_done <= 1'b0;
    end else if (ap_reg[0]) begin
        result_done <= 1'b0;
    end else if (sm_tready) begin
        result_done <= 1'b0;        
    end else if (calc_done && (mem_ctrl_fsm == 3'b100)) begin
        result_done <= 1'b1;
    end
end  

// tap write addr sampling
always @(posedge axis_clk) begin
    if (awvalid) begin
        tap_waddr <= awaddr; // assuming no illegal addr input
    end 
end

// tap write data sampling
always @(posedge axis_clk) begin
    if (wvalid) begin
        tap_wdata <= wdata;
    end 
end

// tap read addr sampling
always @(posedge axis_clk) begin
    if (arvalid) begin       
        tap_raddr <= araddr;        
    end 
end

// tap read data sampling
always @(posedge axis_clk) begin
    if (tap_read_received) begin  
        if (tap_raddr == 12'h0) begin
            tap_rdata <= ap_reg;
        end else if (tap_raddr == 12'h10)begin
            tap_rdata <= data_length;
        end else if (tap_raddr == 12'h14) begin
            tap_rdata <= tap_num;    
        end else if (!ap_reg[2]) begin   
            tap_rdata <= 32'hffff_ffff;                
        end else begin            
            tap_rdata <= tap_Do;
        end 
    end 
end

// tap write resp sent[0] flag setting
always @(posedge axis_clk or negedge axis_rst_n) begin
    if (!axis_rst_n) begin
        tap_write_resp_sent[0] <= 1'b0;
    end else if (&tap_write_ready) begin
        tap_write_resp_sent[0] <= 1'b0;        
    end else if (tap_write_ready[0]) begin
        tap_write_resp_sent[0] <= 1'b1;
    end
end

// tap write resp sent[1] flag setting
always @(posedge axis_clk or negedge axis_rst_n) begin
    if (!axis_rst_n) begin
        tap_write_resp_sent[1] <= 1'b0;
    end else if (&tap_write_ready) begin
        tap_write_resp_sent[1] <= 1'b0;        
    end else if (tap_write_ready[1]) begin
        tap_write_resp_sent[1] <= 1'b1;
    end
end

// tap write addr flag setting
always @(posedge axis_clk or negedge axis_rst_n) begin
    if (!axis_rst_n) begin
        tap_write_ready[0] <= 1'd0;    
    end else if (awvalid && (!tap_write_ready[0]) && (!tap_awready)) begin
        tap_write_ready[0] <= 1'b1;
    end else if (&tap_write_ready) begin
        tap_write_ready[0] <= 1'b0;
    end
end    

// tap write addr ready output setting
always @(posedge axis_clk or negedge axis_rst_n) begin
    if (!axis_rst_n) begin
        tap_awready <= 1'b0;
    end else if (tap_write_ready[0] && (!tap_write_resp_sent[0])) begin
        tap_awready <= 1'b1;
    end else if (tap_awready) begin
        tap_awready <= 1'b0;
    end
end  

// tap write data flag setting
always @(posedge axis_clk or negedge axis_rst_n) begin  
    if (!axis_rst_n) begin
        tap_write_ready[1] <= 1'd0;
    end else if (wvalid && (!tap_write_ready[1]) && (!tap_wready)) begin     
        tap_write_ready[1] <= 1'b1;
    end else if (&tap_write_ready) begin
        tap_write_ready[1] <= 1'b0;
    end
end

// tap write data ready output setting
always @(posedge axis_clk or negedge axis_rst_n) begin
    if (!axis_rst_n) begin
        tap_wready <= 1'b0;
    end else if (tap_write_ready[1] && (!tap_write_resp_sent[1])) begin
        tap_wready <= 1'b1;
    end else if (tap_wready)begin
        tap_wready <= 1'b0;
    end
end  

// tap read addr flag setting
always @(posedge axis_clk or negedge axis_rst_n) begin    
    if (!axis_rst_n) begin
        tap_read_ready <= 1'd0;
    end else if (arvalid && (!tap_read_received) && (!tap_read_sent) && (!tap_read_ready)) begin     
        tap_read_ready <= 1'b1;
    end else if (tap_read_ready) begin
        tap_read_ready <= 1'b0;
    end
end

// tap read addr ready output setting
always @(posedge axis_clk or negedge axis_rst_n) begin
    if (!axis_rst_n) begin
        tap_arready <= 1'b0;
    end else if (tap_read_ready) begin     
        tap_arready <= 1'b1;
    end else begin
        tap_arready <= 1'b0;
    end
end

// misc flip flop
always @(posedge axis_clk) begin    
    tap_read_received <= tap_read_ready;
    calc_read_dly     <= calc_read || first_read;    
end

always @(posedge axis_clk or negedge axis_rst_n) begin
    if (!axis_rst_n) begin
        ss_tlast_dly <= 1'b0;
    end else if (sm_tready) begin
        ss_tlast_dly <= 1'b0;
    end else if (ss_tvalid && !data_write_ready) begin
        ss_tlast_dly <= ss_tlast;
    end
end

// misc reset flip flop 0
always @(posedge axis_clk or negedge axis_rst_n) begin    
    if (!axis_rst_n) begin
        result_done_dly   <= 1'b0;        
    end else begin
        result_done_dly   <= result_done;
    end
end

// misc rest flip flop 1
always @(posedge axis_clk or negedge axis_rst_n) begin  
    if (!axis_rst_n) begin
        tap_read_sent       <= 1'b0;     
    end else if (tap_read_received) begin
        tap_read_sent       <= 1'b1;
    end else if (rready) begin
        tap_read_sent       <= 1'b0;    
    end
end

// ap_start flip flop
always @(posedge axis_clk or negedge axis_rst_n) begin   
    if (!axis_rst_n) begin        
        ap_reg[0] <= 0;
    end else if ((ap_reg[2]) && ((&tap_write_ready) && (tap_waddr == 12'h000))) begin
        ap_reg[0] <= 1;
    end else if (ap_reg[0] && data_write_ready) begin
        ap_reg[0] <= 0;
    end
end

// ap_done flip flop
always @(posedge axis_clk or negedge axis_rst_n) begin    
    if (!axis_rst_n) begin
        ap_reg[1] <= 1'b0;
    end else if (sm_tready && result_done && ss_tlast_dly) begin
        ap_reg[1] <= 1'b1;
    end else if (tap_read_received) begin // read to clear
        ap_reg[1] <= 1'b0;
    end
end

// ap_idle flip flop
// according to lecture notes, idle and done are set when last data is tranfered, but fir_tb assumed idle set after done deassert
always @(posedge axis_clk or negedge axis_rst_n) begin   
    if (!axis_rst_n) begin
        ap_reg[2] <= 1'b1;
    end else if (ap_reg[0] && data_write_ready) begin
        ap_reg[2] <= 1'b0;
    end else if (ap_reg[1] && tap_read_received) begin 
        ap_reg[2] <= 1'b1;
    end
end

always @(posedge axis_clk or negedge axis_rst_n) begin   
    if (!axis_rst_n) begin
        ap_reg[4] <= 1'b0;
    end else if (ap_reg[0]) begin
        ap_reg[4] <= 1'b1;
    end else if (sm_tready && result_done) begin
        ap_reg[4] <= 1'b1;
    end else if (ss_tvalid) begin 
        ap_reg[4] <= 1'b0;
    end
end	

always @(posedge axis_clk or negedge axis_rst_n) begin   
    if (!axis_rst_n) begin
        ap_reg[5] <= 1'b0;
    end else if (sm_tready) begin
        ap_reg[5] <= 1'b0;
    end else if (result_done) begin 
        ap_reg[5] <= 1'b1;
    end
end

// misc ap_reg flip flop
always @(posedge axis_clk or negedge axis_rst_n) begin   
    if (!axis_rst_n) begin        
        ap_reg[31:3] <= 0;
    end
end

// data_length flip flop
always @(posedge axis_clk or negedge axis_rst_n) begin   
    if (!axis_rst_n) begin
        data_length <= tap_wdata;
    end else if ((&tap_write_ready) && (tap_waddr == 12'h10) && (ap_reg[2])) begin
        data_length <= tap_wdata;
    end
end

// tap_num flip flop
always @(posedge axis_clk or negedge axis_rst_n) begin   
    if (!axis_rst_n) begin
        tap_num <= tap_wdata;
    end else if ((&tap_write_ready) && (tap_waddr == 12'h14) && (ap_reg[2])) begin
        tap_num <= tap_wdata;
    end
end

// data write flag setting
always @(posedge axis_clk or negedge axis_rst_n) begin    
    if (!axis_rst_n) begin
        data_write_ready <= 1'd0;    
    end else if (ss_tvalid) begin
        data_write_ready <= 1'b1;        
    end else if (sm_tready && result_done) begin
        data_write_ready <= 1'b0;
    end
end

// data wdata sampling
always @(posedge axis_clk) begin    
    if (ss_tvalid) begin
        data_wdata <= ss_tdata;        
    end
end

// data wdata sampling
always @(posedge axis_clk or axis_rst_n) begin    
    if (!axis_rst_n) begin
        ss_tready_sent <= 1'b0;
    end else if (sm_tready) begin
        ss_tready_sent <= 1'b0;            
    end else if (data_write_ready) begin
        ss_tready_sent <= 1'b1;        
    end
end


// fsm flip flop
always @(posedge axis_clk) begin    
    mem_ctrl_fsm <= mem_ctrl_fsm_nxt;    
end

// calc_cnt flip flop
always @(posedge axis_clk or negedge axis_rst_n) begin    
    if (!axis_rst_n) begin
        calc_cnt <= 12'd0;
    end else if ((calc_done && (mem_ctrl_fsm == 3'b100) && sm_tready) || ((&tap_write_ready) && (tap_waddr == 12'h000) && ap_reg[2])) begin
        calc_cnt <= 12'b0;
    end else if ((!calc_done) && (first_read || calc_write)) begin
        calc_cnt <= calc_cnt + 12'b1;
    end
end

// first around flip flop
always @(posedge axis_clk or negedge axis_rst_n) begin    
    if (!axis_rst_n) begin
        first_around <= 1'd0;
    end else if ((&tap_write_ready) && (tap_waddr == 12'h000) && ap_reg[2]) begin
        first_around <= 1'b1;
    end else if (calc_cnt == 12'd10) begin
        first_around <= 1'b0;
    end
end

endmodule
