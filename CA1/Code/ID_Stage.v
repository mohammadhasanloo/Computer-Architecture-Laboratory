module ID_Stage(
    input clk, rst,
    // From RegsIfId
    input [31:0] PC_in, inst,
    // From EX
    input [3:0] status,
    // From WB
    input wbWbEn,
    input [31:0] wbValue,
    input [3:0] wbDest,
    // From Hazard
    input hazard,
    // To RegsIdEx
    output [31:0] PC,
    output [3:0] aluCmd,
    output memRead, memWrite, wbEn, branch, s,
    output [31:0] reg1, reg2,
    output imm,
    output [11:0] shiftOperand,
    output signed [23:0] imm24,
    output [3:0] dest,
    output [3:0] src1, src2,
    // To Hazard
    output hazardTwoSrc
);
    assign PC = PC_in;
    assign imm = inst[25];
    assign shiftOperand = inst[11:0];
    assign imm24 = inst[23:0];
    assign dest = inst[15:12];
    assign src1 = inst[19:16];

    wire [3:0] aluCmdCU;
    wire memReadCU, memWriteCU, wbEnCU, branchCU, sCU;
    wire [3:0] regfile2Inp;
    wire cond, condFinal;
    wire [31:0] regRn, regRm;
    assign hazardTwoSrc = ~imm | memWriteCU;
    assign condFinal = ~cond | hazard;
    assign src2 = regfile2Inp;

    ConditionCheck cc(
        .cond(inst[31:28]),
        .status(status),
        .result(cond)
    );

    ControlUnit cu(
        .mode(inst[27:26]),
        .op_code(inst[24:21]),
        .sIn(inst[20]),
        .aluCmd(aluCmdCU),
        .memRead(memReadCU),
        .memWrite(memWriteCU),
        .wbEn(wbEnCU),
        .B(branchCU),
        .sOut(sCU)
    );

    RegisterFile rf(
        .clk(clk),
        .rst(rst),
        .src1(inst[19:16]),
        .src2(regfile2Inp),
        .Dest_wb(wbDest),
        .Result_WB(wbValue),
        .writeBackEn(wbWbEn),
        .sclr(1'b0),
        .reg1(regRn),
        .reg2(regRm)
    );

    Mux2To1 #(9) muxCtrlUnit(
        .a0({aluCmdCU, memReadCU, memWriteCU, wbEnCU, branchCU, sCU}),
        .a1(9'd0),
        .sel(condFinal),
        .out({aluCmd, memRead, memWrite, wbEn, branch, s})
    );

    Mux2To1 #(4) muxRegfile(
        .a0(inst[3:0]),
        .a1(inst[15:12]),
        .sel(memWriteCU),
        .out(regfile2Inp)
    );

    // Handle X output for register file input = 4'd15
    Mux2To1 #(32) muxRn15(
        .a0(regRn),
        .a1(PC_in),
        .sel(&inst[19:16]),
        .out(reg1)
    );

    Mux2To1 #(32) muxRm15(
        .a0(regRm),
        .a1(PC_in),
        .sel(&regfile2Inp),
        .out(reg2)
    );
endmodule

module RegisterFile #(
    parameter WordLen = 32,
    parameter WordCount = 15
)(
    input clk, rst,
    input [$clog2(WordCount)-1:0] src1, src2, Dest_wb,
    input [WordLen-1:0] Result_WB,
    input writeBackEn, sclr,
    output [WordLen-1:0] reg1, reg2
);
    reg [WordLen-1:0] regFile [0:WordCount-1];

    assign reg1 = regFile[src1];
    assign reg2 = regFile[src2];

    integer i;

    initial begin
        for (i = 0; i < WordCount; i = i + 1)
            regFile[i] <= i;
    end

    always @(negedge clk or posedge rst) begin
        if (rst)
            for (i = 0; i < WordCount; i = i + 1)
                regFile[i] <= i;
        else if (sclr)
            regFile[Dest_wb] <= {WordLen{1'b0}};
        else if (writeBackEn)
            regFile[Dest_wb] <= Result_WB;
    end
endmodule


module ControlUnit(
    input [1:0] mode,
    input [3:0] op_code,
    input sIn,
    output reg [3:0] aluCmd,
    output reg memRead, memWrite, wbEn, B, sOut
);
    always @(mode, op_code, sIn) begin
        aluCmd = 4'd0;
        {memRead, memWrite} = 2'd0;
        {wbEn, B, sOut} = 3'd0;

        case (op_code)
            4'b1101: aluCmd = 4'b0001; // MOV
            4'b1111: aluCmd = 4'b1001; // MVN
            4'b0100: aluCmd = 4'b0010; // ADD, LDR, STR
            4'b0101: aluCmd = 4'b0011; // ADC
            4'b0010: aluCmd = 4'b0100; // SUB
            4'b0110: aluCmd = 4'b0101; // SBC
            4'b0000: aluCmd = 4'b0110; // AND
            4'b1100: aluCmd = 4'b0111; // ORR
            4'b0001: aluCmd = 4'b1000; // EOR
            4'b1010: aluCmd = 4'b0100; // CMP
            4'b1000: aluCmd = 4'b0110; // TST
            default: aluCmd = 4'b0001;
        endcase

        case (mode)
            2'b00: begin
                sOut = sIn;
                wbEn = (op_code == 4'b1010 || op_code == 4'b1000) ? 1'b0 : 1'b1;
            end
            2'b01: begin
                wbEn = sIn;
                memRead = sIn;
                memWrite = ~sIn;
            end
            2'b10: B = 1'b1;
            default:;
        endcase
    end
endmodule



module ConditionCheck(
    input [3:0] cond,
    input [3:0] status,
    output reg result
);
    wire n, z, c, v;
    assign {n, z, c, v} = status;

    always @(cond, n, z, c, v) begin
        result = 1'b0;
        case (cond)
            4'b0000: result = z;             // EQ
            4'b0001: result = ~z;            // NE
            4'b0010: result = c;             // CS/HS
            4'b0011: result = ~c;            // CC/LO
            4'b0100: result = n;             // MI
            4'b0101: result = ~n;            // PL
            4'b0110: result = v;             // VS
            4'b0111: result = ~v;            // VC
            4'b1000: result = c & ~z;        // HI
            4'b1001: result = ~c | z;        // LS
            4'b1010: result = (n == v);      // GE
            4'b1011: result = (n != v);      // LT
            4'b1100: result = ~z & (n == v); // GT
            4'b1101: result = z & (n != v);  // LE
            4'b1110: result = 1'b1;          // AL
            default: result = 1'b0;
        endcase
    end
endmodule