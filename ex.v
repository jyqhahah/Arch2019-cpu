`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/03 17:54:17
// Design Name: 
// Module Name: ex
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

module ex(
    input wire rst,
    input wire[`StallBus] stall_i,
  
    input wire[`RegBus] reg1_data_i,
    input wire[`RegBus] reg2_data_i,
    input wire[`RegAddrBus] wd_i,
    input wire wreg_i,
    input wire[`OptcodeBus] opcode_i,
    input wire[`OpBus] op_i,
    input wire[`DataBus] imm_i,
    input wire[`ShamtBus]shamt_i,

    output reg[`RegAddrBus] wd_o,
    output reg wreg_o,
    //output reg[`RegBus] wdata_o,
    output reg[`RegBus] data_out,
    output reg[`OptcodeBus] opcode_o,
    output reg[`OpBus] op_o,
    output reg[`InstAddrBus] mem_addr_o
    );

    reg[`RegBus] data_out;

    always @ (*) begin
      if(rst ==`RstEnable) begin
        data_out <= `ZeroWord;
        wd_o <= `ZeroWord;
        wreg_o <= `WriteDisable;
        opcode_o <= `OptcodeNOP;
        op_o <= `OpNOP;
        mem_addr_o <= `ZeroWord;
      end else begin
        data_out <= `ZeroWord;
        wd_o <= wd_i;
        wreg_o <= wreg_i;
        opcode_o <= opcode_i;
        op_o <= op_i;
        mem_addr_o <= `ZeroWord;
        case (opcode_i)
            `OptcodeLUI: begin data_out <= imm_i; end   
            `OptcodeAUIPC: begin data_out <= imm_i; end
            `OptcodeJAL: begin data_out <= imm_i; end
            `OptcodeJALR: begin data_out <= imm_i; end
            `OptcodeBranch: begin end
            `OptcodeLoad: begin mem_addr_o <= reg1_data_i + imm_i; end 
            `OptcodeSave: begin mem_addr_o <= reg1_data_i + imm_i; data_out <= reg2_data_i; end   
            `OptcodeCalcI: begin 
              case(op_o)
                `OpADDI: begin data_out <= $signed(reg1_data_i) + $signed(imm_i); end 
                `OpSLTI: begin data_out <= ($signed(reg1_data_i)<$signed(imm_i)); end 
                `OpSLTIU: begin data_out <= reg1_data_i<imm_i; end
                `OpXORI: begin data_out <= reg1_data_i^imm_i; end
                `OpORI: begin data_out <= reg1_data_i|imm_i; end
                `OpANDI: begin data_out <= reg1_data_i&imm_i; end
                `OpSLLI: begin data_out <= reg1_data_i<<shamt_i; end
                `OpSRLI: begin data_out <= reg1_data_i>>shamt_i; end
                `OpSRAI: begin data_out <= ($signed(reg1_data_i)>>>shamt_i); end
              endcase
            end
            `OptcodeCalc: begin
              case(op_o)
                `OpADD: begin data_out <= $signed(reg1_data_i) + $signed(reg2_data_i); end 
                `OpSUB: begin data_out <= $signed(reg1_data_i) - $signed(reg2_data_i); end
                `OpSLL: begin data_out <= reg1_data_i << reg2_data_i[4:0]; end
                `OpSLT: begin data_out <= $signed(reg1_data_i) < $signed(reg2_data_i); end
                `OpSLTU: begin data_out <= reg1_data_i < reg2_data_i; end
                `OpXOR: begin data_out <= reg1_data_i ^ reg2_data_i; end
                `OpSRL: begin data_out <= reg1_data_i >> reg2_data_i[4:0]; end
                `OpSRA: begin data_out <= $signed(reg1_data_i)>>>reg2_data_i[4:0]; end
                `OpOR: begin data_out <= reg1_data_i | reg2_data_i; end  
                `OpAND: begin data_out <= reg1_data_i & reg2_data_i; end 
              endcase
            end   
            default: begin
              data_out <= `ZeroWord;
            end
        endcase
      end
    end
  /*
  always @ (*) begin
    
    wdata_o <= data_out;
    
  end*/
endmodule
