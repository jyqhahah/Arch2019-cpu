`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/01 21:37:42
// Design Name: 
// Module Name: if_id
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

module if_id(
    input wire      clk,
    input wire      rst,

    input wire[`InstAddrBus]    if_pc,
    input wire[`InstBus]        if_inst,

    input wire[`StallBus]       stall_i,

    output reg[`InstAddrBus]    id_pc,
    output reg[`InstBus]        id_inst
    );

    always @ (posedge clk) begin
      if (rst == `RstEnable) begin
        id_pc <= `ZeroWord;
        id_inst <= `ZeroWord;
      end else if (stall_i[2] == 1'b0) begin
        id_pc <= if_pc;
        id_inst <= if_inst;
      end else if (stall_i[3] == 1'b0) begin
        id_pc <= `ZeroWord;
        id_inst <= `ZeroWord;
      end
    end
endmodule
