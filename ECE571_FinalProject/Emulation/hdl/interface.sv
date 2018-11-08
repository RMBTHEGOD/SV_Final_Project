//////////////////////////////////////////////////////////////////////////////
// interface.sv -  INTERFACE DECLARATION: COMMON BETWEEN DUT AND HVL
//
// Author:			Vadiraja , Jyothsna , Ajna
// Version:			1.1
// Last modified:	15-Mar-2018
//
// Module contains the definitions of signals required between the Memory Controller 
// and Memory and also with the CPU and Controller
////////////////////////////////////////////////////////////////////////////
//
//  Package containing the parameterized definitions of TIMING and WIDTH
import DDR3MemPkg::* ;

interface mem_if(input logic i_cpu_ck);	 // pragma attribute mem_if partition_interface_xif
	logic   rst_n;
    logic   ck;
    logic   ck_n;
    logic   cke;
    logic   cs_n;
    logic   ras_n;
    logic   cas_n;
    logic   we_n;
    tri   [1-1:0]   dm_tdqs;
    logic   [BA_BITS-1:0]   ba;
    logic   [ADDR_BITS-1:0] addr;
    tri   [DQ_BITS-1:0]   dq;
    tri   [1-1:0]  dqs;
    tri   [1-1:0]  dqs_n;
    logic  [1-1:0]  tdqs_n;
    logic   odt;

//======Module port for controller signals===============================================================
	modport contr_sig (
		output ck, ck_n, rst_n, cs_n, cke, ras_n, cas_n, we_n, odt, ba, addr,tdqs_n,
		inout dm_tdqs, dq, dqs, dqs_n
	);


//======Module ports for Memory===========================================================================
	modport mem_sig (
		input ck, ck_n, rst_n, cs_n, cke, ras_n, cas_n, we_n, odt,ba, addr,tdqs_n,
		inout dm_tdqs,dq, dqs, dqs_n
	);

covergroup cov_mem @(posedge ck);

address : coverpoint addr {
           bins A1 = {[0: 2**7]};
           bins A2 = {[2**10 : (2**14)-1]};
          }
clk_en : coverpoint cke {
          bins off = {0};
          bins enable = {1};
          }
activate : coverpoint ras_n {
            bins off = {1};
            bins on = {0};
           }
rd_wr : coverpoint cas_n{
             bins rw = {0};
             bins rw_off = {1};
           }
write : coverpoint we_n {
            bins wr = {0};
            bins rd = {1};
          }
ondie : coverpoint odt {
          bins off_odt = {1};
          bins on_odt = {0};
         }
bank : coverpoint ba {
        bins bks = {0, 1, 2, 3, 4, 5, 6, 7};
       }

c1xc2 : cross ras_n, cas_n;

c3xc4 : cross cas_n, we_n;

c5xc6 : cross ras_n, we_n;

c7xc8 : cross ondie, cas_n;

endgroup

cov_mem cov_mem_inst = new();

endinterface : mem_if

///////////////////////// Interface for Driver///////////////////////////

//import DDR3MemPkg::*;

//import transaction_p::*;

interface mem_intf(input logic i_cpu_ck);  // pragma attribute mem_intf partition_interface_xif
   
  	//logic	     				i_cpu_ck;		// Clock from TB
	logic	     				i_cpu_reset;	// Reset passed to Controller from TB
	logic [ADDR_MCTRL-1:0]		i_cpu_addr;  	// Cpu Addr
	logic 	     				i_cpu_cmd;		// Cpu command RD or WR
	logic [8*DQ_BITS-1:0]		i_cpu_wr_data;	// Cpu Write Data 
	logic 	     				i_cpu_valid;	// Valid is set when passing CPU addr and command
	logic 	     				i_cpu_enable;	// Chip Select
	logic [BURST_L-1:0]  		i_cpu_dm;		// Data Mask - One HOT
	logic [$clog2(BURST_L):0]	i_cpu_burst;	// Define Burst Length - wont be used for now
	logic [8*DQ_BITS-1:0]		o_cpu_rd_data;	// Cpu data Read
	logic	     				o_cpu_data_rdy;	// Cpu data Read	
	logic 						o_cpu_rd_data_valid; // Signal for valid data sent to CPU   
	
 covergroup cov_cpu @(posedge i_cpu_ck);

cpu_addr : coverpoint i_cpu_addr {
           bins A1 = {[0: 2**4]};
           bins A2 = {[2**7: ((2**14)-1)]};
           bins A3 = {[2**17 : 2**20]};
           bins A4 = {[2**21 : (2**24)-1]};
          }

cpu_cmd : coverpoint i_cpu_cmd {
          bins read = {0};
          bins write = {1};
          }
cpu_valid : coverpoint i_cpu_valid {
            bins off = {0};
            bins on = {1};
           }
cpu_rdy : coverpoint o_cpu_data_rdy {
          bins rdy_on = {1};
          bins rdy_off = {0};
          }
cpu_rd_valid : coverpoint o_cpu_rd_data_valid {
               bins rd_valid = {1};
               bins rd_off = {0};
              }
c1xc2 : cross cpu_cmd, cpu_valid;

c3xc4 : cross cpu_rdy, cpu_cmd;

c5xc6 : cross cpu_valid, cpu_rdy;

c7xc8 : cross cpu_addr, cpu_valid;

endgroup

cov_cpu cov_cpu_inst = new();

  modport MemController (
		input i_cpu_ck,
		input 	i_cpu_reset,
		input 	i_cpu_addr,
		input 	i_cpu_cmd,
		input 	i_cpu_wr_data,
		input 	i_cpu_valid,
		input 	i_cpu_enable,
		input 	i_cpu_dm,
		input 	i_cpu_burst,
		output  o_cpu_rd_data,
		output  o_cpu_data_rdy,	
		output 	o_cpu_rd_data_valid);

int count;
  
task Reset(); // pragma tbx xtf
		@(posedge i_cpu_ck);
		$display("--------- [DRIVER] Reset Started ---------");
		i_cpu_reset = 1;
		i_cpu_valid = 0;
		i_cpu_enable= 0;
		@(posedge i_cpu_ck);
		i_cpu_reset = 0;
		i_cpu_enable = 1;
		$display("--------- [DRIVER] Reset Ended---------");
endtask

task Write(logic [ADDR_MCTRL-1:0] address, logic [8*DQ_BITS-1:0] write_data); // pragma tbx xtf
		@(posedge i_cpu_ck);
		wait (o_cpu_data_rdy);
		@(posedge i_cpu_ck);
		i_cpu_valid=1'b1;  
		i_cpu_cmd=1'b1;
		if (i_cpu_valid && i_cpu_cmd) begin												// Write 				
				i_cpu_addr=address;
				i_cpu_wr_data=write_data;
		end
		@(posedge i_cpu_ck);
		i_cpu_valid=0;
endtask

task Read(logic [ADDR_MCTRL-1:0] address, output logic [8*DQ_BITS-1:0] read_data );  // pragma tbx xtf
		@(posedge i_cpu_ck);
		wait(o_cpu_data_rdy);
		@(posedge i_cpu_ck);
		i_cpu_valid=1'b1;  
		i_cpu_cmd=1'b0;
		if (i_cpu_valid && ~i_cpu_cmd) begin											// Read
				i_cpu_addr=address;
				@(posedge i_cpu_ck);
				i_cpu_valid=0;
				wait(o_cpu_rd_data_valid);
				@(posedge i_cpu_ck);
				read_data = o_cpu_rd_data;
				end
		
endtask

task run(logic valid, logic cmd, logic [ADDR_MCTRL-1:0] address, logic [8*DQ_BITS-1:0] wr_data, output logic [8*DQ_BITS-1:0] rd_data);  // pragma tbx xtf
		@(posedge i_cpu_ck);
		$display("count=%d", count++);
		wait (o_cpu_data_rdy);
		@(posedge i_cpu_ck);
		if(valid) begin
		@(posedge i_cpu_ck);
		i_cpu_valid=valid;  
		i_cpu_cmd=cmd;
		if (valid && cmd) begin												// Write 				
				i_cpu_addr=address;
				i_cpu_wr_data=wr_data;
				@(posedge i_cpu_ck);
				i_cpu_valid=0;
				end
		
		if (valid && ~cmd) begin											// Read
				i_cpu_addr=address;
				@(posedge i_cpu_ck);
				i_cpu_valid=0;
				wait(o_cpu_rd_data_valid);
				@(posedge i_cpu_ck);
				rd_data = o_cpu_rd_data;
				end
		end
endtask

endinterface : mem_intf




