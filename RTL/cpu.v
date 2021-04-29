//Module: CPU
//Function: CPU is the top design of the processor
//Inputs:
//	clk: main clock
//	arst_n: reset
// 	enable: Starts the execution
//	addr_ext: Address for reading/writing content to Instruction Memory
//	wen_ext: Write enable for Instruction Memory
// 	ren_ext: Read enable for Instruction Memory
//	wdata_ext: Write word for Instruction Memory
//	addr_ext_2: Address for reading/writing content to Data Memory
//	wen_ext_2: Write enable for Data Memory
// 	ren_ext_2: Read enable for Data Memory
//	wdata_ext_2: Write word for Data Memory
//Outputs:
//	rdata_ext: Read data from Instruction Memory
//	rdata_ext_2: Read data from Data Memory



module cpu(
		input  wire			  clk,
		input  wire         arst_n,
		input  wire         enable,
		input  wire	[31:0]  addr_ext,
		input  wire         wen_ext,
		input  wire         ren_ext,
		input  wire [31:0]  wdata_ext,
		input  wire	[31:0]  addr_ext_2,
		input  wire         wen_ext_2,
		input  wire         ren_ext_2,
		input  wire [31:0]  wdata_ext_2,

		output wire	[31:0]  rdata_ext,
		output wire	[31:0]  rdata_ext_2

   );
wire [31:0]					IF_current_pc,
										IF_updated_pc,
										IF_instruction;

wire signed [31:0]	ID_immediate_extended;
wire [31:0]	  			ID_updated_pc,
										ID_instruction,
										ID_regfile_data_1,
										ID_regfile_data_2;
wire [4:0]  				ID_regfile_waddr;
wire [1:0] 					ID_alu_op;
wire              	ID_branch,
										ID_mem_read,
										ID_jump,
										ID_reg_write,
										ID_mem_2_reg,
										ID_mem_write,
										ID_reg_dst,
										ID_alu_src;

wire signed [31:0]  EX_immediate_extended;
wire [31:0]					EX_instruction,
										EX_jump_pc,
										EX_branch_pc,
 										EX_alu_out,
										EX_regfile_data_1,
										EX_regfile_data_2,
										EX_alu_operand_2,
										EX_updated_pc,
										EX_Rs_forwarded,
										EX_alu_in_0,
										EX_alu_in_1;
wire [4:0] 					EX_regfile_waddr;
wire [3:0] 					EX_alu_control;
wire [1:0]   				EX_alu_op,
										EX_forward_Rs,
										EX_forward_Rt;
wire              	EX_zero_flag,
										EX_branch,
										EX_mem_read,
										EX_jump,
										EX_reg_write,
										EX_mem_2_reg,
										EX_mem_write,
										EX_alu_src;

wire [31:0]					MEM_jump_pc,
										MEM_branch_pc,
										MEM_regfile_data_2,
										MEM_dram_data,
										MEM_alu_out;
wire [4:0]					MEM_regfile_waddr;
wire								MEM_zero_flag,
 										MEM_mem_read,
										MEM_jump,
										MEM_branch,
										MEM_reg_write,
										MEM_mem_2_reg,
										MEM_mem_write;

wire [31:0]					WB_alu_out,
										WB_regfile_wdata,
										WB_dram_data;
wire [4:0]  				WB_regfile_waddr;
wire  							WB_reg_write,
										WB_mem_2_reg;


//register IF/ID
reg_arstn_en #(
   .DATA_W(64),
	 .PRESET_VAL(0)
) reg_IFID (
   .clk (clk),
   .arst_n (arst_n),
   .en(enable),
   .din ({IF_updated_pc,IF_instruction}),
	 .dout ({ID_updated_pc,ID_instruction})
);


//register ID/EX
reg_arstn_en #(
   .DATA_W(174),
	 .PRESET_VAL(0)
) reg_IDEX (
   .clk (clk),
   .arst_n (arst_n),
   .en(enable),
   .din ({ID_immediate_extended,
		 			ID_instruction,
					ID_updated_pc,
					ID_regfile_data_1,
					ID_regfile_data_2,
					ID_regfile_waddr,
					ID_alu_op,
					ID_branch,
					ID_mem_read,
					ID_jump,
					ID_reg_write,
					ID_mem_2_reg,
					ID_mem_write,
					ID_alu_src}),
	.dout ({EX_immediate_extended,
		 			EX_instruction,
					EX_updated_pc,
					EX_regfile_data_1,
					EX_regfile_data_2,
					EX_regfile_waddr,
					EX_alu_op,
					EX_branch,
					EX_mem_read,
					EX_jump,
					EX_reg_write,
					EX_mem_2_reg,
					EX_mem_write,
					EX_alu_src})
);


//register EX/MEM
reg_arstn_en #(
   .DATA_W(140),
	 .PRESET_VAL(0)
) reg_EXMEM (
   .clk (clk),
   .arst_n (arst_n),
   .en(enable),
   .din ({EX_jump_pc,
		 			EX_branch_pc,
					EX_regfile_data_2,
					EX_alu_out,
					EX_regfile_waddr,
					EX_zero_flag,
					EX_mem_read,
					EX_branch,
					EX_jump,
					EX_reg_write,
					EX_mem_2_reg,
					EX_mem_write}),
	 .dout({MEM_jump_pc,
 		 			MEM_branch_pc,
 					MEM_regfile_data_2,
 					MEM_alu_out,
 					MEM_regfile_waddr,
 					MEM_zero_flag,
 					MEM_mem_read,
 					MEM_branch,
 					MEM_jump,
 					MEM_reg_write,
 					MEM_mem_2_reg,
 					MEM_mem_write})
);



//register MEM/WB
reg_arstn_en #(
   .DATA_W(71),
	 .PRESET_VAL(0)
) reg_MEMWB (
   .clk (clk),
   .arst_n (arst_n),
   .en(enable),
   .din ({MEM_dram_data,
		 			MEM_alu_out,
					MEM_regfile_waddr,
					MEM_reg_write,
					MEM_mem_2_reg}),
	 .dout({WB_dram_data,
		 			WB_alu_out,
					WB_regfile_waddr,
					WB_reg_write,
					WB_mem_2_reg})
);

assign ID_immediate_extended = $signed(ID_instruction[15:0]);


pc #(
   .DATA_W(32)
) program_counter (
   .clk       (clk       ),
   .arst_n    (arst_n    ),
   .branch_pc (MEM_branch_pc ),
   .jump_pc   (MEM_jump_pc   ),
   .zero_flag (MEM_zero_flag ),
   .branch    (MEM_branch    ),
   .jump      (MEM_jump      ),
   .current_pc(IF_current_pc),
   .enable    (enable    ),
   .updated_pc(IF_updated_pc)
);


sram #(
   .ADDR_W(9 ),
   .DATA_W(32)
) instruction_memory(
   .clk      (clk           ),
   .addr     (IF_current_pc    ),
   .wen      (1'b0          ),
   .ren      (1'b1          ),
   .wdata    (32'b0         ),
   .rdata    (IF_instruction),
   .addr_ext (addr_ext      ),
   .wen_ext  (wen_ext       ),
   .ren_ext  (ren_ext       ),
   .wdata_ext(wdata_ext     ),
   .rdata_ext(rdata_ext     )
);

control_unit control_unit(
   .opcode   (ID_instruction[31:26]),
   .reg_dst  (ID_reg_dst           ),
   .branch   (ID_branch            ),
   .mem_read (ID_mem_read          ),
   .mem_2_reg(ID_mem_2_reg         ),
   .alu_op   (ID_alu_op            ),
   .mem_write(ID_mem_write         ),
   .alu_src  (ID_alu_src           ),
   .reg_write(ID_reg_write         ),
   .jump     (ID_jump              )
);


mux_2 #(
   .DATA_W(5)
) regfile_dest_mux (
   .input_a (ID_instruction[15:11]),
   .input_b (ID_instruction[20:16]),
   .select_a(ID_reg_dst          ),
   .mux_out (ID_regfile_waddr     )
);

register_file #(
   .DATA_W(32)
) register_file(
   .clk      (clk               ),
   .arst_n   (arst_n            ),
   .reg_write(WB_reg_write         ),
   .raddr_1  (ID_instruction[25:21]),
   .raddr_2  (ID_instruction[20:16]),
   .waddr    (WB_regfile_waddr     ),
   .wdata    (WB_regfile_wdata     ),
   .rdata_1  (ID_regfile_data_1    ),
   .rdata_2  (ID_regfile_data_2    )
);


alu_control alu_ctrl(
   .function_field (EX_instruction[5:0]),
   .alu_op         (EX_alu_op          ),
   .alu_control    (EX_alu_control     )
);

mux_2 #(
   .DATA_W(32)
) alu_operand_mux (
   .input_a (EX_immediate_extended),
   .input_b (EX_regfile_data_2    ),
   .select_a(EX_alu_src           ),
   .mux_out (EX_alu_operand_2     )
);

forwarding_unit EX_forwarding_unit (
	.MEM_reg_write (MEM_reg_write),
	.WB_reg_write	 (WB_reg_write),
	.Rs 			 		 (EX_instruction[25:21]),
	.Rt 					 (EX_instruction[20:16]),
	.MEM_Rd 			 (MEM_regfile_waddr),
	.WB_Rd 				 (WB_regfile_waddr),
	.forward_Rs 	 (EX_forward_Rs),
	.forward_Rt 	 (EX_forward_Rt)
);

mux_2 #(
   .DATA_W(32)
) mux_forward_Rs (
   .input_a (MEM_alu_out),
   .input_b (WB_regfile_wdata),
   .select_a(EX_forward_Rs[0]),
   .mux_out (EX_Rs_forwarded)
);

mux_2 #(
   .DATA_W(32)
) mux_forward_Rt (
   .input_a (MEM_alu_out),
   .input_b (WB_regfile_wdata),
   .select_a(EX_forward_Rt[0]),
   .mux_out (EX_Rt_forwarded)
);

mux_2 #(
   .DATA_W(32)
) mux_alu_in_0 (
   .input_a (EX_Rs_forwarded),
   .input_b (EX_regfile_data_1),
   .select_a(EX_forward_Rs[1]),
   .mux_out (EX_alu_in_0)
);

mux_2 #(
   .DATA_W(32)
) mux_alu_in_1 (
   .input_a (EX_Rt_forwarded),
   .input_b (EX_alu_operand_2),
   .select_a(EX_forward_Rt[1]),
   .mux_out (EX_alu_in_1)
);

alu#(
   .DATA_W(32)
) alu(
   .alu_in_0 (EX_alu_in_0),
   .alu_in_1 (EX_alu_in_1),
   .alu_ctrl (EX_alu_control),
   .alu_out  (EX_alu_out),
   .shft_amnt(EX_instruction[10:6]),
   .zero_flag(EX_zero_flag),
   .overflow (              )
);

sram #(
   .ADDR_W(10),
   .DATA_W(32)
) data_memory(
   .clk      (clk           ),
   .addr     (MEM_alu_out       ),
   .wen      (MEM_mem_write     ),
   .ren      (MEM_mem_read      ),
   .wdata    (MEM_regfile_data_2),
   .rdata    (MEM_dram_data     ),
   .addr_ext (addr_ext_2    ),
   .wen_ext  (wen_ext_2     ),
   .ren_ext  (ren_ext_2     ),
   .wdata_ext(wdata_ext_2   ),
   .rdata_ext(rdata_ext_2   )
);



mux_2 #(
   .DATA_W(32)
) regfile_data_mux (
   .input_a  (WB_dram_data    ),
   .input_b  (WB_alu_out      ),
   .select_a (WB_mem_2_reg     ),
   .mux_out  (WB_regfile_wdata)
);



branch_unit#(
   .DATA_W(32)
)branch_unit(
   .updated_pc   (EX_updated_pc        ),
   .instruction  (EX_instruction       ),
   .branch_offset(EX_immediate_extended),
   .branch_pc    (EX_branch_pc         ),
   .jump_pc      (EX_jump_pc         )
);


endmodule

module forwarding_unit(
      input wire        MEM_reg_write,
      input wire        WB_reg_write,
      input  wire [4:0] Rs,
      input  wire [4:0] Rt,
      input  wire [4:0] MEM_Rd,
      input  wire [4:0] WB_Rd,
      output wire [1:0] forward_Rs,
      output wire [1:0] forward_Rt
   );

   always@(*)begin
      if(Rs == MEM_Rd && MEM_Rd != 5'b00000 && MEM_reg_write == 1'b1)           // EX hazard
        forward_Rs = 2'b11;
      else if(Rs == WB_Rd && WB_Rd != 5'b00000 && WB_reg_write == 1'b1)         // MEM hazard
        forward_Rs = 2'b10;
      else
        forward_Rs = 2'b00;

      if(Rt == MEM_Rd && MEM_Rd != 5'b00000 && MEM_reg_write == 1'b1)           // EX hazard
        forward_Rt = 2'b11;
      else if(Rt == WB_Rd && WB_Rd != 5'b00000 && WB_reg_write == 1'b1)    // MEM hazard
        forward_Rt = 2'b10;
      else
        forward_Rt = 2'b00;
   end
endmodule
