module pipeline_2(
    input clk, 
    input [7:0] a, b, c, d, e, 
    output reg [15:0] f
  );

  reg [7:0] c_d, temp1, temp2, temp3, temp3_d;
  // assign f = (( a | b) + c) * (d & e);
  always @ ( posedge clk) begin
    temp1 <= a | b;
    c_d <= c;
    temp2 <= temp1 + c_d;
    temp3 <= d & e;
    temp3_d <= temp3;
    f <= temp2 * temp3_d;
  end
endmodule

