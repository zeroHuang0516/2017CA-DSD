module register_file(
    Clk  ,
    WEN  ,
    RW   ,
    busW ,
    RX   ,
    RY   ,
    busX ,
    busY ,
);
    input        Clk, WEN;
    input  [2:0] RW, RX, RY;
    input  [7:0] busW;
    output reg [7:0] busX, busY;
    
    // write your design here
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
