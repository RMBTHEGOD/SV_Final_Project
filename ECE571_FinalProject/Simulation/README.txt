Steps to run the Simulation:

1. The current directory should contain the hdl folder, hvl folder, memory_model folder, README.txt and Makefile.
2. Type make all to compile and run the simulation. 
   3 Errors and 2 Warnings are expected. These suppressible errors are from the memory model which are not due to the Memory Controller design or the test bench.
   Report mentions about the reason for warnings under the section BUGS.
3. Type make design to compile and run only the hdl files.
4. Type make update to compile and run only the hvl files.
5. Type make run to run all the files
6. Type make coverage to generate the coverage statistics (only available on the GUI).
7. Type make clean to remove the work directory and delete the transcript.
