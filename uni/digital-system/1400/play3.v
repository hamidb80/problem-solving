module fileWriter;
  integer handle1, handle2, handle3;
  integer desc1, desc2, desc3;
  
  initial begin
    handle1 = $fopen("fileA.txt");
    handle2 = $fopen("fileB.txt");
    handle3 = $fopen("fileC.txt");
    
    desc1 = 1 | handle1;
    desc2 = 1 | handle2;
    desc3 = 1 | handle3;

    $fdisplay(desc1, "997");
    $fdisplay(desc2, "514");
    $fdisplay(desc3, "001");
  end
endmodule
