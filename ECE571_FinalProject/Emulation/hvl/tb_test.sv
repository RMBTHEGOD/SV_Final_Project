//////////////////////////////////////////////////////////////
// tb_test.sv
//
// Author: Vadiraja M N
// Date: 03-12-2018
//
// Description:
// ------------
// The test program decides the number of packets to be sent to the DUT 
// and received to verify. It calls the environment class
// 
// Reference: http://www.verificationguide.com/p/systemverilog-testbench.html
////////////////////////////////////////////////////////////////////////////

//`include "tb_environment.sv"

program test(mem_intf intf);
import environment_p::* ;

environment env;													//declaring environment instance
   
initial begin
    env = new(intf);												//creating environment
     
	env.gen.repeat_count = 1000;									//setting the repeat count of generator as 1000, means to generate 1000 packets
   	env.driv.count = 1000;											// Drive 1000 packets
	env.scb.count = 1000;											// Compare 1000 packets
 
    env.run();														//calling run of environment class, it interns calls generator and driver main tasks.														
  end
endprogram