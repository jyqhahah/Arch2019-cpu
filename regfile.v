`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/01 21:46:43
// Design Name: 
// Module Name: regfile
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

module regfile(
    input wire clk,
    input wire rst,
    input wire ready,

    input wire we,
    input wire[`RegAddrBus] waddr,
    input wire[`RegBus] wdata,

    input wire re1,
    input wire[`RegAddrBus] raddr1,
    output reg[`RegBus] rdata1,

    input wire re2,
    input wire[`RegAddrBus] raddr2,
    output reg[`RegBus] rdata2
    );

    reg[`RegBus] regs[0:`RegNum-1];
    
    integer i;
    initial begin
      for (i=0; i < `RegNum; i=i+1) begin
        regs[i] <= `ZeroWord;
      end
    end

    always @ (posedge clk) begin
      if (rst == `RstDisable&&ready) begin
        if ((we == `WriteEnable) && (waddr != `RegNumLog2'h0)) begin
          regs[waddr] <= wdata;
        end
      end
    end

    always @ (*) begin
      if (rst == `RstEnable) begin
        rdata1 <= `ZeroWord;
      end else if(!ready) begin
        rdata1 <= `ZeroWord;
      end else begin
        if(raddr1 == `RegNumLog2'h0) begin
          rdata1 <= `ZeroWord;
        end else if((raddr1 == waddr) && (we == `WriteEnable) && (re1 == `ReadEnable)) begin
          rdata1 <= wdata;
        end else if(re1 == `ReadEnable) begin
          rdata1 <= regs[raddr1];
        end else begin
          rdata1 <= `ZeroWord;
        end
      end
    end

    always @ (*) begin
      if(rst == `RstEnable) begin
        rdata2 <= `ZeroWord;
      end else if(!ready) begin
        rdata2 <= `ZeroWord;
      end else begin
        if(raddr2 == `RegNumLog2'h0) begin
          rdata2 <= `ZeroWord;
        end else if((raddr2 == waddr) && (we == `WriteEnable) && (re2 == `ReadEnable)) begin
          rdata2 <= wdata;
        end else if(re2 == `ReadEnable) begin
          rdata2 <= regs[raddr2];
        end else begin
          rdata2 <= `ZeroWord;
        end
      end
    end
endmodule
