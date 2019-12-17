`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/25 21:48:48
// Design Name: 
// Module Name: cache
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
`include "defines.v"

module cache(
    input wire rst,
    input wire clk,
    input wire ready,

    input wire we_i,
    input wire[`InstBus] write_inst_i,
    input wire[`InstAddrBus] write_addr_i,
    input wire[`InstAddrBus] read_addr_i,

    output reg cache_hit_o,
    output reg[`InstBus] cache_inst_o
    );

    (* ram_style = "registers" *) reg[6:0] cache_tag[255:0];
    (* ram_style = "registers" *) reg[31:0] cache_data[255:0];
    (* ram_style = "registers" *) reg cache_valid[255:0];

    wire[7:0] rindex_i; 
    wire[6:0] rtag_i;
    wire[7:0] windex_i;
    wire[6:0] wtag_i;
    
    assign rindex_i = read_addr_i[9:2];
    assign rtag_i = read_addr_i[16:10];
    assign windex_i = write_addr_i[9:2];
    assign wtag_i = write_addr_i[16:10];

    integer i;
    always @ (posedge clk) begin
      if(rst == `RstEnable) begin
        for (i=0; i<256;i=i+1) 
          cache_valid[i] <= 1'b0; 
      end else if(rst == `RstDisable && we_i == `True_v) begin
        cache_valid[windex_i] <= `True_v;
        cache_data[windex_i] <= write_inst_i;
        cache_tag[windex_i] <= write_addr_i[16:10];
      end
    end

    always @ (*) begin
      if(rst == `RstEnable || ready == `False_v) begin
        cache_hit_o <= `False_v;
        cache_inst_o <= `ZeroWord;
      end else if(we_i == `True_v && rindex_i == windex_i) begin
        cache_hit_o <= `True_v;
        cache_inst_o <= write_inst_i;
      end else if(cache_valid[rindex_i] == `True_v && cache_tag[rindex_i] == rtag_i) begin
        cache_hit_o <= `True_v;
        cache_inst_o <= cache_data[rindex_i];
      end else begin
        cache_hit_o <= `False_v;
        cache_inst_o <= `ZeroWord;
      end
    end

endmodule
