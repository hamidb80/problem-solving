// Andrew and Eliot
// 1/31/2000
// EE272
//Name      : regfile.v
//Author    : 271 - 272 Hybrid
//Mod:	Date	By	Reason
//	1/31	AF	Re-use 271 code to handle SRAM 
//			(added input/output mux and pixmux also)
//	2/12	AF	Made Kernel_Bus_b to reflect actual layout
//
//Block Description :
//	This block models the SRAM memory and surrounding muxes
//
// SRAM memory:
// It has 9 columns of 24 bits.  Output is memory_v1.
//
// Controls: wordnum_s1
// Inputs: pixel_v1[7:0], Write_Mem_q1, wrapout_s1[8:0] 
// Outputs: Kernel_Bus_b_s1[7:0], pixel_bit0_s1,
//		 pixel_bit1_s1, pixel_bit2_s1


////////////////////////////////////////////////////////////////////////////
module		regfile(
			reset_s1, 
			Write_Mem_q1, 
			wrapout_s1,
			pixel_s1, 
			Mem_Pointer_s1, 
			Pix_Mux_s1,
			Word_Line_q1[8:0], 
			Kernel_Bus_b_v1, 
			pixel_bit0_v1, pixel_bit1_v1, pixel_bit2_v1, 
			phi1, phi2);
////////////////////////////////////////////////////////////////////////////




////////////////////////////////////////////////////////////////////////////
// Port Declarations
////////////////////////////////////////////////////////////////////////////

input		phi1,phi2;	// - 2 phase clocks
input		reset_s1;	// - When reset is high, the counters are 
				//   initialized and when reset is low the
				//   kernel is loaded and convolution proceeds.
input		Write_Mem_q1;	// - Read/Write enable for table 1: 
				//   0 if read, 1 if write.
input	[7:0]	pixel_s1;	// - Pixel input to chip
input 	[8:0]	wrapout_s1;	// - control signals from counters.v that
				//   raises the appropriate wordline.
input   [2:0]   Mem_Pointer_s1;	// - control signal for memory pointer
input   [7:0]   Pix_Mux_s1;	// - selects which bit of the pixel we present
				//   to the datapath as pixel_bit*

output  [8:0]	Word_Line_q1;	// - SRAM word lines (qualified) are
				//   passed to DP as possible Kernel_Latch
				//   clocks.
output	[7:0]	Kernel_Bus_b_v1;// - 1st Row of SRAM data
output		pixel_bit0_v1,	// - Bits of pixel values in the 3 rows
		pixel_bit1_v1,  //   of memory, ANDed in datapath with kernel
		pixel_bit2_v1;  //   for multiplication


/////////////////////////////////////////////////////////////////////////////
// Internal Variable Declarations
/////////////////////////////////////////////////////////////////////////////

wire	[8:0]	wordnum_s1;	// - Selects wordlines (address) in memory
reg 	[23:0]  pixelcol_v1;	// - Output of SRAM
reg 	pixtmp0_v1, pixtmp1_v1, // - Output of Pix_Mux (selects bit in pixel)
	pixtmp2_v1;		
reg	pixel_bit0_v1,		// - Output of reordering, (mem_pointer)
	pixel_bit1_v1,		//   and pix_mux
	pixel_bit2_v1;

//SRAM  Variable Declarations
// The following declarations hold the data written to the SRAM during
// initialization.

reg	[23:0]	memory_v1[8:0];

reg	[4:0]	decodenum_s1;	
wire 	[23:0]	memtemp_v1;

assign wordnum_s1 = wrapout_s1;	// Qualification for SRAM is done later
assign Word_Line_q1[0] = wrapout_s1[0] & phi1; 	// Qualified for kernel latch
assign Word_Line_q1[1] = wrapout_s1[1] & phi1;  // Qualified for kernel latch
assign Word_Line_q1[2] = wrapout_s1[2] & phi1;	// Qualified for kernel latch
assign Word_Line_q1[3] = wrapout_s1[3] & phi1;	// Qualified for kernel latch
assign Word_Line_q1[4] = wrapout_s1[4] & phi1;	// Qualified for kernel latch
assign Word_Line_q1[5] = wrapout_s1[5] & phi1;	// Qualified for kernel latch
assign Word_Line_q1[6] = wrapout_s1[6] & phi1;	// Qualified for kernel latch
assign Word_Line_q1[7] = wrapout_s1[7] & phi1;	// Qualified for kernel latch
assign Word_Line_q1[8] = wrapout_s1[8] & phi1;	// Qualified for kernel latch

// Convert the wordline selector back to a decimal value so that it may be 
// used in an array.  This logic is only needed in verilog and won't be 
// implemented in layout.  
always @(wordnum_s1)
   begin
      case (wordnum_s1)
         9'b000000001: decodenum_s1 = 8;
	 9'b000000010: decodenum_s1 = 7; 
	 9'b000000100: decodenum_s1 = 6; 
	 9'b000001000: decodenum_s1 = 5; 
	 9'b000010000: decodenum_s1 = 4; 
	 9'b000100000: decodenum_s1 = 3; 
	 9'b001000000: decodenum_s1 = 2; 
	 9'b010000000: decodenum_s1 = 1;
	 9'b100000000: decodenum_s1 = 0;
// The default case occurs when no wordline is selected.
         default: decodenum_s1 = 16;
      endcase
   end 

always @ (phi1 or decodenum_s1 or pixelcol_v1 or Write_Mem_q1)
  if (phi1)
    begin
	// Write pixel values to SRAM 
        // Note: this line violates strict two-phase clocking
       if (Write_Mem_q1 == 1'b1) 
	begin
          memory_v1[decodenum_s1] = pixelcol_v1;
        end
    end

// Read from SRAM (Base)
//----------------------------------------------------------------
assign memtemp_v1 = ~Write_Mem_q1 ? memory_v1[decodenum_s1] : 24'bz;
assign Kernel_Bus_b_v1 = ~memtemp_v1[23:16];


// Route input to appropriate row of memory, we only overwrite the
//  row which Mem_Pointer tells us is the oldest.  (This doesn't
//  model layout exactly, but the idea is the same)  ie: in layout
//  because all rows except the one being written to have a high
//  impedance input, they retain their old value.
// Include Pix_Mux_s1 in sensitivity list to load pixelcol_v1 just
//  before every write to mem, regardless if pixel_s1 or 
//  Mem_Pointer_s1 has changed or not.
//----------------------------------------------------------------
always @ (Mem_Pointer_s1 or pixel_s1 or Pix_Mux_s1)
 begin
  if (Pix_Mux_s1[7])
   begin
   case (Mem_Pointer_s1)
   3'b001: begin
	   pixelcol_v1[23:16] = pixel_s1;
	   pixelcol_v1[15:8] = memtemp_v1[15:8];
	   pixelcol_v1[7:0]  = memtemp_v1[7:0];
	   end

   3'b010: begin
	   pixelcol_v1[23:16] = memtemp_v1[23:16];
	   pixelcol_v1[15:8] = pixel_s1;
	   pixelcol_v1[7:0]  = memtemp_v1[7:0];
	   end

   3'b100: begin
	   pixelcol_v1[23:16] = memtemp_v1[23:16];
	   pixelcol_v1[15:8] = memtemp_v1[15:8];
	   pixelcol_v1[7:0]  = pixel_s1;
	   end

   default: pixelcol_v1 =   memtemp_v1;		// nothing new is written
   endcase
   end
 end


// Mux the output, so we recover only one bit per row on a read
// ------------------------------------------------------------
always @ (Pix_Mux_s1 or memtemp_v1)
 begin
   case (Pix_Mux_s1)
   8'b00000001: begin
		 pixtmp0_v1 = memtemp_v1[16];
    		 pixtmp1_v1 = memtemp_v1[8];
		 pixtmp2_v1 = memtemp_v1[0];
		 end

   8'b00000010: begin
		 pixtmp0_v1 = memtemp_v1[17];
    		 pixtmp1_v1 = memtemp_v1[9];
		 pixtmp2_v1 = memtemp_v1[1];
		 end

   8'b00000100: begin
		 pixtmp0_v1 = memtemp_v1[18];
    		 pixtmp1_v1 = memtemp_v1[10];
		 pixtmp2_v1 = memtemp_v1[2];
		 end
	
   8'b00001000: begin
		 pixtmp0_v1 = memtemp_v1[19];
    		 pixtmp1_v1 = memtemp_v1[11];
		 pixtmp2_v1 = memtemp_v1[3];
		 end

   8'b00010000: begin
		 pixtmp0_v1 = memtemp_v1[20];
    		 pixtmp1_v1 = memtemp_v1[12];
		 pixtmp2_v1 = memtemp_v1[4];
		 end

   8'b00100000: begin
		 pixtmp0_v1 = memtemp_v1[21];
    		 pixtmp1_v1 = memtemp_v1[13];
		 pixtmp2_v1 = memtemp_v1[5];
		 end

   8'b01000000: begin
		 pixtmp0_v1 = memtemp_v1[22];
    		 pixtmp1_v1 = memtemp_v1[14];
		 pixtmp2_v1 = memtemp_v1[6];
		 end

   8'b10000000: begin
		 pixtmp0_v1 = memtemp_v1[23];
    		 pixtmp1_v1 = memtemp_v1[15];
		 pixtmp2_v1 = memtemp_v1[7];
		 end
	
   default:      begin
		 pixtmp0_v1 = 1'bz;
		 pixtmp1_v1 = 1'bz;
	         pixtmp2_v1 = 1'bz;
		 end
   endcase
 end 

// Sort the temporary pixel bits so that the rows are re-ordered
// based on the value of the memory pointer
always @ (Mem_Pointer_s1 or pixtmp0_v1 or pixtmp1_v1 or pixtmp2_v1)
 begin
   case (Mem_Pointer_s1)
	3'b001:	begin
		pixel_bit0_v1 = pixtmp0_v1;	// Normal ordering.
		pixel_bit1_v1 = pixtmp1_v1;
		pixel_bit2_v1 = pixtmp2_v1;
		end

	3'b010:	begin
		pixel_bit0_v1 = pixtmp1_v1;	// 2nd row filled.
		pixel_bit1_v1 = pixtmp2_v1;
		pixel_bit2_v1 = pixtmp0_v1;
		end

	3'b100:	begin
		pixel_bit0_v1 = pixtmp2_v1;	// 3rd row filled.
		pixel_bit1_v1 = pixtmp0_v1;
		pixel_bit2_v1 = pixtmp1_v1;
		end

	default: begin
		 pixel_bit0_v1 = 1'bz;
		 pixel_bit1_v1 = 1'bz;
		 pixel_bit2_v1 = 1'bz;
		 end
   endcase
 end

// Note:  This is ordering is fine for now, but on the bigger picture, 
//         it is confusing to visualize.  It would be clearer if pixel_bit0
//         corresponded to the bottom row of the kernel, pixel_bit1 to the
//         middle, and pixel_bit2 to the top.  Then we could imagine we 
//         were feeding in values in the bottom row of the image, and 
//         those values then got shifted up.



// End of SRAM Memory
endmodule // memory


