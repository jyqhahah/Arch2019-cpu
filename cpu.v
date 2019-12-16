// RISCV32I CPU top module
// port modification allowed for debugging purposes
`include "defines.v"

module cpu(
    input  wire                 clk_in,			// system clock signal
    input  wire                 rst_in,			// reset signal
	  input  wire					        rdy_in,			// ready signal, pause cpu when low

    input  wire [ 7:0]          mem_din,		// data input bus
    output wire [ 7:0]          mem_dout,		// data output bus
    output wire [31:0]          mem_a,			// address bus (only 17:0 is used)
    output wire                 mem_wr,			// write/read signal (1 for write)

	output wire [31:0]			dbgreg_dout		// cpu register output (debugging demo)
);

// implementation goes here

// Specifications:
// - Pause cpu(freeze pc, registers, etc.) when rdy_in is low
// - Memory read takes 2 cycles(wait till next cycle), write takes 1 cycle(no need to wait)
// - Memory is of size 128KB, with valid address ranging from 0x0 to 0x20000
// - I/O port is mapped to address higher than 0x30000 (mem_a[17:16]==2'b11)
// - 0x30000 read: read a byte from input
// - 0x30000 write: write a byte to output (write 0x00 is ignored)
// - 0x30004 read: read clocks passed since cpu starts (in dword, 4 bytes)
// - 0x30004 write: indicates program stop (will output '\0' through uart tx)


//pc_reg to if
wire[`InstAddrBus] inst_pc;

//  if to if_id
wire[`InstAddrBus] if_pc_o;
wire[`InstBus] if_inst_o;

//  if_id to id
wire[`InstAddrBus] id_pc_i;
wire[`InstBus] id_inst_i;

//  id to id_ex
wire[`RegBus] id_reg1_data_o;
wire[`RegBus] id_reg2_data_o;
wire[`RegAddrBus] id_wd_o;
wire id_wreg_o;
wire[`OptcodeBus] id_opcode_o;
wire[`OpBus] id_op_o;
wire[`DataBus] id_imm_o;
wire[`ShamtBus] id_shamt_o;

//branch
wire[`InstAddrBus] jump_addr;
wire branch_flag;

//  id_ex to ex
wire[`RegBus] ex_reg1_data_i;
wire[`RegBus] ex_reg2_data_i;
wire[`RegAddrBus] ex_wd_i;
wire ex_wreg_i;
wire[`OptcodeBus] ex_opcode_i;
wire[`OpBus] ex_op_i;
wire[`DataBus] ex_imm_i;
wire[`ShamtBus] ex_shamt_i;

//  ex to ex_mem
wire[`RegAddrBus] ex_wd_o;
wire ex_wreg_o;
wire[`RegBus] ex_wdata_o;
wire[`OptcodeBus] ex_opcode_o;
wire[`OpBus] ex_op_o;
wire[`InstAddrBus] ex_mem_addr_o;

//  ex_mem to mem
wire[`RegAddrBus] mem_wd_i;
wire mem_wreg_i;
wire[`RegBus] mem_wdata_i;
wire[`OptcodeBus] mem_opcode_i;
wire[`OpBus] mem_op_i;
wire[`InstAddrBus] mem_mem_addr_i;

//  mem to mem_wb
wire[`RegAddrBus] mem_wd_o;
wire mem_wreg_o;
wire[`RegBus] mem_wdata_o;

// mem_wb to regfile
wire[`RegAddrBus] wb_wd_i;
wire wb_wreg_i;
wire[`RegBus] wb_wdata_i;

//regfile to id
wire[`DataBus] reg1_data;
wire[`DataBus] reg2_data;

//id to regfile
wire reg1_read;
wire reg2_read;
wire[`RegAddrBus] reg1_addr;
wire[`RegAddrBus] reg2_addr;

//hazardctrl
wire[`StallBus] stall_flag;
wire if_mem_req;
wire branch_stall;
wire mem_mem_req;
wire if_stall;
wire mem_stall;

//memctrl
wire[`InstAddrBus] if_mem_addr;
wire[`InstAddrBus] mem_mem_addr;
wire[`MemDataBus] mem_data;
//wire if_we;
wire mem_we;

// cache
wire cache_we;
wire[`InstAddrBus] cache_write_addr;
wire[`InstBus] cache_write_inst;
wire[`InstAddrBus] cache_read_addr;
wire cache_hit;
wire[`InstBus] cache_inst;

If if0(
  .clk(clk_in),
  .rst(rst_in),
  .data_i(mem_din),
  .stall_i(stall_flag),
  .jump_addr_i(jump_addr),
  .branch_flag_i(branch_flag),
  .cache_hit_i(cache_hit),
  .cache_inst_i(cache_inst),
  .pc_o(if_pc_o),
  .inst_o(if_inst_o),
  .if_mem_req_o(if_mem_req),
  .branch_req_o(branch_stall),
  .mem_addr_o(if_mem_addr),
  .cache_we_o(cache_we),
  .cache_write_inst_o(cache_write_inst),
  .cache_write_addr_o(cache_write_addr),
  .cache_read_addr_o(cache_read_addr)
);

if_id if_id0(
  .clk(clk_in),
  .rst(rst_in),
  .if_pc(if_pc_o),
  .if_inst(if_inst_o),
  .stall_i(stall_flag),
  .id_pc(id_pc_i),
  .id_inst(id_inst_i)
);

id id0(
  .rst(rst_in),
  .ready(rdy_in),
  .pc_i(id_pc_i),
  .inst_i(id_inst_i),
  .reg1_data_i(reg1_data),
  .reg2_data_i(reg2_data),
  .ex_wreg_i(ex_wreg_o),
  .ex_wd_i(ex_wd_o),
  .ex_wdata_i(ex_wdata_o),
  .ex_opcode_i(ex_opcode_o),
  .mem_wreg_i(mem_wreg_o),
  .mem_wd_i(mem_wd_o),
  .mem_wdata_i(mem_wdata_o),
  .reg1_read_o(reg1_read),
  .reg2_read_o(reg2_read),
  .reg1_addr_o(reg1_addr),
  .reg2_addr_o(reg2_addr),
  .reg1_data_o(id_reg1_data_o),
  .reg2_data_o(id_reg2_data_o),
  .wd_o(id_wd_o),
  .wreg_o(id_wreg_o),
  .shamt_o(id_shamt_o),
  .imm_o(id_imm_o),
  .opcode_o(id_opcode_o),
  .op_o(id_op_o),
  .jump_addr_o(jump_addr),
  .branch_flag_o(branch_flag)
);

id_ex id_ex0(
  .clk(clk_in),
  .rst(rst_in),
  .id_reg1_data(id_reg1_data_o),
  .id_reg2_data(id_reg2_data_o),
  .id_wd(id_wd_o),
  .id_wreg(id_wreg_o),
  .id_opcode(id_opcode_o),
  .id_op(id_op_o),
  .id_imm(id_imm_o),
  .id_shamt(id_shamt_o),
  .stall_i(stall_flag),
  .ex_reg1_data(ex_reg1_data_i),
  .ex_reg2_data(ex_reg2_data_i),
  .ex_wd(ex_wd_i),
  .ex_wreg(ex_wreg_i),
  .ex_opcode(ex_opcode_i),
  .ex_op(ex_op_i),
  .ex_imm(ex_imm_i),
  .ex_shamt(ex_shamt_i)
);

ex ex0(
  .rst(rst_in),
  .stall_i(stall_flag),
  .reg1_data_i(ex_reg1_data_i),
  .reg2_data_i(ex_reg2_data_i),
  .wd_i(ex_wd_i),
  .wreg_i(ex_wreg_i),
  .opcode_i(ex_opcode_i),
  .op_i(ex_op_i),
  .imm_i(ex_imm_i),
  .shamt_i(ex_shamt_i),
  .wd_o(ex_wd_o),
  .wreg_o(ex_wreg_o),
  //.wdata_o(ex_wdata_o),
  .data_out(ex_wdata_o),
  .opcode_o(ex_opcode_o),
  .op_o(ex_op_o),
  .mem_addr_o(ex_mem_addr_o)
);

ex_mem ex_mem0(
  .clk(clk_in),
  .rst(rst_in),
  .ex_wd(ex_wd_o),
  .ex_wreg(ex_wreg_o),
  .ex_wdata(ex_wdata_o),
  .ex_opcode(ex_opcode_o),
  .ex_op(ex_op_o),
  .ex_mem_addr(ex_mem_addr_o),
  .stall_i(stall_flag),
  .mem_wd(mem_wd_i),
  .mem_wreg(mem_wreg_i),
  .mem_wdata(mem_wdata_i),
  .mem_opcode(mem_opcode_i),
  .mem_op(mem_op_i),
  .mem_mem_addr(mem_mem_addr_i)
);

mem mem0(
  .clk(clk_in),
  .rst(rst_in),
  .opcode_i(mem_opcode_i),
  .op_i(mem_op_i),
  .mem_addr_i(mem_mem_addr_i),
  .mem_data_i(mem_din),
  .wd_i(mem_wd_i),
  .wreg_i(mem_wreg_i),
  .wdata_i(mem_wdata_i),
  .wd_o(mem_wd_o),
  .wreg_o(mem_wreg_o),
  .wdata_o(mem_wdata_o),
  .mem_addr_o(mem_mem_addr),
  .mem_data_o(mem_data),
  .mem_we_o(mem_we),
  .mem_mem_req_o(mem_mem_req)
);

mem_wb mem_wb0(
  .clk(clk_in),
  .rst(rst_in),
  .mem_wd(mem_wd_o),
  .mem_wreg(mem_wreg_o),
  .mem_wdata(mem_wdata_o),
  .stall_i(stall_flag),
  .wb_wd(wb_wd_i),
  .wb_wreg(wb_wreg_i),
  .wb_wdata(wb_wdata_i)
);

regfile regfile0(
  .clk(clk_in),
  .rst(rst_in),
  .ready(rdy_in),
  .we(wb_wreg_i),
  .waddr(wb_wd_i),
  .wdata(wb_wdata_i),
  .re1(reg1_read),
  .raddr1(reg1_addr),
  .rdata1(reg1_data),
  .re2(reg2_read),
  .raddr2(reg2_addr),
  .rdata2(reg2_data)
);

memctrl memctrl0(
  .rst(rst_in),
  .ready(rdy_in),
  .if_mem_req_i(if_mem_req),
  .if_mem_addr_i(if_mem_addr),
  .mem_mem_req_i(mem_mem_req),
  .mem_mem_addr_i(mem_mem_addr),
  .mem_data_i(mem_data),
  .mem_we_i(mem_we),
  .mem_addr_o(mem_a),
  .mem_data_o(mem_dout),
  .if_stall_o(if_stall),
  .mem_stall_o(mem_stall),
  .we_o(mem_wr)
);

hazardctrl hazardctrl0(
  .rst(rst_in),
  .ready(rdy_in),
  .if_stall_i(if_stall),
  .mem_stall_i(mem_stall),
  .branch_stall_i(branch_stall),
  .stall_o(stall_flag)
);

cache cache0(
  .rst(rst_in),
  .clk(clk_in),
  .ready(rdy_in),
  .we_i(cache_we),
  .write_inst_i(cache_write_inst),
  .write_addr_i(cache_write_addr),
  .read_addr_i(cache_read_addr),
  .cache_hit_o(cache_hit),
  .cache_inst_o(cache_inst)
);

always @(posedge clk_in)
  begin
    if (rst_in)
      begin
      
      end
    else if (!rdy_in)
      begin
      
      end
    else
      begin
      
      end
  end

endmodule