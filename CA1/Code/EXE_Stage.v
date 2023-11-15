module EXE_Stage(
    input clk, rst,
    input wbEnIn, memREnIn, memWEnIn, branchTakenIn, ldStatus, imm, carryIn,
    input [3:0] exeCmd,
    input [31:0] val1, valRm, pc,
    input [11:0] shifterOperand,
    input [23:0] signedImm24,
    input [3:0] dest,
    input [1:0] selSrc1, selSrc2,
    input [31:0] valMem, valWb,
    output wbEnOut, memREnOut, memWEnOut, branchTakenOut,
    output [31:0] aluRes, exeValRm, branchAddr,
    output [3:0] exeDest,
    output [3:0] status
);
    assign wbEnOut = wbEnIn;
    assign memREnOut = memREnIn;
    assign memWEnOut = memWEnIn;
    assign branchTakenOut = branchTakenIn;
    assign exeDest = dest;


    wire [31:0] aluSrc1, aluSrc2, val2;
    assign exeValRm = aluSrc2;

    ALU #(32) alu(
        .a(aluSrc1),
        .b(val2),
        .carryIn(carryIn),
        .exeCmd(exeCmd),
        .out(aluRes),
        .status(statusIn)
    );


    Val2Generator val2Generator(
        .memInst(memREnIn | memWEnIn),
        .imm(imm),
        .valRm(aluSrc2),
        .shifterOperand(shifterOperand),
        .val2(val2)
    );

    wire [3:0] statusIn;
    RegisterNegEdge #(4) statusRegister(
        .clk(clk),
        .rst(rst),
        .ld(ldStatus),
        .clr(1'b0),
        .in(statusIn),
        .out(status)
    );

    wire [31:0] imm24SignExt;
    assign imm24SignExt = {{6{signedImm24[23]}}, signedImm24, 2'b00};
    Adder #(32) branchCalculator(
        .a(pc),
        .b(imm24SignExt),
        .out(branchAddr)
    );

    // Forwarding Unit
    Mux4To1 #(32) muxSrc1(
        .a00(val1),
        .a01(valMem),
        .a10(valWb),
        .a11(32'd0),
        .sel(selSrc1),
        .out(aluSrc1)
    );

    Mux4To1 #(32) muxSrc2(
        .a00(valRm),
        .a01(valMem),
        .a10(valWb),
        .a11(32'd0),
        .sel(selSrc2),
        .out(aluSrc2)
    );

endmodule



module ALU #(
    parameter N = 32
)(
    input [N-1:0] a, b,
    input carryIn,
    input [3:0] exeCmd,
    output reg [N-1:0] out,
    output [3:0] status
);
    reg c, v;
    wire z, n;
    assign status = {n, z, c, v};
    assign z = ~|out;
    assign n = out[N-1];

    wire [N-1:0] carryExt, nCarryExt;
    assign carryExt = {{(N-1){1'b0}}, carryIn};
    assign nCarryExt = {{(N-1){1'b0}}, ~carryIn};

    always @(exeCmd or a or b or carryExt or nCarryExt) begin
        out = {N{1'b0}};
        c = 1'b0;

        case (exeCmd)
            4'b0001: out = b;                      // MOV
            4'b1001: out = ~b;                     // MVN
            4'b0010: {c, out} = a + b;             // ADD
            4'b0011: {c, out} = a + b + carryExt;  // ADC
            4'b0100: {c, out} = a - b;             // SUB
            4'b0101: {c, out} = a - b - nCarryExt; // SBC
            4'b0110: out = a & b;                  // AND
            4'b0111: out = a | b;                  // ORR
            4'b1000: out = a ^ b;                  // EOR
            default: out = {N{1'b0}};
        endcase

        v = 1'b0;
        if (exeCmd[3:1] == 3'b001) begin      // ADD, ADC
            v = (a[N-1] == b[N-1]) && (a[N-1] != out[N-1]);
        end
        else if (exeCmd[3:1] == 3'b010) begin // SUB, SBC
            v = (a[N-1] != b[N-1]) && (a[N-1] != out[N-1]);
        end
    end
endmodule

module Val2Generator(
    input memInst, imm,
    input [31:0] valRm,
    input [11:0] shifterOperand,
    output reg [31:0] val2
);
    integer i;

    always @(memInst or imm or valRm or shifterOperand) begin
        val2 = 32'd0;
        if (memInst) begin // LDR, STR
            val2 = {{20{shifterOperand[11]}}, shifterOperand};
        end
        else begin
            if (imm) begin // immediate
                val2 = {24'd0, shifterOperand[7:0]};
                for (i = 0; i < 2 * shifterOperand[11:8]; i = i + 1) begin
                    val2 = {val2[0], val2[31:1]};
                end
            end
            else begin // shift Rm
                case (shifterOperand[6:5])
                    2'b00: val2 = valRm << shifterOperand[11:7];  // LSL
                    2'b01: val2 = valRm >> shifterOperand[11:7];  // LSR
                    2'b10: val2 = $signed(valRm) >>> shifterOperand[11:7]; // ASR
                    2'b11: begin                                  // ROR
                        val2 = valRm;
                        for (i = 0; i < shifterOperand[11:7]; i = i + 1) begin
                            val2 = {val2[0], val2[31:1]};
                        end
                    end
                    default: val2 = 32'd0;
                endcase
            end
        end
    end
endmodule

