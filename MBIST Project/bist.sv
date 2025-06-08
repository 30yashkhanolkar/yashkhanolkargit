// MBIST Top Module Design
module bist #(parameter size = 6, parameter length = 8) (
  
  input logic start, rst, clk, csin, rwbarin, opr,
  input logic [size-1:0] address,
  input logic [length-1:0] datain,
  output logic [length-1:0] dataout,
  output logic fail  
  
);
  
  logic[size-1:0] ramaddr, mux_addr_out;
  logic [length-1:0] data_t, ramout, ramin, mux_data_out;
  logic[9:0] d_in, q;
  logic gt, eq, lt, we, cs, cout, NbarT, ld, temp;
  
  
  comparator comp (.data_t(data_t), .ramout(ramout), .gt(gt), .eq(eq), .lt(lt));
  counter #(.length(10)) count(.d_in(d_in), .clk(clk), .ld(ld), .u_d(1'b1), .cen(NbarT), .q(q), .cout(cout));
  multiplexer #(.WIDTH(size)) MUX_A(.normal_in(address), .bist_in(q[5:0]), .NbarT(NbarT),.out(mux_addr_out));
  multiplexer #(.WIDTH(length)) MUX_D(.normal_in(datain), .bist_in(data_t), .NbarT(NbarT),.out(mux_data_out));
  decoder dec(.q(q[9:7]), .data_t(data_t));
  controller contr(.start(start), .rst(rst), .clk(clk), .cout(cout), .NbarT(NbarT), .ld(ld));
  sram sram1(.ramaddr(ramaddr), .ramin(ramin), .rwbar(we), .clk(clk), .cs(cs), .ramout(ramout));
  
  assign we = (NbarT == 1'b1) ? q[6] : rwbarin;
 
  assign cs = (NbarT == 1'b1) ? 1'b1 : csin;

  assign ramaddr = mux_addr_out;
  
  assign ramin = mux_data_out;
 
  assign temp = (NbarT == 1'b0) ? rwbarin : q[6];

  always_ff @(posedge clk) begin
      if (rst) begin
          fail <= 1'b0;
      end else begin
          fail <= (NbarT == 1'b1 && opr == 1'b1 && temp == 1'b1 && !eq) ? 1'b1 : 1'b0;
      end
  end
  
  assign dataout = ramout; 
  
endmodule

//Comparator Module
module comparator(
  
  input logic [7:0] data_t,
  input logic [7:0] ramout,
  output logic gt, eq, lt
  
);
  
  always_comb begin
    
    if (data_t > ramout) begin
      gt = 1;
      eq = 0;
      lt = 0;
    end
    
    if (data_t == ramout) begin
      gt = 0;
      eq = 1;
      lt = 0;
    end
    
    if (data_t < ramout) begin
      gt = 0;
      eq = 0;
      lt = 1;
    end
    
  end
  
endmodule

//Counter Module
module counter #(parameter length = 10) (
  
  input logic [length-1:0] d_in,
  input logic clk, ld, u_d, cen,
  output logic [length-1:0] q,
  output logic cout
  
);
  
  logic [length:0] counter_reg;
  
  assign q = counter_reg[length-1:0];
  assign cout = counter_reg[length];
  
  always_ff @ (posedge clk) begin
    
    if (cen) begin
      
      if (ld) begin
        counter_reg <= {1'b0, d_in};
      end
      
      else begin
        if (u_d) begin
          counter_reg <= counter_reg + 1;
        end 
        
        else begin
          counter_reg <= counter_reg - 1;
        end
      end
    end
    
    end
  
endmodule

//Multiplexer module
module multiplexer #(parameter WIDTH = 8) (
  
  input logic [WIDTH-1:0] normal_in,
  input logic [WIDTH-1:0] bist_in,
  input logic NbarT,
  output logic [WIDTH-1:0] out
               
               
);
  
  assign out = (NbarT == 1'b1) ? bist_in : normal_in;
  
endmodule

//Decoder Module
module decoder(
  
  input logic [2:0] q,
  output logic [7:0] data_t
  
);
  
  always_comb begin
    
    case (q)
      3'b000: data_t = 8'b10101010;
      3'b001: data_t = 8'b01010101;
      3'b010: data_t = 8'b11110000;
      3'b011: data_t = 8'b00001111;
      3'b100: data_t = 8'b00000000;
      3'b101: data_t = 8'b11111111;
      default: data_t = 8'bx;
      
    endcase
      
    end
  
endmodule


//Controller Module
module controller (
  
  input  logic start, rst, clk, cout,
  output logic NbarT, ld
 
);

 
  typedef enum logic {RESET, TEST} state;
  
  state current_state, next_state;

 
  always_ff @(posedge clk or posedge rst) begin
    
    if (rst) begin
      current_state <= RESET;
    end
    else begin
      current_state <= next_state;
    end
  
  end

  always_comb begin
    
    case (current_state)
      
      RESET: begin
        if (start) begin
  			next_state = TEST;
		end 
        else begin
 		    next_state = RESET;
        end
end
      
      TEST:  begin
        if (cout) begin
 		    next_state = RESET;
		end 
        else begin
  			next_state = TEST;
        end
end
      
      default: next_state = RESET;
      
    endcase
  end

  assign NbarT = (current_state == TEST) ? 1'b1 : 1'b0;
  assign ld = (current_state == RESET) ? 1'b1 : 1'b0;

endmodule

//SRAM Module
module sram(
  
  input logic [5:0] ramaddr,
  input logic [7:0] ramin,
  input logic rwbar, clk, cs,
  output logic [7:0] ramout
  
);
  
  logic [7:0] ram [63:0];
  logic [5:0] addr_reg;
  
  always_ff @(posedge clk ) begin
    
    if (cs) begin 
    	addr_reg <= ramaddr;
    end
    
    if (cs && !rwbar) begin
      ram[ramaddr] <= ramin;
    end
    
    
    
  end
  
  assign ramout = (cs && rwbar) ? ram[addr_reg] : 8'b0 ;
  
endmodule



