`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/20 21:06:27
// Design Name: 
// Module Name: If
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

module If(
    input wire clk,
    input wire rst,

    input wire[`StallBus] stall_i,
    input wire[`MemDataBus] data_i,

    input wire[`InstAddrBus] jump_addr_i,
    input wire branch_flag_i,

    input wire cache_hit_i,
    input wire[`InstAddrBus] cache_inst_i,

    output reg[`InstAddrBus] pc_o,
    output reg[`InstBus] inst_o,
    output reg if_mem_req_o,
    output reg branch_req_o,
    output reg[`InstAddrBus] mem_addr_o,//,
    //output reg mem_we_o

    output reg cache_we_o,
    output reg[`InstBus] cache_write_inst_o,
    output reg[`InstAddrBus] cache_write_addr_o,
    output reg[`InstAddrBus] cache_read_addr_o
    );

    reg[`MemDataBus] data_in1;
    reg[`MemDataBus] data_in2;
    reg[`MemDataBus] data_in3;
    reg[3:0] cnt;

    always @ (posedge clk) begin
      if (rst == `RstEnable) begin
        cnt      <= 4'b0000;
        data_in1 <= 8'h00;
        data_in2 <= 8'h00;
        data_in3 <= 8'h00;
        pc_o     <= `ZeroWord;
        inst_o   <= `ZeroWord;
        if_mem_req_o <= `False_v;
        branch_req_o <= `False_v;
        mem_addr_o <= `ZeroWord;
        //mem_we_o <= `False_v;
        cache_we_o <= `False_v;
        cache_write_inst_o <= `ZeroWord;
        cache_write_addr_o <= `ZeroWord;
        cache_read_addr_o <= `ZeroWord;
      end else if(branch_flag_i == `True_v && stall_i[2] == 1'b0) begin
        cnt <= 4'b0000;
        pc_o <= jump_addr_i;
        inst_o <= `ZeroWord;
        if_mem_req_o <= `False_v;
        branch_req_o <= `False_v;
        mem_addr_o <= `ZeroWord;
      end else begin
        case (cnt)
          4'b0000: begin
            if(stall_i[2] == 1'b0 && stall_i[3] == 1'b0) begin
              if_mem_req_o <= `True_v;
              mem_addr_o <= pc_o;
              cache_read_addr_o <= pc_o;
              cnt <= 4'b0010;
            end
            cache_we_o <= `False_v;
          end
          4'b0010: begin
            if(cache_hit_i == `False_v) begin
              if(stall_i[1] == 1'b0) begin
                mem_addr_o <= pc_o[17:0] + 17'h1;
                cnt <= 4'b0001;
              end else begin
                cnt <= 4'b0100;
              end
            end else begin
              if(stall_i[1] == 1'b0) begin
                inst_o <= cache_inst_i;
                if_mem_req_o <= 1'b0;
                if(cache_inst_i[6] == 1'b0) begin
                  branch_req_o <= `False_v;
                  pc_o <= pc_o[17:0] + 17'h4;
                end else begin
                  branch_req_o <= `True_v;
                end
                cnt <= 4'b0000; 
              end
            end
          end
          4'b0001: begin
            mem_addr_o <= pc_o[17:0] + 17'h2;
            data_in1 <= data_i;
            cnt <= 4'b0011;  
          end
          4'b0011: begin
            if(stall_i[1] == 1'b0) begin
              mem_addr_o <= pc_o[17:0] + 17'h3;
              data_in2 <= data_i;
              cnt <= 4'b0111;
            end else begin
              cnt <= 4'b0110;
            end
          end
          4'b0111: begin
            if(stall_i[1] == 1'b0) begin
              data_in3 <= data_i;
              cnt <= 4'b1111; 
            end else begin
              cnt <= 4'b1001;
            end
          end
          4'b0100: begin 
            if(stall_i[1] == 1'b0) begin
              mem_addr_o <= pc_o[17:0];
              cnt <= 4'b0101;
            end
          end
          4'b0101: begin
            mem_addr_o <= pc_o[17:0] + 17'h1;
            cnt <= 4'b0001;
          end
          4'b0110: begin
            if(stall_i[1] == 1'b0) begin
              mem_addr_o <= pc_o[17:0] + 17'h1;
              cnt <= 4'b1000; 
            end
          end
          4'b1000: begin
            mem_addr_o <= pc_o[17:0] + 17'h2;
            cnt <= 4'b0011;
          end
          4'b1001: begin
            if(stall_i[1] == 1'b0) begin
              mem_addr_o <= pc_o[17:0] + 17'h2;
              cnt <= 4'b1010;
            end
          end
          4'b1010: begin
            mem_addr_o <= pc_o[17:0] + 17'h3;
            cnt <= 4'b0111;
          end
          4'b1111: begin
            inst_o <= {data_i, data_in3, data_in2, data_in1};
            if_mem_req_o <= `False_v;
            cache_we_o <= `True_v;
            cache_write_inst_o <= {data_i, data_in3, data_in2, data_in1};
            cache_write_addr_o <= cache_read_addr_o;
            if(!data_in1[6]) begin
              branch_req_o <= `False_v;
              pc_o <= pc_o[17:0] + 17'h4;
            end else begin
              branch_req_o <= `True_v;
            end
            cnt <= 4'b0000;
          end
        endcase
      end
    end

endmodule
