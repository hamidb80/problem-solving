// Filename	:  top.v
// Author	:  Andrew Fernandez & Eliot Gerstner	  	
// Date		:  2/9/2000
// Mod:	Date:	By:	Reason:
//	2/13	ADF	Removed some extra signals from control,
//			so v2sue works ok
//		
// -------------------------------------------
// 2-D Convolver 
// Functional Top Level Description
///////////////////////////////////////////////////////////////
//-------------------------------------------------------------
// Design Testbench: Instantiates DP, Memory, and Control
//-------------------------------------------------------------
module top();

 wire   	Phi1, 		// 2-Phase Clocks
		Phi2,		//  
		Reset_s1;	// Reset (active high, 4cycles) 
 wire [7:0] 	Pixel_s1;	// Input: kernel+datastream
 wire		Output_Ready_q1;// Signal conv. value is done
 
// Declare Memory (OUTPUTS)
//-------------------------------------------------------------
 wire 	[7:0]	Kernel_Bus_b_v1; // "top row" 	    (to datapath)
 wire 		pixel_bit0_v1,	// "top row pixel"  (to datapath)
		pixel_bit1_v1,	// "middle row pix" (to datapath)
		pixel_bit2_v1;	// "bottom row pix" (to datapath)
 wire 	[8:0]	Word_Line_q1;	// kernel latch clocks (to datapath)


// Declare Datapath (OUTPUTS)
//-------------------------------------------------------------
 wire 	[19:11] SR_toControl_s1;// to control for bounds checking
 wire 	[7:0] 	Final_Output_s1;// Result of one convolution


// Declare Control (OUTPUTS)
//-------------------------------------------------------------
 wire 	Write_Mem_q1, 		// Write to SRAM
	Shift_Right_s2, 	// Datapath SR, right shift
	No_Shift_s2,		// Datapath SR, no shift
	Reset_Shift_s2, 	// Reset Datapath SR
	Input_Ready_s1,		// New pixel value is needed
 	Kernel_en_s1;		// Enable Latched Kernel Values	

 wire 		c9_Phi1_q1;	// wordCounter clock
 wire 		c8_Phi1_q1; 	// pixCounter Clock
 wire 		p3_Phi1_q1;	// MemPointerCounter Clock
 wire 		c3_Phi2_q2;	// kernelCounter Clock

				// Goes to Final Mux in Datapath
 wire 	[1:0]  	Sat_Controls_s1;	// [0] = output ok! 
				// [-] = sat to zero (SR_toControl_s1[19])
				// [1] = sat to 255
 wire 	[2:0]	Sat_Control_s1;	// Input to Final Mux in Datapath


// Declare Counter (OUTPUTS)
//-------------------------------------------------------------
 wire 		pixCounterOut7_s1;	// Pixel bit -> Memory
 wire 		wordCounterOut0_s1;	// -> Control
 wire 		wordCounterOut2_s1;	// -> Control
 wire 		kernelCounterOut2_s1;	// -> Control
 wire 	[8:0] 	wordCounterOut_s1;	// see above
 wire 	[8:0] 	wordCounterShifted_s1;	// -> Memory (wordlines)
 wire 	[2:0] 	kernelCounterOut_s1;	// -> Datapath (sel kernel col)
 wire 	[2:0] 	Mem_Pointer_s1;		// -> Memory (select row)
 wire  	[7:0]  	Pix_Mux_s1;		// == pixCounterOut_s1
 wire  	[2:0] 	Kernel_Mux_s1;		// == kernelCounterOut_s1 
					//Select appropriate kernel
					//  values for multiplication


// Signal reassignment for different blocks 
//------------------------------------------------------------- 
 assign wordCounterOut0_s1 	= wordCounterOut_s1[0];
 assign wordCounterOut2_s1 	= wordCounterOut_s1[2];
 assign pixCounterOut7_s1 	= Pix_Mux_s1[7];
 assign kernelCounterOut2_s1 	= kernelCounterOut_s1[2];
 assign Kernel_Mux_s1		= kernelCounterOut_s1;
 assign Output_Ready_q1		= Write_Mem_q1;		// Output valid
							// when
							// Write_Mem_q1 is high
 assign Sat_Control_s1[2:0]	= {Sat_Controls_s1[1],
				   SR_toControl_s1[19],
				   Sat_Controls_s1[0]};
 

// Instantiate Counter Block
//-------------------------------------------------------------
counters countblock(c8_Phi1_q1, Phi2, 
		c9_Phi1_q1, Phi2, 
		Phi1, c3_Phi2_q2, 
		p3_Phi1_q1, Phi2, 
		Pix_Mux_s1[7:0], 
		wordCounterOut_s1[8:0], 
		kernelCounterOut_s1[2:0], 
		Mem_Pointer_s1[2:0], 
		wordCounterShifted_s1[8:0], Reset_s1);


//------- Instantiate Controller--------
control controller(Phi1, Phi2, Reset_s1,
		pixCounterOut7_s1,
		wordCounterOut0_s1,
		wordCounterOut2_s1,
		kernelCounterOut2_s1,
		Kernel_en_s1,
	        Write_Mem_q1,
		Shift_Right_s2, No_Shift_s2, Reset_Shift_s2,  
		Input_Ready_s1,
		c8_Phi1_q1, c9_Phi1_q1, 
		p3_Phi1_q1,
		c3_Phi2_q2,
		SR_toControl_s1[19:11],
		Sat_Controls_s1);


//------- Instantiate Memory--------
regfile	 memory(Reset_s1, 
		Write_Mem_q1, 
		wordCounterShifted_s1[8:0],
		Pixel_s1[7:0], 
		Mem_Pointer_s1[2:0], 
		Pix_Mux_s1[7:0],
		Word_Line_q1[8:0], 
		Kernel_Bus_b_v1[7:0], 
		pixel_bit0_v1, pixel_bit1_v1, pixel_bit2_v1, 
		Phi1, Phi2);


//------- Instantiate Datapath--------
datapath dp(Phi1, Phi2, 
		Kernel_Bus_b_v1[7:0], 
		pixel_bit0_v1, pixel_bit1_v1, pixel_bit2_v1, 
		Shift_Right_s2, No_Shift_s2, Reset_Shift_s2, 
		Kernel_Mux_s1[2:0],
		Kernel_en_s1,
		Word_Line_q1[8:0], 
		Sat_Control_s1, 
		SR_toControl_s1[19:11], 
		Final_Output_s1[7:0]);






//------- Instantiate Testing Modules--------
stimulus	stimulus(Phi1, Phi2, 
			Reset_s1, 
			Input_Ready_s1, 
			Pixel_s1[7:0]);

storeout	storeout(Output_Ready_q1, 
			Final_Output_s1, 
			Reset_s1);


//---- Begin Test Procedure--------
initial 
begin  
// Create a dump file for Magellen navigator
$ssi_navdbase("nav.dbase", "top.v");
//  $ssi_navdump;
 $dumpvars;
//  $dumpon;
end


//---- Begin Snooping -------------
/*
dpsnooper dpsnooper(
	Phi1, Phi2, 
	Kernel_Bus_b_v1, 
	pixel_bit0_v1, pixel_bit1_v1, pixel_bit2_v1, 
	Shift_Right_s2, No_Shift_s2, Reset_Shift_s2, 
	Kernel_Mux_s1, Kernel_en_s1, 
	Word_Line_q1, 
	Sat_Control_s1, 
	SR_toControl_s1, 
	Final_Output_s1);

*/

//wordcsnooper wordcsnooper(
//	c9_Phi1_q1, Phi2, Reset_s1, wordCounterOut_s1);
/*
countsnooper countsnooper(
	c8_Phi1_q1, Phi2, c9_Phi1_q1, Phi1, 
	c3_Phi2_q2, p3_Phi1_q1, Reset_s1, Pix_Mux_s1, 
	wordCounterOut_s1, kernelCounterOut_s1, Mem_Pointer_s1, wordCounterShifted_s1);
*/

topsnooper topsnooper(
	Phi1, Phi2, Reset_s1, Pixel_s1, 
	Final_Output_s1, Input_Ready_s1, Output_Ready_q1);

/*
controlsnooper controlsnooper(
	Phi1, Phi2, SR_toControl_s1, kernelCounterOut2_s1, 
	wordCounterOut2_s1, wordCounterOut0_s1, pixCounterOut7_s1, Reset_s1, 
	Sat_Controls_s1, c3_Phi2_q2, p3_Phi1_q1, c9_Phi1_q1, 
	c8_Phi1_q1, Input_Ready_s1, Reset_Shift_s2, No_Shift_s2, 
	Shift_Right_s2, Write_Mem_q1, Kernel_en_s1);
*/

endmodule


