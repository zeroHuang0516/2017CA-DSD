//RTL (use continuous assignment)
module alu_rtl(
    ctrl,
    x,
    y,
    carry,
    out  
);
    
    input  [3:0] ctrl;
    input  signed [7:0] x;
    input  signed [7:0] y;
    output       carry;
    output signed [7:0] out;
    wire [8:0] tmp;
    wire [7:0] neg;

assign out = (ctrl == 4'b0000) ? (x + y):
                (ctrl == 4'b0001) ? (x - y):
                    (ctrl == 4'b0010) ? (x & y):
                    (ctrl == 4'b0011) ? (x | y):
                    (ctrl == 4'b0100) ? (~x):
                    (ctrl == 4'b0101) ? (x ^ y):
                    (ctrl == 4'b0110) ? (~x & ~y):
                    (ctrl == 4'b0111) ? (y << x[2:0]):
                    (ctrl == 4'b1000) ? (y >> x[2:0]):
                    (ctrl == 4'b1001) ? ({x[7],x[7:1]}):
                    (ctrl == 4'b1010) ? ({x[6:0] , x[7]}):
                    (ctrl == 4'b1011) ? ({x[0] , x[7:1]}):
                    (ctrl == 4'b1100) ? ((x==y)?1:0):
                    (ctrl == 4'b1101) ? (0):
                    (ctrl == 4'b1110) ? (0):
                    (ctrl == 4'b1111) ? (0):
                    (0);

assign neg = (ctrl == 4'b0001) ? (~y + 00000001):neg;
assign tmp = (ctrl == 4'b0000) ? ({x[7],x}+{y[7],y}):
                (ctrl == 4'b0001) ? ({x[7],x}+{neg[7],neg}):tmp;

assign carry = (ctrl == 4'b0000 || ctrl == 4'b0001) ? (tmp[8]):(carry);


endmodule
