//////////////////////////////////////////////////////////////////////////
// Filename	: stimulus.v
// Author       : Andrew and Eliot
// Date         : 2/9/2000
// Mod:	Date:	By:	Reason:
//////////////////////////////////////////////////////////////////////////
 
`define NUM_KERNEL 9
`define NUM_IMAGE  9*10
`define FILE2	"image.dat"

module stimulus(Phi1,Phi2, Reset_s1, Input_Ready_s1, Pixel_s1[7:0]);

input	Input_Ready_s1;	// - New pixel value needed
output Phi1,Phi2;	// - 2 phase clocks
reg	[7:0]	Pixel_s1;

initial
  begin
    #(`period / 4) Phi1 = 1;

    for (ProgCntr = 0; ProgCntr < `NUM_KERNEL; ProgCntr = ProgCntr+1)
      Kernel[ProgCntr] = 8'b0;

    Image[ProgCntr] = 8'b0;
    $write("Reading in Kernel Values: K8 K7 K6 K5 K4 K3 K2 K1 K0\n");
  end

always @ (posedge Phi2)
   begin
      case (state)
    	  `RESET: begin end
        `LOAD_KERNEL:	begin end
    	endcase
    end
endmodule
