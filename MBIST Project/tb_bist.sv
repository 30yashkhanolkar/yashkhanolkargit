//MBIST Top module Testbench
module tb_bist;
  
  parameter size = 6;
  parameter length = 8;
  
  logic start;
  logic rst; 
  logic clk; 
  logic csin;
  logic rwbarin; 
  logic opr;
  logic [size-1:0] address;
  logic [length-1:0] datain;
  logic [length-1:0] dataout;
  logic fail;
  
  bist #(.size(size), .length(length)) dut(.*);
  
  always #10 clk = ~clk;
  
  initial begin
    
    start = 0;
    clk = 0;
    rst = 1;       
    csin = 0;
    rwbarin = 1;  
    opr = 0;
    address = 0;
    datain = 0;

    #5;
    rst = 0; 
   
      
    $display("\nTest Case 1: Normal Mode Test ");
      
    repeat (100) begin
      csin = 1;
      rwbarin = 0;  
      address = $urandom % 64;
      datain = $urandom;
      
      @ (posedge clk);
      #10;
      
      $display("Writing %h to address %d", datain, address);

      rwbarin = 1;  
      
      #10;
      $display("Reading from address %d", address);
      
      if (dataout == datain)
        $display("PASS: Normal Mode Test - Address %d", address);
      else
        $display("FAIL: Normal Mode Test - Address %d, Expected %h, Got %h", address, datain, dataout);
    end

    $display("\nTest Case 2: BIST Mode Test");
    
    repeat (100) begin
      
      csin = 0;       
      rwbarin = 1;    
      opr = 1;
      start = 0;
       
      @ (posedge clk);
      #10;
      
      
      if (fail == 0)
        $display("PASS - Bist Mode Test");
      else
        $display("FAIL - Bist Mode Test");
      #10;
    end

    $finish;
  end
endmodule
  
  
  