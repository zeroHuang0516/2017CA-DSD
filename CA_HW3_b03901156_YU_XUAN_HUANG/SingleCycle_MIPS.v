// Single Cycle MIPS
//=========================================================
// Input/Output Signals:
// positive-edge triggered         clk
// active low asynchronous reset   rst_n
// instruction memory interface    IR_addr, IR
// output for testing purposes     RF_writedata  
//=========================================================
// Wire/Reg Specifications:
// control signals             MemToReg, MemRead, MemWrite, 
//                             RegDST, RegWrite, Branch, 
//                             Jump, ALUSrc, ALUOp
// ALU control signals         ALUctrl
// ALU input signals           ALUin1, ALUin2
// ALU output signals          ALUresult, ALUzero
// instruction specifications  r, j, jal, jr, lw, sw, beq
// sign-extended signal        SignExtend
// MUX output signals          MUX_RegDST, MUX_MemToReg, 
//                             MUX_Src, MUX_Branch, MUX_Jump
// registers input signals     Reg_R1, Reg_R2, Reg_W, WriteData 
// registers                   Register
// registers output signals    ReadData1, ReadData2
// data memory contral signals CEN, OEN, WEN
// data memory output signals  ReadDataMem
// program counter/address     PCin, PCnext, JumpAddr, BranchAddr
//=========================================================

module SingleCycle_MIPS( 
    clk,
    rst_n,
    IR_addr,
    IR,
    RF_writedata,
    ReadDataMem,
    CEN,
    WEN,
    A,
    ReadData2,
    OEN
);

//==== in/out declaration =================================
    //-------- processor ----------------------------------
    input         clk, rst_n;
    input  [31:0] IR;
    output [31:0] IR_addr, RF_writedata;
    //-------- data memory --------------------------------
    input  [31:0] ReadDataMem;  // read_data from memory
    output        CEN;  // chip_enable, 0 when you read/write data from/to memory
    output        WEN;  // write_enable, 0 when you write data into SRAM & 1 when you read data from SRAM
    output  [6:0] A;  // address
    output [31:0] ReadData2;  // write_data to memory
    output        OEN;  // output_enable, 0

//==== reg/wire declaration ===============================
// control signals             
    wire          MemToReg,
                  MemRead,
                  MemWrite,
                  RegDST,
                  RegWrite,
                  Branch,
                  Jump,
                  ALUSrc,
                  JumpRegister,
                  JumpAndLink;
    wire  [1:0]   ALUOp;
// ALU control signals         
    wire  [3:0]   ALUctrl;
// ALU input signals           
    wire  [31:0]  ALUin1, 
                  ALUin2;
// ALU output signals          
    wire  [31:0]  ALUresult;
    wire          ALUzero;
// sign-extended signal        
    wire  [31:0]  SignExtend;
// MUX output signals          
    wire  [4:0]   MUX_RegDST;
    wire  [31:0]  MUX_MemToReg; 
    wire  [31:0]  MUX_Src;
    wire  [31:0]  MUX_Branch; 
    wire  [31:0]  MUX_Jump;
// registers input signals     
    wire  [4:0]   Reg_R1, Reg_R2, Reg_W;
    wire  [31:0]  WriteData; 
// registers output signals    
    wire  [31:0]  ReadData1;
// program counter/address     
    wire  [31:0]  PCin;
    wire  [31:0]  PCnext;
    wire  [31:0]  PCAdd4;
    wire  [31:0]  JumpAddr; 
    wire  [31:0]  BranchAddr;

//******connection******//
assign RF_writedata = WriteData; // for debug
assign PCin = PCnext;

PC _PC(
    .clk(clk),
    .rst(rst_n),
    .PCin(PCin),
    .PCout(IR_addr)
);

mainControl _mainControl(
    .opcode_i(IR[31:26]),
    .funct_i(IR[5:0]),
    .RegDst_o(RegDST),
    .Jump_o(Jump),
    .Branch_o(Branch),
    .MemRead_o(MemRead),
    .MemToReg_o(MemToReg),
    .ALUOp_o(ALUOp),
    .MemWrite_o(MemWrite),
    .ALUSrc_o(ALUSrc),
    .RegWrite_o(RegWrite),
    .JumpRegister_o(JumpRegister),
    .JumpAndLink_o(JumpAndLink)
);

assign ALUin1 = ReadData1;
assign ALUin2 = MUX_Src;
assign A = ALUresult[8:2]; // A = LSB of (ALUresult >> 2)

ALU _ALU(
    .ALUCtrl_i(ALUctrl), 
    .data1_i(ALUin1), 
    .data2_i(ALUin2), 
    .ALU_o(ALUresult), 
    .Zero_o(ALUzero)
);

ALUControl _ALUControl (
    .ALUOp_i(ALUOp), 
    .funct_i(IR[5:0]), 
    .ALUctrl_o(ALUctrl)
);

signExtend _signExtend (
    .data_i(IR[15:0]), 
    .data_o(SignExtend)
);

assign Reg_R1 = IR[25:21];
assign Reg_R2 = IR[20:16];

register_file _regFile(
    .clk(clk),
    .rst(rst_n),
    .RegWrite_i(RegWrite),
    .WriteReg_i(Reg_W),
    .WriteData_i(WriteData),
    .ReadReg1_i(Reg_R1),
    .ReadReg2_i(Reg_R2),
    .ReadData1_o(ReadData1),
    .ReadData2_o(ReadData2)
);

Mux #(5) MUXX_RegDST(
    .data1_i(IR[20:16]), 
    .data2_i(IR[15:11]), 
    .select_i(RegDST), 
    .data_o(MUX_RegDST)
);

Mux #(32) MUXX_Src(
    .data1_i(ReadData2), 
    .data2_i(SignExtend), 
    .select_i(ALUSrc), 
    .data_o(MUX_Src)
);

Mux #(32) MUXX_MemToReg(
    .data1_i(ALUresult), 
    .data2_i(ReadDataMem), 
    .select_i(MemToReg), 
    .data_o(MUX_MemToReg)
);

Add_ALU PC_adder (
    .data1_i(IR_addr), 
    .data2_i(32'b100), 
    .Add_ALU_o(PCAdd4)
);

assign JumpAddr = { {PCAdd4[31:28]}, {IR[25:0]}, 2'b00};

Add_ALU branch_adder (
    .data1_i(PCAdd4), 
    .data2_i({{SignExtend[29:0]}, 2'b00}),
    .Add_ALU_o(BranchAddr)
);

Mux #(32) MUXX_Branch(
    .data1_i(PCAdd4), 
    .data2_i(BranchAddr), 
    .select_i(Branch & ALUzero), 
    .data_o(MUX_Branch)
);

Mux #(32) MUXX_Jump(
    .data1_i(MUX_Branch), 
    .data2_i(JumpAddr), 
    .select_i(Jump), 
    .data_o(MUX_Jump)
);

Mux #(32) MUXX_JumpRegister(
    .data1_i(MUX_Jump), 
    .data2_i(ReadData1), 
    .select_i(JumpRegister), 
    .data_o(PCnext)
);

Mux #(5) MUXX_JumpAndLink_1(
    .data1_i(MUX_RegDST), 
    .data2_i(5'd31), 
    .select_i(JumpAndLink), 
    .data_o(Reg_W)
);

Mux #(32) MUXX_JumpAndLink_2(
    .data1_i(MUX_MemToReg), 
    .data2_i(PCAdd4), 
    .select_i(JumpAndLink), 
    .data_o(WriteData)
);

// data memory contral signals CEN, OEN, WEN
assign  CEN = ~(MemRead | MemWrite);
assign  WEN = ~(MemWrite);
assign  OEN = ~(MemRead);
//==== combinational part =================================


//==== sequential part ====================================


//=========================================================
endmodule

// module PC
module PC(clk, rst, PCin, PCout);
    input        clk,rst;
    input [31:0] PCin;
    output reg [31:0] PCout;

    always @(posedge clk or posedge rst)begin
        if(rst)
            PCout <= 32'b0;
        else 
            PCout <= PCin;
        //$display("Your IR_addr = %d", PCout);
    end
endmodule


//module Add_ALU
module Add_ALU(data1_i, data2_i, Add_ALU_o);

    input [31:0] data1_i;
    input [31:0] data2_i;
    
    output reg [31:0] Add_ALU_o;

    always @(*) begin
        Add_ALU_o <= data1_i + data2_i;
    end
endmodule

//module register_file
module register_file(
    clk  ,
    rst,
    RegWrite_i  ,
    WriteReg_i   ,
    WriteData_i ,
    ReadReg1_i  ,
    ReadReg2_i   ,
    ReadData1_o ,
    ReadData2_o ,
);
    input        clk, rst, RegWrite_i;
    input  [4:0] WriteReg_i, ReadReg1_i, ReadReg2_i;
    input  [31:0] WriteData_i;
    output [31:0] ReadData1_o, ReadData2_o;
    
    
    reg [31:0] register[0:31];
    integer i;

    assign ReadData1_o = register[ReadReg1_i];
    assign ReadData2_o = register[ReadReg2_i];

    always@(posedge clk or posedge rst) begin
        if(rst) begin
          for(i=0;i<32;i=i+1) begin
            register[i] <=32'b0;
          end
        end
        else if(RegWrite_i) begin
          register[WriteReg_i] <= WriteData_i;
        end
    end
endmodule

//module mainControl
module mainControl(
    opcode_i,
    funct_i,
    RegDst_o,
    Jump_o,
    Branch_o,
    MemRead_o,
    MemToReg_o,
    ALUOp_o,
    MemWrite_o,
    ALUSrc_o,
    RegWrite_o,
    JumpRegister_o,
    JumpAndLink_o,
);

input [5:0] opcode_i, funct_i;
output RegDst_o, RegWrite_o, ALUSrc_o;
output Branch_o, Jump_o;
output MemToReg_o, MemRead_o, MemWrite_o;
output JumpRegister_o, JumpAndLink_o;
output [1:0] ALUOp_o;

wire R_format, lw, sw, beq, jump, jr, jal;
    
assign R_format = (opcode_i == 6'b000000)?1:0;
assign lw = (opcode_i == 6'b100011)?1:0;
assign sw = (opcode_i == 6'b101011)?1:0;
assign beq = (opcode_i == 6'b000100)?1:0;
assign jump = (opcode_i == 6'b000010)?1:0;
assign jr = ((opcode_i == 6'b000000) && (funct_i == 6'b001000))?1:0;
assign jal = (opcode_i == 6'b000011)?1:0;

assign RegDst_o = R_format;
assign Jump_o = jump | jal; 
assign Branch_o = beq;
assign MemRead_o = lw;
assign MemToReg_o = lw;
assign MemWrite_o = sw;
assign ALUSrc_o = lw|sw;
assign RegWrite_o = R_format | lw | jal;
assign ALUOp_o = R_format ? 2'b10:
                 beq      ? 2'b01 : 2'b00;
assign JumpRegister_o = jr;
assign JumpAndLink_o = jal;
endmodule

// module ALU
module ALU (ALUCtrl_i, data1_i, data2_i, ALU_o, Zero_o);

    input [3:0] ALUCtrl_i;
    input signed [31:0] data1_i, data2_i;
    
    output reg signed [31:0] ALU_o;
    output Zero_o;
    assign Zero_o = (data1_i == data2_i)?1:0;
    always @(*) begin
        case (ALUCtrl_i)
            4'b0000: ALU_o <= data1_i & data2_i;
            4'b0001: ALU_o <= data1_i | data2_i;
            4'b0010: ALU_o <= data1_i + data2_i;
            4'b0110: ALU_o <= data1_i - data2_i;
            4'b0111: ALU_o <= data1_i < data2_i ? 32'b1:32'b0;
            4'b1100: ALU_o <= ~(data1_i | data2_i);
            default: ALU_o <= 32'b0;
        endcase
    end
endmodule

// module ALUControl
module ALUControl (ALUOp_i, funct_i, ALUctrl_o);
    input [1:0] ALUOp_i;
    input [5:0] funct_i;
    output reg [3:0] ALUctrl_o;

    always @(ALUOp_i,funct_i) begin
        if (ALUOp_i == 2'b00) 
            ALUctrl_o <=4'b0010;
        else if (ALUOp_i ==2'b01)
            ALUctrl_o <=4'b0110;
        else 
            case(funct_i[3:0])
                4'b0000: ALUctrl_o <= 4'b0010 ; //add
                4'b0010: ALUctrl_o <= 4'b0110; //subtract     
                4'b0100: ALUctrl_o <= 4'b0000; //and  
                4'b0101: ALUctrl_o <= 4'b0001; //or   
                4'b0111: ALUctrl_o <= 4'b1100; //nor
                4'b1010: ALUctrl_o <= 4'b0111; //slt
                default: ALUctrl_o <= 4'b1111; //should not happen
            endcase
    end
                     
endmodule

// module signExtend
module signExtend (data_i, data_o);
    input [15:0] data_i;
    output[31:0] data_o;

    assign data_o = { {16{data_i[15]}} , data_i };
endmodule

module Mux #(parameter WIDTH =32) (data1_i, data2_i, select_i, data_o);
    input [WIDTH-1:0] data1_i, data2_i;
    input select_i;
    output reg [WIDTH-1:0] data_o;
    always @(select_i, data1_i, data2_i)begin
        case(select_i)
            0: data_o <= data1_i;
            1: data_o <= data2_i; 
        endcase
    end
endmodule