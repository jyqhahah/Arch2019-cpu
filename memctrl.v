`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/20 20:44:13
// Design Name: 
// Module Name: memctrl
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

module memctrl(
    input wire    rst,
    input wire    ready,

    input wire    if_mem_req_i,
    input wire[`InstAddrBus]    if_mem_addr_i,

    input wire    mem_mem_req_i,
    input wire[`InstAddrBus]    mem_mem_addr_i,
    input wire[`MemDataBus]     mem_data_i,
    input wire mem_we_i,

    output reg[`InstAddrBus]    mem_addr_o,
    output reg[`MemDataBus]     mem_data_o,
    output reg if_stall_o,
    output reg mem_stall_o,
    output reg we_o
    );
    always @ (*) begin
      if(rst == `RstEnable) begin
        mem_addr_o <= `ZeroWord;
        mem_data_o <= 8'h00;
        if_stall_o <= `False_v;
        mem_stall_o <= `False_v;
        we_o <= `False_v;
      end else if(!ready) begin
        mem_addr_o <= `ZeroWord;
        mem_data_o <= 8'h00;
        if_stall_o <= `False_v;
        mem_stall_o <= `False_v;
        we_o <= `False_v;
      end else if(mem_mem_req_i) begin 
        mem_addr_o <= mem_mem_addr_i;
        mem_data_o <= mem_data_i;
        if_stall_o <= `False_v;
        mem_stall_o <= `True_v;
        we_o <= mem_we_i;
      end else if(if_mem_req_i) begin
        mem_addr_o <= if_mem_addr_i;
        mem_data_o <= 8'h00;
        if_stall_o <= `True_v;
        mem_stall_o <= `False_v;
        we_o <= `False_v;
      end else begin
        mem_addr_o <= `ZeroWord;
        mem_data_o <= 8'h00;
        if_stall_o <= `False_v;
        mem_stall_o <= `False_v;
        we_o <= `False_v;
      end
    end
endmodule
