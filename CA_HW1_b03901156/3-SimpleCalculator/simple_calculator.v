module simple_calculator(
    Clk,
    WEN,
    RW,
    RX,
    RY,
    DataIn,
    Sel,
    Ctrl,
    busY,
    Carry
);

    input        Clk;
    input        WEN;
    input  [2:0] RW, RX, RY;
    input  [7:0] DataIn;
    input        Sel;
    input  [3:0] Ctrl;
    output [7:0] busY;
    output       Carry;

//==== reg/wire definition ====
	reg signed [7:0] x;
	reg [7:0] busY, busX;
	reg Carry;
	reg signed [7:0] busW;
	reg [8:0] tmp;
    reg [7:0] neg;
	
    
// submodule instantiation
 	always@(DataIn or busX or Sel) begin
 		case(Sel)
 			1'b0: x = DataIn;
 			1'b1: x = busX;
 		endcase
 	end 

// combinational part
	always@(Ctrl,x,busY)
	begin
	  case(Ctrl)
	    4'b0000: begin
	    	tmp ={x[7],x}+{busY[7],busY};
	    	Carry = tmp[8];
	    	busW = x+busY;
	    end
	    4'b0001: begin
	    	neg = ~busY + 00000001;
	    	tmp ={x[7],x}+{neg[7],neg};
	    	Carry = tmp[8];
	    	busW = x-busY;
	    end
	    4'b0010: busW = x & busY;
	    4'b0011: busW = x | busY;
	    4'b0100: busW = ~x;
	    4'b0101: busW = x ^ busY;
	    4'b0110: busW = ~x & ~busY;
	    4'b0111: busW = busY << x[2:0];
	    4'b1000: busW = busY >> x[2:0];
	    4'b1001: busW = {x[7],x[7:1]};
	    4'b1010: busW = {x[6:0] , x[7]};
	    4'b1011: busW = {x[0] , x[7:1]};
	    4'b1100: busW = (x==busY)?1:0;
	    4'b1101: busW = 0;
	    4'b1110: busW = 0;
	    4'b1111: busW = 0;
	  endcase
	end

  
//==== sequential circuit ====
	reg [7:0] registers[7:0];

    always@(posedge Clk) begin
    	if(WEN)
    	  registers[RW] <= busW;
    end

    always@(RX or registers[RX])begin
    	if(RX == 0) busX <= 0;
    	else busX <= registers[RX];
    end
    always@(RY or registers[RY])begin
    	if(RY == 0) busY <= 0;
    	else busY <= registers[RY];
    end

endmodule
