//////////////////////////////////////////////////////////////
// top.sv
//
// Author: Sai Teja
// Date: 03-15-2018
//
// Description:
// ------------
// The HDL top module instantiates the DUT(memory Conroller) , the interface to the  
// Memory Controller and the interface to the Memory.
///////////////////////////////////////////////////////////////

`timescale 1ps/1ps
module hdltop();

parameter tck = 2500/2;
parameter ps = 2500/4;
logic i_cpu_ck;
bit i_cpu_ck_ps;
//===================== Clock Generation========================================================
    // clock generator
	// tbx clkgen
	initial 
	begin
	i_cpu_ck =1;
	forever
	begin
    #tck  i_cpu_ck = ~i_cpu_ck;
	end
	end
	
	

//===================== Interface Instance =====================================================
	mem_intf cpu_contr(
						.i_cpu_ck(i_cpu_ck)					// Instance of CPU-CONTR Interface
					  );
    clockGenerator cg(.i_cpu_ck(i_cpu_ck),.i_cpu_ck_ps(i_cpu_ck_ps));					  

	mem_if contr_mem(
					  .i_cpu_ck(i_cpu_ck)					// Instance of CONTR-MEM Interface
					);
	

//======================= CPU Instance===========================================================


//cpu_model cpu_model_inst (.i_cpu_ck(cpu_model),.if_cpu(cpu_contr.DRIVER));

//======================= Controller Instance====================================================
	DDR3_Controller	DDR3(
						  .i_cpu_ck(i_cpu_ck),				// System Clock
					      .i_cpu_ck_ps(i_cpu_ck_ps),
						  .cont_if_cpu(cpu_contr.MemController),			// CPU-CONTR ports
					      .cont_if_mem(contr_mem.contr_sig));			// CONTR-MEM ports	

//======================Memory Instance===========================================================

	ddr3_simple4 dd3_model (
		.cont_if_mem_model(contr_mem.mem_sig) 	
	);



endmodule // hdltop	
