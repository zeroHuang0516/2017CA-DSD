//RTL (use continuous assignment)
module alu_rtl(
    ctrl,
    x,
    y,
    carry,
    out  
);
    
    input  [3:0] ctrl;
    input  [7:0] x;
    input  [7:0] y;
    output       carry;
    output [7:0] out;
    
always@(ctrl)
begin
  case(ctrl)
    4'b0000: out = x + y;
             // carry = (x & y) |  (carry & (x ^ y))
    4'b0001: out = x - y;
    4'b0010: out = x & y;
    4'b0011: out = x | y;
    4'b0100: out = ~x;
    4'b0101: out = x ^ y;
    4'b0110: out = x ~| y;
    4'b0111: out = y << x[2:0];
    4'b1000: out = y >> x[2:0];
    4'b1001: out = {x[7],x[7:1]};
    4'b1010: out = {x[6:0] , x[7]};
    4'b1011: out = {x[0] , x[7:1]};
    4'b1100: out = (x==y)?1:0;
    4'b1101: out = 0;
    4'b1110: out = 0;
    4'b1111: out = 0;

  endcase
end

endmodule
