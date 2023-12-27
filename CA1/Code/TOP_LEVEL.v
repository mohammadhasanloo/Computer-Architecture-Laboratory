module TOP_LEVEL(
    input clk, rst,
    input Forward_En
);
    // Hazard
    wire Hazard, Two_src;
    
    // Forwarding
    wire [1:0] Sel_src1, Sel_src2;
    // IF
    wire [31:0] pcOutIf, instOutIf;
    wire [3:0] src1OutId, src2OutId;

    // IF-Reg
    wire [31:0] pcOutIfId, instOutIfId;
    // ID
    wire [31:0] pcOutId;
    wire [3:0] aluCmdOutId;
    wire memReadOutId, memWriteOutId, wbEnOutId, branchOutId, sOutId, immOutId;
    wire [31:0] reg1OutId, reg2OutId;
    wire [11:0] shiftOperandOutId;
    wire [23:0] imm24OutId;
    wire [3:0] destOutId;
    // ID-Reg
    wire [31:0] pcOutIdEx;
    wire [3:0] aluCmdOutIdEx;
    wire memReadOutIdEx, memWriteOutIdEx, wbEnOutIdEx, branchOutIdEx, sOutIdEx;
    wire [31:0] reg1OutIdEx, reg2OutIdEx;
    wire [3:0] src1OutIdEx, src2OutIdEx;
    wire immOutIdEx;
    wire [11:0] shiftOperandOutIdEx;
    wire [23:0] imm24OutIdEx;
    wire [3:0] destOutIdEx;
    wire carryOut;
    // EX
    wire memReadOutEx, memWriteOutEx, wbEnOutEx, Branch_taken;
    wire [31:0] Branch_Address;
    wire [31:0] aluResOutEx, reg2OutEx;
    wire [3:0] destOutEx;
    wire [3:0] status;
    wire carryIn;
    assign carryIn = status[1];
    // EX-Reg
    wire memReadOutExMem, memWriteOutExMem, wbEnOutExMem;
    wire [31:0] aluResOutExMem, reg2OutExMem;
    wire [3:0] destOutExMem;
    // MEM
    wire memReadOutMem, wbEnOutMem;
    wire [31:0] aluResOutMem, memDataOutMem;
    wire [3:0] destOutMem;
    // MEM-Reg
    wire memReadOutMemWb, wbEnOutMemWb;
    wire [31:0] aluResOutMemWb, memDataOutMemWb;
    wire [3:0] destOutMemWb;
    // WB
    wire WB_EN;
    wire [31:0] WB_Value;
    wire [3:0] wbDest;

    Hazard_Unit hzrd(
        .Rn(src1OutId), .Rdm(src2OutId),
        .Two_src(Two_src),
        .Dest_Ex(destOutEx), .Dest_Mem(destOutMem),
        .WB_EN_EXE(wbEnOutEx), .WB_EN_MEM(wbEnOutMem), .memREn(memReadOutEx),
        .Forward_En(Forward_En),
        .Hazard(Hazard)
    );

    ForwardingUnit frwrd(
        .Forward_En(Forward_En),
        .src1(src1OutIdEx), .src2(src2OutIdEx),
        .WB_EN_MEM(wbEnOutExMem), .WB_EN_WB(wbEnOutMemWb),
        .destMem(destOutExMem), .destWb(destOutMemWb),
        .Sel_src1(Sel_src1), .Sel_src2(Sel_src2)
    );

    IF_Stage stIf(
        .clk(clk), .rst(rst),
        .Branch_taken(Branch_taken), .freeze(Hazard),
        .Branch_Address(Branch_Address),
        .PC(pcOutIf), .Instruction(instOutIf)
    );
    IF_Stage_Reg regsIf(
        .clk(clk), .rst(rst),
        .freeze(Hazard), .Flush(Branch_taken),
        .PC_in(pcOutIf), .Instruction_in(instOutIf),
        .PC(pcOutIfId), .Instruction(instOutIfId)
    );

    ID_Stage stId(
        .clk(clk), .rst(rst),
        .PC_in(pcOutIfId), .inst(instOutIfId),
        .status(status),
        .WB_WB_EN(WB_EN), .WB_Value(WB_Value), .wbDest(wbDest),
        .Hazard(Hazard),
        .PC(pcOutId),
        .EXE_CMD(aluCmdOutId), .MEM_R_EN(memReadOutId), .MEM_W_EN(memWriteOutId),
        .WB_EN(wbEnOutId), .B(branchOutId), .S(sOutId),
        .reg1(reg1OutId), .reg2(reg2OutId),
        .imm(immOutId), .Shift_operand(shiftOperandOutId), .Signed_imm_24(imm24OutId), .Dest(destOutId),
        .src1(src1OutId), .src2(src2OutId), .Two_src(Two_src)
    );
    ID_Stage_Reg regsId(
        .clk(clk), .rst(rst),
        .PC_in(pcOutId),
        .EXE_CMD_In(aluCmdOutId), .MEM_R_EN_In(memReadOutId), .MEM_W_EN_In(memWriteOutId),
        .WB_EN_In(wbEnOutId), .B_In(branchOutId), .S_In(sOutId),
        .reg1In(reg1OutId), .reg2In(reg2OutId),
        .imm_In(immOutId), .Shift_operand_In(shiftOperandOutId), .Signed_imm_24_In(imm24OutId), .Dest_In(destOutId),
        .carryIn(carryIn), .src1In(src1OutId), .src2In(src2OutId), .Flush(Branch_taken),
        .PC(pcOutIdEx),
        .EXE_CMD_Out(aluCmdOutIdEx), .MEM_R_EN_Out(memReadOutIdEx), .MEM_W_EN_Out(memWriteOutIdEx),
        .WB_EN_Out(wbEnOutIdEx), .B_Out(branchOutIdEx), .S_Out(sOutIdEx),
        .reg1Out(reg1OutIdEx), .reg2Out(reg2OutIdEx),
        .imm_Out(immOutIdEx), .Shift_operand_Out(shiftOperandOutIdEx), .Signed_imm_24_Out(imm24OutIdEx), .Dest_Out(destOutIdEx),
        .src1Out(src1OutIdEx), .src2Out(src2OutIdEx),
        .carryOut(carryOut)
    );

    EXE_Stage stEx(
        .clk(clk), .rst(rst),
        .WB_EN_In(wbEnOutIdEx), .MEM_R_EN_In(memReadOutIdEx), .MEM_W_EN_In(memWriteOutIdEx),
        .Brach_Taken_In(branchOutIdEx), .ldStatus(sOutIdEx), .imm(immOutIdEx), .carryIn(carryOut),
        .EXE_CMD(aluCmdOutIdEx), .Val_Rn(reg1OutIdEx), .Val_Rm(reg2OutIdEx), .PC(pcOutIdEx),
        .Shift_operand(shiftOperandOutIdEx), .Signed_EX_imm24(imm24OutIdEx), .Dest(destOutIdEx),
        .Sel_src1(Sel_src1), .Sel_src2(Sel_src2), .valMem(aluResOutExMem), .valWb(WB_Value),
        .WB_EN_Out(wbEnOutEx), .MEM_R_EN_Out(memReadOutEx), .MEM_W_EN_Out(memWriteOutEx),
        .Brach_Taken_Out(Branch_taken), .ALU_Res(aluResOutEx), .EXE_Val_Rm(reg2OutEx), .Branch_Address(Branch_Address),
        .EXE_Dest(destOutEx), .status(status)
    );
    EXE_Stage_Reg regsEx(
        .clk(clk), .rst(rst),
        .WB_EN_In(wbEnOutEx), .MEM_R_EN_In(memReadOutEx), .MEM_W_EN_In(memWriteOutEx),
        .ALU_Res_In(aluResOutEx), .valRmIn(reg2OutEx), .Dest_In(destOutEx),
        .WB_EN_Out(wbEnOutExMem), .MEM_R_EN_Out(memReadOutExMem), .MEM_W_EN_Out(memWriteOutExMem),
        .ALU_Res_Out(aluResOutExMem), .valRmOut(reg2OutExMem), .Dest_Out(destOutExMem)
    );

    MEM_Stage stMem(
        .clk(clk), .rst(rst),
        .WB_EN_In(wbEnOutExMem), .MEM_R_EN_In(memReadOutExMem), .MEM_W_EN_In(memWriteOutExMem),
        .ALU_Res_In(aluResOutExMem), .Val_Rm(reg2OutExMem), .Dest_In(destOutExMem),
        .WB_EN_Out(wbEnOutMem), .MEM_R_EN_Out(memReadOutMem),
        .ALU_Res_Out(aluResOutMem), .memOut(memDataOutMem), .Dest_Out(destOutMem)
    );
    MEM_Stage_Reg regsMem(
        .clk(clk), .rst(rst),
        .WB_EN_In(wbEnOutMem), .MEM_R_EN_In(memReadOutMem),
        .ALU_Res_In(aluResOutMem), .Mem_Data_In(memDataOutMem), .Dest_In(destOutMem),
        .WB_EN_Out(wbEnOutMemWb), .MEM_R_EN_Out(memReadOutMemWb),
        .ALU_Res_Out(aluResOutMemWb), .Mem_Data_Out(memDataOutMemWb), .Dest_Out(destOutMemWb)
    );

    WB_Stage stWb(
        .clk(clk), .rst(rst),
        .WB_EN_In(wbEnOutMemWb), .MEM_R_EN(memReadOutMemWb),
        .ALU_Res(aluResOutMemWb), .Mem_Data(memDataOutMemWb), .Dest_In(destOutMemWb),
        .WB_EN_Out(WB_EN), .WB_Value(WB_Value), .Dest_Out(wbDest)
    );
endmodule
