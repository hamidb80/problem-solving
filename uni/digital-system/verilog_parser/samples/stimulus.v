//////////////////////////////////////////////////////////////////////////
// Filename	: stimulus.v
// Author       : Andrew and Eliot
// Date         : 2/9/2000
// Mod:	Date:	By:	Reason:
//
//------------------------------------------------------------------------
// Description :
// This block implements the stimulus necessary to initialize the 
// SRAM with the kernel values (stored in kernel.dat) and supplies 
// the pixel bitstream to the convolution engine.
//	
//////////////////////////////////////////////////////////////////////////
 
`define NUM_KERNEL 9
`define NUM_IMAGE  9*10

// FILE1 - all the kernel values: K8 K7 K6 K5 K4 K3 K2 K1 K0.
`define	FILE1	"kernel.dat"
`define FILE2	"image.dat"

/////////////////////////////////////////////////////////////////////////////
module		stimulus(Phi1,Phi2,
			Reset_s1,
			Input_Ready_s1,
			Pixel_s1[7:0]);
/////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////
// Port Declarations
/////////////////////////////////////////////////////////////////////////////
input		Input_Ready_s1;	// - New pixel value needed

output 		Phi1,Phi2;	// - 2 phase clocks
output		Reset_s1;	// - Reset the convolution engine
output	[7:0]	Pixel_s1;	// - Pixel value to memory

reg		Phi1, Phi2;
reg		Reset_s1;
reg	[7:0]	Pixel_s1;

/////////////////////////////////////////////////////////////////////////////
// Internal Variable Declarations
/////////////////////////////////////////////////////////////////////////////
reg	[7:0]	Kernel[`NUM_KERNEL-1:0]; // kernel.dat is read into this array
reg	[7:0]	Image[`NUM_IMAGE-1:0];	 // image.dat is read into this array
reg	[20:0]	ProgCntr;        	 // Used to count cycles
reg	[1:0]	state;


/////////////////////////////////////////////////////////////////////////////
// Internal  Workings
/////////////////////////////////////////////////////////////////////////////

//------- Create a clock...--------------
always begin
   #(`period / 4) Phi1 = 1;
   #(`period / 4) Phi1 = 0;
   #(`period / 4) Phi2 = 1;
   #(`period / 4) Phi2 = 0;
end


//------- Define States -----------------
`define	RESET		2'b00
`define LOAD_KERNEL 	2'b01
`define RESET2		2'b10
`define CONVOLVE 	2'b11

//------- Load from file ----------------
initial
   begin
      				// Initialize Kernel and Image to zero.
      for (ProgCntr = 0; ProgCntr < `NUM_KERNEL; ProgCntr = ProgCntr+1)
         Kernel[ProgCntr] = 8'b0;
      for (ProgCntr = 0; ProgCntr < `NUM_IMAGE; ProgCntr = ProgCntr+1)
	 Image[ProgCntr] = 8'b0;
      
      				// $write allows text written to the 
      				// verilog session.
      $write("Reading in Kernel Values: K8 K7 K6 K5 K4 K3 K2 K1 K0\n");
      $display(`FILE1);
      				// $readmemb loads the contents of FILE 
				// into an array
      $readmemb(`FILE1, Kernel);
      $write("Reading in Image: P0 P1 P2 P3 P4 P5 P6 P7 P8\n");
      $display(`FILE2);
      $readmemh(`FILE2, Image);
      ProgCntr = 0;
      state = `RESET;
      $write("State: RESET\n");
   end


//------- State Machine -----------------
// RESET	:	Reset the 2-D C.E. 
// LOAD_KERNEL	:	Load Kernel, and 2 lines of zero
// RESET2	:	Reset again
// CONVOLVE	:	Stream in new pixels from the image

always @ (posedge Phi2)
   begin
      case (state)
	 `RESET: 
		begin
             	if (ProgCntr == 4) // Next State: LOAD_KERNEL
                 begin
   		  state = `LOAD_KERNEL;
		  // Fix initialization delay
		  ProgCntr = 0;
		  Pixel_s1 = Kernel[ProgCntr];
		  //$write("...Loaded %X, %d\n", Pixel_s1, ProgCntr);
                  ProgCntr = 1;
 		  Reset_s1 = 0;
                 end
	     	else 		// Stay in RESET, 4 cycles
                 begin
	          state = `RESET;
		  Reset_s1 = 1;
	          ProgCntr = ProgCntr + 1;
                 end
            	end

         `LOAD_KERNEL: 
		begin
                if (Input_Ready_s1)
             	 begin
		  if (ProgCntr < `NUM_KERNEL)
			begin
			Pixel_s1 = Kernel[ProgCntr];
			//$write("...Loaded %X, %d\n", Pixel_s1, ProgCntr);
             		ProgCntr = ProgCntr + 1;
			end
		  else
			begin
			Pixel_s1 = 8'b0;
			ProgCntr = ProgCntr + 1;
			end
		 end
		 
             	// Set State
             	if (ProgCntr < 28)
                	state = `LOAD_KERNEL;
             	else 	begin
			$write("Finished loading Kernel\n");
			$write("State: RESET2\n");
                	state = `RESET2;
                	ProgCntr = 0;
              		end              
            	end

	 `RESET2: 
		begin
             	if (ProgCntr == 4) // Next State: CONVOLVE
                 begin
		  $write("State: Convolving...\n");
   		  state = `CONVOLVE;
		  // Fix initialization delay
		  ProgCntr = 0;
		  Pixel_s1 = Image[ProgCntr];
                  ProgCntr = 1;
 		  Reset_s1 = 0;
                 end
	     	else 		// Stay in RESET, 4 cycles
                 begin
	          state = `RESET2;
		  Reset_s1 = 1;
	          ProgCntr = ProgCntr + 1;
                 end
            	end


         `CONVOLVE: begin
             		//---Run till we finish image---
			if (ProgCntr < `NUM_IMAGE)
			begin
			 if (Input_Ready_s1)
			   begin
			   Pixel_s1 = Image[ProgCntr];
			   //$write("Pixel_s1 = %X\n", Pixel_s1);
			   ProgCntr = ProgCntr + 1;
			   end
			end
			else  	
             		 $finish;
		    end

	 default:   begin
		    state = `RESET;
		    end
	endcase
    end
endmodule






