`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/03 19:13:28
// Design Name: 
// Module Name: mem
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

module mem(
    input wire clk,
    input wire rst,

    input wire[`OptcodeBus] opcode_i,
    input wire[`OpBus] op_i,
    input wire[`InstAddrBus] mem_addr_i,
    input wire[`MemDataBus] mem_data_i,
    input wire[`RegAddrBus] wd_i,
    input wire wreg_i,
    input wire[`RegBus] wdata_i,

    output reg[`RegAddrBus] wd_o,
    output reg wreg_o,
    output reg[`RegBus] wdata_o,
    output reg[`InstAddrBus] mem_addr_o,
    output reg[`MemDataBus] mem_data_o,
    output reg mem_we_o,
    output reg mem_mem_req_o
    );

    reg period_end;
    reg[`MemDataBus] data_1;
    reg[`MemDataBus] data_2;
    reg[`MemDataBus] data_3;
    reg[3:0] cnt;

    reg[`DataBus] data_out;

    always @ (*) begin 
      if(rst == `RstEnable) begin
        mem_mem_req_o <= `False_v;
      end else begin
        if(period_end == `True_v) begin
          mem_mem_req_o <= `False_v;
        end else if(opcode_i == `OptcodeLoad || opcode_i == `OptcodeSave) begin
          mem_mem_req_o <= `True_v;
        end else begin
          mem_mem_req_o <= `False_v;
        end
      end
    end

    always @ (posedge clk) begin
      if(rst == `RstEnable) begin
        mem_addr_o <= `ZeroWord;
        mem_data_o <= 8'h00;
        mem_we_o <= `WriteDisable;
        period_end <= `False_v;
        data_1 <= 8'h00;
        data_2 <= 8'h00;
        data_3 <= 8'h00;
        cnt <= 4'b0000;
        data_out <= `ZeroWord;
      end else if(mem_mem_req_o) begin
        case(cnt)
          4'b0000: begin
            mem_addr_o <= mem_addr_i;
            case(opcode_i)
              `OptcodeLoad: begin
                mem_we_o <= `False_v;
              end
              `OptcodeSave: begin
                mem_data_o <= wdata_i[7:0];
                mem_we_o <= `True_v;
              end
            endcase
            period_end <= `False_v;
            cnt <= 4'b0010;
            mem_addr_o <= mem_addr_i;
          end
          4'b0010: begin
            case(opcode_i)
              `OptcodeLoad: begin
                if(op_i == `OpLH || op_i == `OpLHU || op_i == `OpLW) begin
                  mem_addr_o <= mem_addr_i + 1;
                end
                cnt <= 4'b0001;
              end
              `OptcodeSave: begin
                if(op_i == `OpSB) begin
                  mem_addr_o <= `ZeroWord;
                  mem_we_o <= `False_v;
                  period_end <= `True_v;
                  cnt <= 4'b0000;
                end else if(op_i == `OpSH || op_i == `OpSW) begin
                  mem_addr_o <= mem_addr_i + 1;
                  mem_data_o <= wdata_i[15:8];
                  period_end <= `False_v;
                  cnt <= 4'b0001;
                end
              end
              default: begin
                cnt <= 4'b0001;
              end
            endcase
          end
          4'b0001: begin
            case(opcode_i) 
              `OptcodeLoad: begin
                case(op_i)
                  `OpLB: begin
                    mem_addr_o <= `ZeroWord;
                    data_out <= {{24{mem_data_i[7]}}, mem_data_i};
                    period_end <= `True_v;
                    cnt <= 4'b0000;
                  end
                  `OpLBU: begin
                    mem_addr_o <= `ZeroWord;
                    data_out <= {24'b0, mem_data_i};
                    period_end <= `True_v;
                    cnt <= 4'b0000;
                  end
                  `OpLH: begin
                    data_1 <= mem_data_i;
                    cnt <= 4'b0011;
                  end
                  `OpLHU: begin
                    data_1 <= mem_data_i;
                    cnt <= 4'b0011;
                  end
                  `OpLW: begin
                    mem_addr_o <= mem_addr_i + 2;
                    data_1 <= mem_data_i;
                    cnt <= 4'b0011;
                  end
                endcase
              end
              `OptcodeSave: begin
                case(op_i)
                  `OpSH: begin
                    mem_we_o <= `False_v;
                    mem_addr_o <= `ZeroWord;
                    period_end <= `True_v;
                    cnt <= 4'b0000;
                  end
                  `OpSW: begin
                    mem_data_o <= wdata_i[23:16];
                    mem_addr_o <= mem_addr_i + 2;
                    cnt <= 4'b0011;
                  end
                endcase
              end
            endcase
          end
          4'b0011: begin
            case(opcode_i) 
              `OptcodeLoad: begin
                case(op_i) 
                  `OpLH: begin
                    mem_addr_o <= `ZeroWord;
                    data_out <= {{16{mem_data_i[7]}}, mem_data_i, data_1};
                    period_end <= `True_v;
                    cnt <= 4'b0000;
                  end
                  `OpLHU: begin
                    mem_addr_o <= `ZeroWord;
                    data_out <= {16'b0, mem_data_i, data_1};
                    period_end <= `True_v;
                    cnt <= 4'b0000;
                  end
                  `OpLW: begin
                    mem_addr_o <= mem_addr_i + 3;
                    data_2 <= mem_data_i;
                    cnt <= 4'b0100;
                  end
                endcase
              end
              `OptcodeSave: begin
                case(op_i) 
                  `OpSW: begin
                    mem_data_o <= wdata_i[31:24];
                    mem_addr_o <= mem_addr_i + 3;
                    cnt <= 4'b0100;
                  end
                endcase
              end
              default: begin
                cnt <= 4'b0100;
              end
            endcase
          end
          4'b0100: begin
            case(opcode_i)
              `OptcodeLoad: begin
                if(op_i == `OpLW) begin
                  data_3 <= mem_data_i;
                  cnt <= 4'b0111;
                end
              end
              `OptcodeSave: begin
                if(op_i == `OpSW) begin
                  mem_addr_o <= `ZeroWord;
                  mem_we_o <= `False_v;
                  period_end <= `True_v;
                  cnt <= 4'b0000;
                end
              end
              default: begin
                cnt <= 4'b0000;
              end
            endcase
          end
          4'b0111: begin
            data_out <= {mem_data_i, data_3, data_2, data_1};
            mem_addr_o <= `ZeroWord;
            period_end <= `True_v;
            cnt <= 4'b0000;
          end
        endcase
      end else begin
        period_end <= `False_v;
      end
    end

    always @ (*) begin
      if(rst == `RstEnable) begin
        wd_o <= `NOPRegAddr;
        wdata_o <= `ZeroWord;
        wreg_o <= `WriteDisable;
      end else begin
        wd_o <= wd_i;
        wreg_o <= wreg_i;
        if(opcode_i == `OptcodeLoad) begin
          wdata_o <= data_out;
        end else begin
          wdata_o <= wdata_i;
        end
      end
    end
endmodule
