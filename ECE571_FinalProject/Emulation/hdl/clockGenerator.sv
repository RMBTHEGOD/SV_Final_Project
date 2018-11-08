//////////////////////////////////////////////////////////////
// ClockGeneratorr.sv - Generates the second clock required for the DUT
//
// Author:	Rithvik Mitresh Ballal 
// Date:	25-Feb-2017
//
// Description:
// ------------
// The second clock is generated using the primary clock. The clock generated
// is phase shifted with the primary clock
////////////////////////////////////////////////////////////////



`timescale 1ps/1ps

module clockGenerator(input i_cpu_ck,output bit i_cpu_ck_ps);

parameter ps = 2500/4;  //delay

initial
begin
i_cpu_ck_ps = 1;  // second clock
forever
begin
i_cpu_ck_ps = #ps i_cpu_ck;   // seconds clock is generated with a delay of ps.
end
end

endmodule
