`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/03 17:19:38
// Design Name: 
// Module Name: id_ex
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


module id_ex(
    input wire clk,
    input wire rst,

    input wire[`RegBus] id_reg1_data,
    input wire[`RegBus] id_reg2_data,
    input wire[`RegAddrBus] id_wd,
    input wire id_wreg,
    input wire[`OptcodeBus] id_opcode,
    input wire[`OpBus] id_op,
    input wire[`DataBus] id_imm,
    input wire[`ShamtBus] id_shamt,

    input wire[`StallBus] stall_i,

    output reg[`RegBus] ex_reg1_data,
    output reg[`RegBus] ex_reg2_data,
    output reg[`RegAddrBus] ex_wd,
    output reg ex_wreg,
    output reg[`OptcodeBus] ex_opcode,
    output reg[`OpBus] ex_op,
    output reg[`DataBus] ex_imm,
    output reg[`ShamtBus] ex_shamt
    );

    always @ (posedge clk) begin
      if (rst == `RstEnable) begin
        ex_reg1_data <= `ZeroWord;
        ex_reg2_data <= `ZeroWord;
        ex_wd <= `NOPRegAddr;
        ex_wreg <= `WriteDisable;
        ex_opcode <= `OptcodeNOP;
        ex_op <= `OpNOP;
        ex_imm <= `ZeroWord;
        ex_shamt <= 5'b00000;
      end else if(stall_i[3] == 1'b0) begin
        ex_reg1_data <= id_reg1_data;
        ex_reg2_data <= id_reg2_data;
        ex_wd <= id_wd;
        ex_wreg <= id_wreg;
        ex_opcode <= id_opcode;
        ex_op <= id_op;
        ex_imm <= id_imm;
        ex_shamt <= id_shamt;
      end else if(stall_i[4] == 1'b0) begin
        ex_reg1_data <= `ZeroWord;
        ex_reg2_data <= `ZeroWord;
        ex_wd <= `NOPRegAddr;
        ex_wreg <= `WriteDisable;
        ex_opcode <= `OptcodeNOP;
        ex_op <= `OpNOP;
        ex_imm <= `ZeroWord;
        ex_shamt <= 5'b00000;
      end
    end
endmodule
