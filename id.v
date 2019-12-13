`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/02 21:41:27
// Design Name: 
// Module Name: id
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

module id(
    input wire rst,
    input wire ready,

    input wire[`InstAddrBus] pc_i,
    input wire[`InstBus] inst_i,

    input wire[`RegBus] reg1_data_i,
    input wire[`RegBus] reg2_data_i,

    input wire ex_wreg_i,
    input wire[`RegAddrBus] ex_wd_i,
    input wire[`DataBus] ex_wdata_i,
    input wire[`OptcodeBus] ex_opcode_i,

    input wire mem_wreg_i,
    input wire[`RegAddrBus] mem_wd_i,
    input wire[`DataBus] mem_wdata_i, 

    output reg reg1_read_o,
    output reg reg2_read_o,
    output reg[`RegAddrBus] reg1_addr_o,
    output reg[`RegAddrBus] reg2_addr_o,

    output reg[`RegBus] reg1_data_o,
    output reg[`RegBus] reg2_data_o,
    output reg[`RegAddrBus] wd_o,
    output reg wreg_o,
    output reg[`ShamtBus] shamt_o,
    output reg[`DataBus] imm_o,
    output reg[`OptcodeBus] opcode_o,
    output reg[`OpBus] op_o,

    output reg[`InstAddrBus] jump_addr_o,
    output reg branch_flag_o
    );

    wire[2:0] funct3 = inst_i[14:12];
    wire[6:0] funct7 = inst_i[31:25];
    wire[`OptcodeBus] opcode = inst_i[`OptcodeBus];

    reg[`DataBus] data_out;

    wire[`DataBus] imm_U = {inst_i[31:12],12'b0};
    wire[`DataBus] imm_J = {{12{inst_i[31]}}, inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};
    wire[`DataBus] imm_I = {{21{inst_i[31]}}, inst_i[30:20]}; 
    wire[`DataBus] imm_B = {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
    wire[`DataBus] imm_S = {{21{inst_i[31]}}, inst_i[30:25], inst_i[11:7]};

    always @ (*) begin
      if(rst == `RstEnable) begin
        opcode_o <= `OptcodeNOP;
        op_o <= `OpNOP;
        imm_o <= `ZeroWord;
        data_out <= `ZeroWord;
        shamt_o <= 5'b0;
        reg1_addr_o <= `NOPRegAddr;
        reg2_addr_o <= `NOPRegAddr;
        wd_o <= `NOPRegAddr;
        wreg_o <= `WriteDisable;
        reg1_read_o <= 1'b0;
        reg2_read_o <= 1'b0;
        jump_addr_o <= `ZeroWord;
        branch_flag_o <= `False_v;
      end else begin
        opcode_o <= opcode;
        op_o <= `OpNOP;
        imm_o <= `ZeroWord;
        data_out <= `ZeroWord;
        shamt_o <= 5'b0;
        reg1_addr_o <= inst_i[19:15];
        reg2_addr_o <= inst_i[24:20];
        wd_o <= inst_i[11:7];
        wreg_o <= `WriteDisable;
        reg1_read_o <= 1'b0;
        reg2_read_o <= 1'b0;
        branch_flag_o <= 1'b0;
        jump_addr_o <= `ZeroWord;
        branch_flag_o <= `False_v;
        case(opcode)
          `OptcodeLUI: begin
            op_o <= `OpLUI;
            wreg_o <= `WriteEnable;
            reg1_read_o <= 1'b0;
            reg2_read_o <= 1'b0;
            imm_o <= imm_U;
            data_out <= imm_U;
          end
          `OptcodeAUIPC: begin
            op_o <= `OpAUIPC;
            wreg_o <=  `WriteEnable;
            reg1_read_o <= 1'b0;
            reg2_read_o <= 1'b0;
            imm_o <= imm_U + pc_i;
            data_out <= imm_U + pc_i;
          end
          `OptcodeJAL: begin
            op_o <= `OpJAL;
            wreg_o <= `WriteEnable;
            reg1_read_o <= 1'b0;
            reg2_read_o <= 1'b0;
            imm_o <= pc_i + 32'h4;
            branch_flag_o <= 1'b1;
            jump_addr_o <= imm_J + pc_i;
            data_out <= pc_i + 32'h4;
          end   
          `OptcodeJALR: begin
            op_o <= `OpJALR;
            wreg_o <= `WriteEnable;
            reg1_read_o <= 1'b1;
            reg2_read_o <= 1'b0;
            imm_o <= pc_i + 32'h4;
            branch_flag_o <= 1'b1;
            jump_addr_o <= imm_I + reg1_data_o;
            data_out <= pc_i + 32'h4;
          end  
          `OptcodeBranch: begin
            case(funct3)
              3'b000: begin 
                op_o <= `OpBEQ;
                if (reg1_data_o == reg2_data_o) begin jump_addr_o <= imm_B + pc_i; end else begin jump_addr_o <= pc_i + 32'h4; end
              end
              3'b001: begin 
                op_o <= `OpBNE; 
                if (reg1_data_o != reg2_data_o) begin jump_addr_o <= imm_B + pc_i; end else begin jump_addr_o <= pc_i + 32'h4; end
              end
              3'b100: begin 
                op_o <= `OpBLT;
                if ($signed(reg1_data_o) < $signed(reg2_data_o)) begin jump_addr_o <= imm_B + pc_i; end else begin jump_addr_o <= pc_i + 32'h4; end
              end
              3'b101: begin 
                op_o <= `OpBGE;
                if ($signed(reg1_data_o) >= $signed(reg2_data_o)) begin jump_addr_o <= imm_B + pc_i; end else begin jump_addr_o <= pc_i + 32'h4; end
              end
              3'b110: begin 
                op_o <= `OpBLTU;
                if (reg1_data_o < reg2_data_o) begin jump_addr_o <= imm_B + pc_i; end else begin jump_addr_o <= pc_i + 32'h4; end
              end
              3'b111: begin 
                op_o <= `OpBGEU;
                if (reg1_data_o >= reg2_data_o) begin jump_addr_o <= imm_B + pc_i; end else begin jump_addr_o <= pc_i + 32'h4; end
              end
              default:begin op_o <= `OpNOP; end
            endcase
            branch_flag_o <= 1'b1;
            wd_o <= `ZeroWord;
            wreg_o <= `WriteDisable;
            reg1_read_o <= 1'b1;
            reg2_read_o <= 1'b1;
            imm_o <= imm_B;
            data_out <= `ZeroWord;
          end
          `OptcodeLoad: begin
            case(funct3)
              3'b000: begin op_o <= `OpLB; end
              3'b001: begin op_o <= `OpLH; end
              3'b010: begin op_o <= `OpLW; end
              3'b100: begin op_o <= `OpLBU;end
              3'b101: begin op_o <= `OpLHU;end
              default:begin op_o <= `OpNOP;end
            endcase
            wreg_o <= `WriteEnable;
            reg1_read_o <= 1'b1;
            reg2_read_o <= 1'b0;
            imm_o <= imm_I;
            data_out <= `ZeroWord;
          end  
          `OptcodeSave: begin
            case(funct3)
              3'b000: begin op_o <= `OpSB; end
              3'b001: begin op_o <= `OpSH; end
              3'b010: begin op_o <= `OpSW; end
              default:begin op_o <= `OpNOP; end
            endcase
            wreg_o <= `WriteDisable;
            reg1_read_o <= 1'b1;
            reg2_read_o <= 1'b1;
            imm_o <= imm_S;
            data_out <= `ZeroWord;
          end
          `OptcodeCalcI: begin
            wreg_o <= `WriteEnable;
            reg1_read_o <= 1'b1;
            reg2_read_o <= 1'b0; 
            case(funct3)
              3'b000: begin 
                op_o <= `OpADDI; 
                imm_o <= imm_I;
                data_out <= imm_I;
              end
              3'b001: begin
                if(funct7 == 7'b0000000) begin
                  op_o <= `OpSLLI;
                  shamt_o <= inst_i[24:20];
                  data_out <= {27'b0, inst_i[24:20]};
                end else begin
                  op_o <= `OpNOP;
                end
              end
              3'b010: begin
                op_o <= `OpSLTI;
                imm_o <= imm_I;
                data_out <= imm_I;
              end
              3'b011: begin
                op_o <= `OpSLTIU;
                imm_o <= imm_I;
                data_out <= imm_I;
              end
              3'b100: begin
                op_o <= `OpXORI;
                imm_o <= imm_I;
                data_out <= imm_I;
              end
              3'b101: begin
                case(funct7)
                  7'b0000000: begin 
                    op_o <= `OpSRLI;
                    shamt_o <= inst_i[24:20];
                    data_out <= {27'b0, inst_i[24:20]};
                  end
                  7'b0100000: begin
                    op_o <= `OpSRAI;
                    shamt_o <= inst_i[24:20];
                    data_out <= {27'b0, inst_i[24:20]};
                  end
                  default: begin
                    op_o <= `OpNOP;
                  end
                endcase
              end
              3'b110: begin
                op_o <= `OpORI;
                imm_o <= imm_I;
                data_out <= imm_I;
              end
              3'b111: begin
                op_o <= `OpANDI;
                imm_o <= imm_I;
                data_out <= imm_I;
              end
              default: begin
                op_o <= `OpNOP;
              end
            endcase
          end
          `OptcodeCalc: begin
            data_out <= `ZeroWord;
            wreg_o <= `WriteEnable;
            reg1_read_o <= 1'b1;
            reg2_read_o <= 1'b1;
            case(funct3)
              3'b000: begin 
                case(funct7)
                  7'b0000000: begin op_o <= `OpADD; end
                  7'b0100000: begin op_o <= `OpSUB; end
                  default: begin op_o <= `OpNOP; end
                endcase
              end
              3'b001: begin
                if(funct7 == 7'b0000000) begin
                  op_o <= `OpSLL;
                end else begin
                  op_o <= `OpNOP;
                end
              end
              3'b010: begin
                if(funct7 == 7'b0000000) begin
                  op_o <= `OpSLT;
                end else begin
                  op_o <= `OpNOP;
                end
              end
              3'b011: begin
                if(funct7 == 7'b0000000) begin
                  op_o <= `OpSLTU;
                end else begin
                  op_o <= `OpNOP;
                end
              end
              3'b100: begin
                if(funct7 == 7'b0000000) begin
                  op_o <= `OpXOR;
                end else begin
                  op_o <= `OpNOP;
                end
              end
              3'b110: begin
                if(funct7 == 7'b0000000) begin
                  op_o <= `OpOR;
                end else begin
                  op_o <= `OpNOP;
                end
              end
              3'b101: begin 
                case(funct7)
                  7'b0000000: begin op_o <= `OpSRL; end
                  7'b0100000: begin op_o <= `OpSRA; end
                  default: begin op_o <= `OpNOP; end
                endcase
              end
              3'b111: begin
                if(funct7 == 7'b0000000) begin
                  op_o <= `OpAND;
                end else begin
                  op_o <= `OpNOP;
                end
              end
            endcase      
          end
          default: begin
            op_o <= `OpNOP;
          end
        endcase
      end
    end
  
    always @ (*) begin
	  	if (rst == `RstEnable) begin
	  		reg1_data_o <= `ZeroWord;
	  	end else if (ready) begin
        if (reg1_read_o == `True_v && ex_wreg_i == `True_v && ex_wd_i != `ZeroWord && ex_wd_i == reg1_addr_o) begin
	  	  	reg1_data_o <= ex_wdata_i;
	  	  end else if (reg1_read_o == `True_v && mem_wreg_i == `True_v && mem_wd_i != `ZeroWord && mem_wd_i == reg1_addr_o) begin
	  	    reg1_data_o <= mem_wdata_i;
	  	  end else if (reg1_read_o == `True_v) begin
          reg1_data_o <= reg1_data_i;
        end else if (reg1_read_o == `False_v) begin
          reg1_data_o <= data_out;
        end else begin
          reg1_data_o <= `ZeroWord;
        end
      end else begin 
        reg1_data_o <= `ZeroWord;
      end
	  end
	  
	  always @ (*) begin
	     if (rst == `RstEnable) begin
	  		reg2_data_o <= `ZeroWord;
	  	end else if (ready) begin
        if (reg2_read_o == `True_v && ex_wreg_i == `True_v && ex_wd_i != `ZeroWord && ex_wd_i == reg2_addr_o) begin
	  	  	reg2_data_o <= ex_wdata_i;
	  	  end else if (reg2_read_o == `True_v && mem_wreg_i == `True_v && mem_wd_i != `ZeroWord && mem_wd_i == reg2_addr_o) begin
	  	    reg2_data_o <= mem_wdata_i;
	  	  end else if(reg2_read_o == `True_v) begin
          reg2_data_o <= reg2_data_i;
        end else if(reg2_read_o == `False_v) begin
          reg2_data_o <= data_out;
        end else begin
          reg2_data_o <= `ZeroWord;
        end
      end else begin 
        reg2_data_o <= `ZeroWord;
      end
    end

endmodule
