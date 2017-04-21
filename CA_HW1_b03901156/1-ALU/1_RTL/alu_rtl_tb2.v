//rtl_tb
`timescale 1ns/10ps
`define CYCLE  10
`define HCYCLE  5

module alu_rtl_tb;
    reg  [3:0] ctrl;
    reg  [7:0] x;
    reg  [7:0] y,true_out,neg;
    reg  [8:0] tmp;
    reg        true_carry;
    wire       carry;
    wire [7:0] out;
integer i,j;
    alu_rtl alu1(
        ctrl     ,
        x        ,
        y        ,
        carry    ,
        out  
    );

   initial begin
       $dumpfile("alu_rtl.vcd");
       $dumpvars;
//        $fsdbDumpfile("alu_rtl.fsdb");
//        $fsdbDumpvars;
   end

    initial begin
        ctrl = 4'b1101;
        x    = 8'd0;
        y    = 8'd0;
                
        // test for Add
        #(`CYCLE);
        ctrl = 4'b0000;
        for(i=0;i<256;i=i+1)
        begin
          for(j=0;j<256;j=j+1)
          begin
          x=i[7:0];y=j[7:0];
          #20  true_out=x+y; tmp ={x[7],x}+{y[7],y}; true_carry=tmp[8];
             if(out !== true_out[7:0]) 
             begin
               $display(" %b + %b should be %b. But your output is %b",x,y,true_out,out);
             end 
             else $display( "ADD ----- PASS" );
             if(carry !== true_carry) 
             begin
               $display(" %b + %b's carry should be %b. But your output is %b",x,y,true_carry,carry);
             end 
             else $display( "ADD_carry ----- PASS" );
          end                          
       end

       // test for Sub
       #(`CYCLE);
        ctrl = 4'b0001;
        for(i=0;i<256;i=i+1)
        begin
            for(j=0;j<256;j=j+1)
            begin
            x=i[7:0];y=j[7:0];
            #20 
             
             neg = ~y + 00000001;
             tmp ={x[7],x}+{neg[7],neg};
             true_carry = tmp[8];
             true_out=tmp[7:0];
             if(out !== true_out[7:0]) 
             begin
               $display("%b - %b should be %b. But your output is %b.",x,y,true_out,out);
             end 
             else $display( "SUB ----- PASS" );
             if(carry !== true_carry) 
             begin
               $display(" %b - %b's carry should be %b. But your output is %b",x,y,true_carry,carry);
             end 
             else $display( "SUB_carry ----- PASS" );                          
            end
        end

        // test for AND
       #(`CYCLE);
        ctrl = 4'b0010;
        for(i=0;i<256;i=i+1)
        begin
            for(j=0;j<256;j=j+1)
            begin
            x=i[7:0];y=j[7:0];
            #20 true_out=x & y;
             if(out !== true_out[7:0]) 
             begin
               $display("%b & %b should be %b. But your output is %b.",x,y,true_out,out);
             end
             else $display( "AND ----- PASS" );                            
            end
        end  

        // test for OR
       #(`CYCLE);
        ctrl = 4'b0011;
        for(i=0;i<256;i=i+1)
        begin
            for(j=0;j<256;j=j+1)
            begin
            x=i[7:0];y=j[7:0];
            #20 true_out=x | y;
             if(out !== true_out[7:0]) 
             begin
               $display("%b | %b should be %b. But your output is %b.",x,y,true_out,out);
             end
             else $display( "OR ----- PASS" );                            
            end
        end

        // test for NOT
       #(`CYCLE);
        ctrl = 4'b0100;
        for(i=0;i<256;i=i+1)
        begin
         x=i[7:0];
         #20 true_out=~x;
             if(out !== true_out[7:0]) 
             begin
               $display("~ %b should be %b. But your output is %b.",x,true_out,out);
             end 
             else $display( "NOT ----- PASS" );                             
        end


        // test for XOR
       #(`CYCLE);
        ctrl = 4'b0101;
        for(i=0;i<256;i=i+1)
        begin
            for(j=0;j<256;j=j+1)
            begin
            x=i[7:0];y=j[7:0];
            #20 true_out=x ^ y;
             if(out !== true_out[7:0]) 
             begin
               $display("%b ^ %b should be %b. But your output is %b.",x,y,true_out,out);
             end
             else $display( "XOR ----- PASS" );                            
            end
        end

        // test for NOR
       #(`CYCLE);
        ctrl = 4'b0110;
        for(i=0;i<256;i=i+1)
        begin
            for(j=0;j<256;j=j+1)
            begin
            x=i[7:0];y=j[7:0];
            #20 true_out=~x & ~y;
             if(out !== true_out[7:0]) 
             begin
               $display("%b ~| %b should be %b. But your output is %b.",x,y,true_out,out);
             end
             else $display( "NOR ----- PASS" );                            
            end
        end

        // test for Shift left logical variable
       #(`CYCLE);
        ctrl = 4'b0111;
        for(i=0;i<256;i=i+1)
        begin
            for(j=0;j<256;j=j+1)
            begin
            x=i[7:0];y=j[7:0];
            #20 true_out=y << x[2:0];
             if(out !== true_out[7:0]) 
             begin
               $display("%b << %b[2:0] should be %b. But your output is %b.",y,x,true_out,out);
             end
             else $display( "Shift left ----- PASS" );                            
            end
        end

        // test for Shift right logical variable
       #(`CYCLE);
        ctrl = 4'b1000;
        for(i=0;i<256;i=i+1)
        begin
            for(j=0;j<256;j=j+1)
            begin
            x=i[7:0];y=j[7:0];
            #20 true_out=y >> x[2:0];
             if(out !== true_out[7:0]) 
             begin
               $display("%b >> %b[2:0] should be %b. But your output is %b.",y,x,true_out,out);
             end
             else $display( "Shift right ----- PASS" );                            
            end
        end

        // test for Shift right arithmetic
       #(`CYCLE);
        ctrl = 4'b1001;
        for(i=0;i<256;i=i+1)
        begin
         x=i[7:0];
         #20 true_out={x[0] , x[7:1]};
             if(out !== true_out[7:0]) 
             begin
               $display("Shift right arithmetic of %b should be %b. But your output is %b.",x,true_out,out);
             end 
             else $display( "Shift right arithmetic ----- PASS" );                             
        end

        // test for Rotate left
       #(`CYCLE);
        ctrl = 4'b1010;
        for(i=0;i<256;i=i+1)
        begin
         x=i[7:0];
         #20 true_out={x[6:0] , x[7]};
             if(out !== true_out[7:0]) 
             begin
               $display("Rotate left of %b should be %b. But your output is %b.",x,true_out,out);
             end 
             else $display( "Rotate left arithmetic ----- PASS" );                             
        end

        // test for Rotate right
       #(`CYCLE);
        ctrl = 4'b1011;
        for(i=0;i<256;i=i+1)
        begin
         x=i[7:0];
         #20 true_out={x[0] , x[7:1]};
             if(out !== true_out[7:0]) 
             begin
               $display("Rotate right of %b should be %b. But your output is %b.",x,true_out,out);
             end 
             else $display( "Rotate right arithmetic ----- PASS" );                             
        end


        // test for EQUAL
       #(`CYCLE);
        ctrl = 4'b1100;
        for(i=0;i<256;i=i+1)
        begin
            for(j=0;j<256;j=j+1)
            begin
            x=i[7:0];y=j[7:0];
            #20 true_out= (x==y)?1:0;
             if(out !== true_out[7:0]) 
             begin
               $display("%b equal %b should be %b. But your output is %b.",x,y,true_out,out);
             end
             else $display( "equal ----- PASS" );                            
            end
        end

        // test for 4'b1101
       #(`CYCLE);
        ctrl = 4'b1101;
        for(i=0;i<256;i=i+1)
        begin
            for(j=0;j<256;j=j+1)
            begin
            #20 true_out= 0;
             if(out !== true_out[7:0]) 
             begin
               $display("output should be %b. But your output is %b.",true_out,out);
             end
             else $display( "4'b1101 ----- PASS" );                            
            end
        end

        // test for 4'b1110
       #(`CYCLE);
        ctrl = 4'b1110;
        for(i=0;i<256;i=i+1)
        begin
            for(j=0;j<256;j=j+1)
            begin
            #20 true_out= 0;
             if(out !== true_out[7:0]) 
             begin
               $display("output should be %b. But your output is %b.",true_out,out);
             end
             else $display( "4'b1110 ----- PASS" );                            
            end
        end

        // test for 4'b1111
       #(`CYCLE);
        ctrl = 4'b1111;
        for(i=0;i<256;i=i+1)
        begin
            for(j=0;j<256;j=j+1)
            begin
            #20 true_out= 0;
             if(out !== true_out[7:0]) 
             begin
               $display("output should be %b. But your output is %b.",true_out,out);
             end
             else $display( "4'b1111 ----- PASS" );                            
            end
        end
        
        // finish tb
        #(`CYCLE) $finish;
    end

endmodule
