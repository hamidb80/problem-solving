module detector_1101_stops_by_1000 (
  input clk, 
  input new_bit,
  output detected,
);

  reg [2:0] state;

  always @(posedge clk) begin
    case (state)
      0: begin
        if (new_bit) state = 1;
      end
      1: begin
        if (new_bit) state = 2;
        else state = 5;
      end
      2: begin
        if (~new_bit) state = 3;
      end
      3: begin
        if (new_bit) state = 4;
        else state = 6;
      end
      4: begin
        if (new_bit) state = 2;
        else state = 5;
      end
      5: begin
        if (new_bit) state = 1;
        else state = 6;
      end
      6: begin
        if (new_bit) state = 1;
        else state = 7;
      end
      7: begin end // do nothing
    endcase
  end

  assign detected = state == 4;

endmodule