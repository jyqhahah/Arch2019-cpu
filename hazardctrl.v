`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/21 21:39:10
// Design Name: 
// Module Name: hazardctrl
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


module hazardctrl(
    input wire        rst,
    input wire        ready,

    input wire        if_stall_i,
    input wire        mem_stall_i,
    input wire        branch_stall_i,
    
    output reg[`StallBus] stall_o
    );
    always @ (*) begin
      if(rst == `RstEnable) begin
        stall_o <= 7'b0000000;
      end else if(ready == `False_v) begin
        stall_o <= 7'b1111100;
      end else if(mem_stall_i == `True_v) begin
        stall_o <= 7'b0111111;
      end else if(branch_stall_i == `True_v) begin
        stall_o <= 7'b0001000;
      end else if(if_stall_i == `True_v) begin
        stall_o <= 7'b0000100;
      end else begin
        stall_o <= 7'b0000000;
      end
    end
endmodule
