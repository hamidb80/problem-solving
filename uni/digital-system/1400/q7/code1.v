module BlockA(
  Clk, Reset, DataRequest, 
  Data, RegisterA, Ack
); 
  input Clk, Reset, DataRequest;
  input [7:0] RegisterA; 
  output [7:0] Data;
  output Ack;

  reg Ack;
  reg [1:0] stateA;
  reg [1:0] nextstateA;
  reg [7:0] Data;

  parameter state0 = 2'b00;
  parameter state1 = 2'b01;

  always @(posedge Clk) begin 
    if(Reset) stateA <= state0;
    else stateA <= nextstateA;
  end 

  always @(DataRequest) begin 
    case(stateA) 
      state0: 
        if(DataRequest)
          nextstateA <= state1;
        else
          nextstateA <= state0; 
    
      state1: 
        if (~DataRequest)
          nextstateA <= state0; 
        else
          nextstateA <= state1;
    
      default: nextstateA <= state0;
    endcase
  end

  always @(stateA)
    case(stateA)
      state0: begin 
        Ack <= 1'b0;
        Data <= 8'b00000000;
      end
    
      state1: begin 
        Ack <= 1'b1;
        Data <= RegisterA;
      end
    endcase 
endmodule