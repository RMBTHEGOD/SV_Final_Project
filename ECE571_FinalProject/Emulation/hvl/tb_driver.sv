//////////////////////////////////////////////////////////////
// tb_driver.sv
//
// Author: Vadiraja M N
// Date: 03-11-2018
//
// Description:
// ------------
// The driver class consists of tasks which in turn call tasks like read and write 
// by forcing a few inputs for directed test cases and extracting packets from the mailbox 
// which are randomized test inputs sent to the DUT. At the same time, these packets are
// stored in another mailbox which is used by the scoreboard for verification.
//
// Reference: http://www.verificationguide.com/p/systemverilog-testbench.html
////////////////////////////////////////////////////////////////


/////////////////////////////////////////Driver Class//////////////////////////////////////////
package driver_p;

import transaction_p::* ;
import generator_p::*;
import DDR3MemPkg::* ;

class driver;
   
  
  int no_transactions;														//count the number of transactions
  int count;																// Number of packets sent
  
  virtual mem_intf mem_vif;													//creating virtual interface handle
  mailbox gen2driv;															//creating mailbox handle for sending packets
  mailbox mon2scb;															//creating mailbox handle for receiving packets
  
  logic [2**BA_BITS-1:0][8*DQ_BITS-1:0] memory_write = 
  {{4{16'h1403}},{4{16'h1225}}, {4{16'h0312}}, {4{16'h0876}},{4{16'h1025}}, {4{16'h6512}}, {4{16'h1385}}, {4{16'h4213}}} ; 		// Data array to be written
  logic [2**BA_BITS-1:0][8*DQ_BITS-1:0] memory_read;																			// Data array read from the memory
  logic [8*DQ_BITS-1:0] data_read;																								// Data in one column
  logic [2**BA_BITS-1:0][ADDR_MCTRL-1:0] address = 																				// Addresses to which data has been written and read from.
  {32'h00341c09, 32'h00931886, 32'h00901509, 32'h00101082, 32'h00998c02, 32'h00024882, 32'h00e1040f, 32'h00404282};
   
  
function new(virtual mem_intf mem_vif, mailbox gen2driv, mailbox mon2scb);	//constructor
    this.mem_vif = mem_vif;													//getting the interface
    this.gen2driv = gen2driv;												//getting the mailbox handle from  environment
	this.mon2scb = mon2scb ;												//getting the mailbox handle from  environment
endfunction

task reset();
	mem_vif.Reset();														// Call the reset task defined in the interface using the virtual interface handle
endtask


task directed_test();														// Consists of 4 scenarios of directed test cases.

///////////////////////////////////////// Scenario 1: Verify if 1 column of data written has been read////////////////////////////////

	mem_vif.Write(address[7], memory_write[7]);								// Call the write task defined in the interface using the virtual interface handle
	mem_vif.Read(address[7], data_read);									// Simple data write and read
	
////////////////////////////////////////// Scenario 2: Overwrite data on the same address and verify by read //////////////////////
	
	mem_vif.Write(address[6], memory_write[7]);
	mem_vif.Write(address[6], memory_write[6]);								
	mem_vif.Read(address[6], data_read);
	
////////////////////////////////////////// Scenario 3: Write to same row, different column and verify by read////////////////////////
	
	mem_vif.Write(32'h00341cf9, memory_write[5]);							
	mem_vif.Read(32'h00341cf9, data_read);
	
/////////////////////////////////////// Scenario 4: Write to different row, same bank and verify by read/////////////////////////////
	
	mem_vif.Write(32'h00e41cf9, memory_write[2]);							
	mem_vif.Read(32'h00e41cf9, data_read);
	
	
endtask

///////////////////Scenario 5: Write to 4 Consecutive rows starting from Bank 0, Row 0 , Column 0 to Bank 0, Row 3, Last Column///////////////////// 

task consecutive_addresses();													 
																				// 
	logic [ADDR_MCTRL-1:0] base_address = 32'h00000000;  						// Bank 0 , Row 0, Column 0 
	logic [ADDR_MCTRL-1:0] start_address, actual_address;						// Temporary addresses
	logic [8*DQ_BITS-1:0] read_data;											// One column of data of 64 bits
	
	for (int j=0; j<4; j++)														// Row 0 to Row 4
	begin
		start_address = {base_address[31:15],j[1:0],base_address[12:0]};	
		for (int i=0;i<(2**(COL_BITS-3));i++)									// All columns in the row
		begin 
			logic [8*DQ_BITS-1:0] random_data = {$urandom,$urandom};			// Generate random data
			actual_address = {start_address[31:10],i[6:0],start_address[2:0]};
			mem_vif.Write(actual_address, random_data);   
			//$display("send_data=%h\n", send_data);
			mem_vif.Read(actual_address, read_data);
		end	
	end
	
endtask

///////////////////////////// Write task which calls the write task defined in the interface using virtual interface/////////////////////////

task write();
	for (int i=0;i<(2**BA_BITS);i++)
	begin 
	mem_vif.Write(address[i], memory_write[i]);   						// Single write to every bank
	//$display("memory_write[%d]=%h\n",i,memory_write[i]);
	end	
endtask

///////////////////////////// Read task which calls the read task defined in the interface using virtual interface/////////////////////////

task read();
	for (int i=0;i<(2**BA_BITS);i++)
	begin
	mem_vif.Read(address[i], memory_read[i]);										// Read from the written addresses 
	end
endtask


//////// Drive task sends packets consisting of random inputs from the mailbox to the interface and to another mailbox used in the scoreboard //////////////////////////

task drive();
	repeat(count) begin
		transaction trans;																							 // Creating an object of the packet
		gen2driv.get(trans); 																						 // get packets from the mailbox
		mem_vif.run(trans.i_cpu_valid, trans.i_cpu_cmd, trans.i_cpu_addr, trans.i_cpu_wr_data, trans.o_cpu_rd_data); // Call run task defined in the interface  
		mon2scb.put(trans);																							 // Put packets in the 2nd mailbox used in the scoreboard
		no_transactions++;
	end
endtask
       
endclass

endpackage

