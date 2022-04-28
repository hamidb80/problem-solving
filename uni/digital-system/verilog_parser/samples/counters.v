// Andrew and Eliot
// 1/19/2000
// EE272

// Name:  counters.v
// Desc:  8,9, and 3- stage Ring Counters built from flops 
// Hier:  control.v
// Mod:   Date	By	Reason
//	1/24	AF	Removed flop instantiation (sim errors)
//	1/25	AF	Instantiated all counters to separate
//			them from rest of control logic


/***************************************************************
* All Counters:  These will be layed out by hand w/ wrapshifter
***************************************************************/
module counters(c8_Phi1_q1, c8_Phi2_q2, c9_Phi1_q1, c9_Phi2_q2, 
		c3_Phi1_q1, c3_Phi2_q2, p3_Phi1_q1, p3_Phi2_q2,
		count8_s1[7:0], count9_s1[8:0], 
		count3_s1[2:0], mempoint3_s1[2:0], 
		wrapout_s1[8:0], Reset_s1);

// Declare signals
//-------------------------------------------------------------
 input c9_Phi1_q1, c9_Phi2_q2;
 input c8_Phi1_q1, c8_Phi2_q2; 
 input c3_Phi1_q1, c3_Phi2_q2;
 input p3_Phi1_q1, p3_Phi2_q2;
 input Reset_s1;
 output [7:0] count8_s1;
 output [8:0] count9_s1;
 output [8:0] wrapout_s1;
 output [2:0] count3_s1;
 output [2:0] mempoint3_s1;


// Instantiate counters
//-------------------------------------------------------------
 counter9 WordLineCounter (c9_Phi1_q1, c9_Phi2_q2, count9_s1[8:0],
			   Reset_s1);

 counter8 PixMuxCounter (c8_Phi1_q1, c8_Phi2_q2, 
			  count8_s1[7:0], Reset_s1);

 counter3 KernelMuxCounter (c3_Phi1_q1, c3_Phi2_q2, 
			    count3_s1[2:0], Reset_s1);

 counter3 Memory_Pointer (p3_Phi1_q1, p3_Phi2_q2, 
			  mempoint3_s1[2:0], Reset_s1);

// The 3 bit counter, count3, provides the control signals for
//  wrapshifter and the 9 bit counter (the wordline control) 
//  provides the input.
//-------------------------------------------------------------
 
 wrapshifter shifter (count3_s1[2:0], count9_s1[8:0],
		      wrapout_s1[8:0]);

// The output of the wrap shifter goes directly to memory: we 
//  don't qualify it here, on in the control block, because the
//  write drivers have a 3-NAND gate which will be used for 
//  qualification. 

endmodule



/***************************************************************
* 8 Bit Counter:  (Ring Counter, Initialized to 1)
***************************************************************/
module counter8(Phi1, Phi2, state_s1[7:0], Reset_s1);

 input Phi1, Phi2;
 input Reset_s1;
 output [7:0] state_s1;

 reg [7:0] state_s1;
 reg [7:0] state_s2;

always @ (Phi1 or state_s1 or Reset_s1)
begin
if (Phi1)
 begin
  if (Reset_s1)
     state_s2 = 8'b1;		
  else 
     begin
	state_s2[7:1] = state_s1[6:0];
 	state_s2[0] = state_s1[7];
     end
 end
end

always @ (Phi2 or state_s2)
begin
 if(Phi2)
    state_s1 = state_s2;
end

endmodule


/***************************************************************
* 9 Bit Counter:  (Ring Counter, Initialized to 1_0000_0000)
***************************************************************/
module counter9(Phi1, Phi2, state_s1[8:0], Reset_s1);

 input Phi1, Phi2;
 input Reset_s1;
 output [8:0] state_s1;

 reg [8:0] state_s1;
 reg [8:0] state_s2;

always @ (Phi1 or state_s1 or Reset_s1)
begin
if (Phi1)
 begin
  if (Reset_s1)
     state_s2 = 9'b100000000;		
  else 
     begin
	state_s2[7:0] = state_s1[8:1];
 	state_s2[8] = state_s1[0];
     end
 end
end

always @ (Phi2 or state_s2)
begin
 if(Phi2)
    state_s1 = state_s2;
end

endmodule


/***************************************************************
* 3 Bit Counter:  (Ring Counter, Initialized to 1)
***************************************************************/
module counter3(Phi1, Phi2, state_s1[2:0], Reset_s1);

 input Phi1, Phi2;
 input Reset_s1;
 output [2:0] state_s1;

 reg [2:0] state_s1;
 reg [2:0] state_s2;

always @ (Phi1 or state_s1 or Reset_s1)
begin
if (Phi1)
 begin
  if (Reset_s1)
     state_s2 = 3'b1;		
  else 
     begin
	state_s2[2:1] = state_s1[1:0];
 	state_s2[0] = state_s1[2];
     end
 end
end

always @ (Phi2 or state_s2)
begin
 if(Phi2)
    state_s1 = state_s2;
end

endmodule


/***************************************************************
* WrapShifter:  Shifts Right 0,1,2 positions (and wraps lsb to 
*               msb)
***************************************************************/
module wrapshifter(shiftcontrol_s1[2:0], instate_s1[8:0], outstate_s1[8:0]);

 input [2:0] shiftcontrol_s1;
 input [8:0] instate_s1;
 output [8:0] outstate_s1;

 wire [2:0] shiftcontrol_s1;
 wire [8:0] instate_s1; 
 reg  [8:0] outstate_s1;

`define shiftright2  3'b001
`define shiftright1  3'b010
`define	noshift      3'b100

always @(instate_s1 or shiftcontrol_s1)
 
  case (shiftcontrol_s1)

	`noshift   :	 outstate_s1 = instate_s1;
	
	`shiftright1  :	
			begin
			 outstate_s1[7:0] = instate_s1[8:1];
			 outstate_s1[8] = instate_s1[0];
			end

	`shiftright2  :
			begin
			 outstate_s1[6:0] = instate_s1[8:2];
			 outstate_s1[8:7] = instate_s1[1:0];
			end

	default    :	 outstate_s1 = instate_s1;
  endcase

endmodule





