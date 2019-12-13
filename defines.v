`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/11/01 19:49:22
// Design Name: 
// Module Name: defines
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


`define RstEnable          1'b1                 //复位信号有效
`define RstDisable         1'b0                 //复位信号无效
`define ZeroWord           32'h00000000         //32位的数值0
`define WriteEnable        1'b1                 //使能写
`define WriteDisable       1'b0                 //禁止写
`define ReadEnable         1'b1                 //使能读
`define ReadDisable        1'b0                 //禁止读
`define AluOpBus           7:0                  //译码阶段的输出aluop_o的宽度
`define AluSelBus          2:0                  //译码阶段的输出alusel_o的宽度
`define InstValid          1'b0                 //指令有效   
`define InstInvalid        1'b1                 //指令无效
`define True_v             1'b1                 //逻辑 真
`define False_v            1'b0                 //逻辑 假
`define ChipEnable         1'b1                 //芯片使能
`define ChipDisable        1'b0                 //芯片禁止
`define StallBus           6:0                  //暂停标志
`define MemDataBus         7:0                  //每次取出指令的长度



`define EXE_ORI            6'b001101            //指令ori指令码
`define EXE_NOP            6'b000000            



`define EXE_OR_OP          8'b00100101          
`define EXE_NOP_OP         8'b00000000



`define EXE_RES_LOGIC      3'b001
`define EXE_RES_NOP        3'b000


`define InstAddrBus        31:0                 //ROM的地址总线宽度
`define InstBus            31:0                 //ROM的数据总线宽度
`define InstMemNum         131071               //ROM的实际大小为128KB
`define InstMemNumLog2     17                   //ROM实际使用的地址线宽度

`define DataBus            31:0
`define DataWidth          32

`define PcBus              31:0
`define PcWidth            32

`define RegAddrBus         4:0                  //Regfile模块的地址线宽度
`define RegBus             31:0                 //Regfile模块的数据线宽度
`define RegWidth           32                   //通用寄存器的宽度
`define DoubleRegWidth     64                   //两倍的通用寄存器的宽度
`define DoubleRegBus       63:0                 //两倍的通用寄存器的数据线宽度
`define RegNum             32                   //通用寄存器的数量
`define RegNumLog2         5                    //寻址通用寄存器使用的地址位数
`define NOPRegAddr         5'b00000  

`define OptcodeBus   6:0

`define OptcodeNOP    7'b0000000
`define OptcodeLUI    7'b0110111
`define OptcodeAUIPC  7'b0010111
`define OptcodeJAL    7'b1101111
`define OptcodeJALR   7'b1100111
`define OptcodeBranch 7'b1100011
`define OptcodeLoad   7'b0000011
`define OptcodeSave   7'b0100011
`define OptcodeCalcI  7'b0010011
`define OptcodeCalc   7'b0110011


`define ShamtBus     4:0
`define OpBus       5:0



`define OpNOP        6'b000000
`define OpLUI        6'b000001
`define OpAUIPC      6'b000010
`define OpJAL        6'b000011
`define OpJALR       6'b000100
`define OpBEQ        6'b000101
`define OpBNE        6'b000110
`define OpBLT        6'b000111
`define OpBGE        6'b001000 
`define OpBLTU       6'b001001
`define OpBGEU       6'b001010
`define OpLB         6'b001011
`define OpLH         6'b001100
`define OpLW         6'b001101
`define OpLBU        6'b001110
`define OpLHU        6'b001111
`define OpSB         6'b010000
`define OpSH         6'b010001
`define OpSW         6'b010010
`define OpADDI       6'b010011
`define OpSLTI       6'b010100
`define OpSLTIU      6'b010101 
`define OpXORI       6'b010110
`define OpORI        6'b010111
`define OpANDI       6'b011000
`define OpSLLI       6'b011001
`define OpSRLI       6'b011010
`define OpSRAI       6'b011011
`define OpADD        6'b011100
`define OpSUB        6'b011101
`define OpSLL        6'b011110
`define OpSLT        6'b011111
`define OpSLTU       6'b100000
`define OpXOR        6'b100001
`define OpSRL        6'b100010
`define OpSRA        6'b100011
`define OpOR         6'b100100
`define OpAND        6'b100101