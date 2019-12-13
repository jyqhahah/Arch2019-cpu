`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/03 19:07:08
// Design Name: 
// Module Name: ex_mem
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

module ex_mem(
    input wire clk,
    input wire rst,

    input wire[`RegAddrBus] ex_wd,
    input wire ex_wreg,
    input wire[`RegBus] ex_wdata,
    input wire[`OptcodeBus] ex_opcode,
    input wire[`OpBus] ex_op,
    input wire[`InstAddrBus] ex_mem_addr,

    input wire[`StallBus] stall_i,

    output reg[`RegAddrBus] mem_wd,
    output reg mem_wreg,
    output reg[`RegBus] mem_wdata,
    output reg[`OptcodeBus] mem_opcode,
    output reg[`OpBus] mem_op,
    output reg[`InstAddrBus] mem_mem_addr
    );

    always @ (posedge clk) begin
      if(rst == `RstEnable) begin
        mem_wd <= `NOPRegAddr;
        mem_wreg <= `WriteDisable;
        mem_wdata <= `ZeroWord;
        mem_opcode <= `OptcodeNOP;
        mem_op <= `OpNOP;
        mem_mem_addr <= `ZeroWord;
      end else if(stall_i[4] == 1'b0) begin
        mem_wd <= ex_wd;
        mem_wreg <= ex_wreg;
        mem_wdata <= ex_wdata;
        mem_opcode <= ex_opcode;
        mem_op <= ex_op;
        mem_mem_addr <= ex_mem_addr;
      end else if(stall_i[5] == 1'b0) begin
        mem_wd <= `NOPRegAddr;
        mem_wreg <= `WriteDisable;
        mem_wdata <= `ZeroWord;
        mem_opcode <= `OptcodeNOP;
        mem_op <= `OpNOP;
        mem_mem_addr <= `ZeroWord;
      end
    end
endmodule
