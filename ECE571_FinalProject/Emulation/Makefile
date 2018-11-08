#Rithvik Mitresh Ballal, Portland State University, March 2018
#This makefile is for TBX BFM Example - DDR3 Memory Controller

#Specify the mode- could be either puresim or veloce
#Always make sure that everything works fine in puresim before changing to veloce

MODE ?= veloce

#make all does everything
all: work build run

#Create respective work libs and map them 
work:
	vlib work.$(MODE)
	vmap work work.$(MODE)
	
#Compile/synthesize the environment
build:
	vlog ./hvl/DUT_pkg.sv	                    			#Compile the package
	vlog ./hvl/tb_transaction.sv					#compile the transaction.sv
	vlog ./hvl/tb_generator.sv					#compile the generator module
	vlog ./hvl/tb_driver.sv                   			#compile the driver module
	vlog ./hvl/tb_scoreboard.sv               			#compile the scoreboard module
	vlog ./hvl/tb_environment.sv					#compile the environment module
	vlog ./hvl/tb_test.sv 						#compile the test module
	vlog ./hvl/hvl_top.sv			            		#Compile the testbench 
	
ifeq ($(MODE),puresim)		    					#If mode is puresim, compile everything else
	vlog ./memory_model/dport_ram.v
	vlog ./memory_model/my_oddrx8.v
	vlog ./memory_model/my_iddrx8.v
	vlog ./memory_model/ddr3_sr4.v
	vlog ./memory_model/ddr3_sr36.v
	vlog ./memory_model/ddr3_simple4.sv
	vlog ./hdl/interface.sv           				#compile both the interface
	vlog ./hdl/clockGenerator.sv      				#compile the clock generator module
	vlog ./hdl/DDR3_Controller.sv					#Compile the ddr3 Memory controller DUT 
	vlog ./hdl/top.sv				    		#Compile the HDL top 
	vlog ./hdl/counter.sv             				#compile the counter module
	vlog ./hdl/Burst.sv               				#compile the write burst module
	velhvl -sim $(MODE)
else						                      	#else, synthesize!
	velanalyze ./hvl/DUT_pkg.sv		                      	#Analyze the package for synthesis 
	velanalyze -extract_hvl_info +define+QUESTA ./hvl/hvl_top.sv	#Analyze the HVL for external task calls in BFM
	velanalyze ./memory_model/dport_ram.v
	velanalyze ./memory_model/my_oddrx8.v
	velanalyze ./memory_model/my_iddrx8.v
	velanalyze ./memory_model/ddr3_sr4.v
	velanalyze ./memory_model/ddr3_sr36.v
	velanalyze ./memory_model/ddr3_simple4.sv
	velanalyze ./hdl/interface.sv                                 #Analyze both the interface
	velanalyze ./hdl/clockGenerator.sv                            #Analyze the clock generator module
	velanalyze ./hdl/top.sv		                                #Analyze the HDL top for synthesis 
	velanalyze ./hdl/DDR3_Controller.sv			                #Analyze the ddr3 Memory controller DUT for synthesis 
	velanalyze ./hdl/counter.sv                                   #Analyze the counter module
	velanalyze ./hdl/Burst.sv                                     #Analyze the write burst module   
	velcomp -top hdltop  	                                #Synthesize!
	velhvl -sim $(MODE) 
endif

run:
	vsim -novopt -c -do "run -all" hdltop hvltop	#Run all
	cp transcript transcript.$(MODE)		#Record transcript 

norun:	#No run lets you control stepping etc. 
	vsim -novopt -c +tbxrun+norun hdlTop hvlTop -cpppath $(CPP_PATH)
	cp transcript transcript.$(MODE)

clean:
	rm -rf tbxbindings.h modelsim.ini transcript.veloce transcript.puresim work work.puresim work.veloce transcript *~ vsim.wlf *.log dgs.dbg dmslogdir veloce.med veloce.wave veloce.map velrunopts.ini edsenv 
	


