module cpu #(
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 16
) (
    input clk,
    input rst_n,
    input [DATA_WIDTH-1 : 0] mem_in, // podatak koji salje memorija kao rezultat citanja
    input [DATA_WIDTH-1 : 0] in, // podatak sa standardnog ulaza kod instrukcije IN
    output reg mem_we, // kodujem ovde vrednost i salje se memoriji u DE0_TOP
    output reg [ADDR_WIDTH-1 : 0] mem_addr, // kodujem ovde vrednost i salje se memoriji u DE0_TOP
    output reg [DATA_WIDTH-1 : 0] mem_data, // kodujem ovde vrednost i salje se memoriji u DE0_TOP
    output [DATA_WIDTH-1 : 0] out, // podatak koji ispisujem na standardni izlaz
    output [ADDR_WIDTH-1 : 0] pc,
    output [ADDR_WIDTH-1 : 0] sp
);

    

    reg [5:0] PC_in;
    wire [5:0] PC_out;
    reg PC_ld, PC_cl, PC_inc, PC_dec, PC_sr, PC_ir, PC_sl, PC_il; // signals for PC register

    register #(6) PCregister(
        .clk(clk),
        .rst_n(rst_n),
        .cl(PC_cl),
        .ld(PC_ld),
        .inc(PC_inc),
        .dec(PC_dec),
        .sr(PC_sr),
        .ir(PC_ir),
        .sl(PC_sl),
        .il(PC_il),
        .in(PC_in),
        .out(PC_out)
    );

    reg [5:0] SP_in;
    wire [5:0] SP_out;
    reg SP_ld, SP_cl, SP_inc, SP_dec, SP_sr, SP_ir, SP_sl, SP_il; // signals for SP register

    register #(6) SPregister(
        .clk(clk),
        .rst_n(rst_n),
        .cl(SP_cl),
        .ld(SP_ld),
        .inc(SP_inc),
        .dec(SP_dec),
        .sr(SP_sr),
        .ir(SP_ir),
        .sl(SP_sl),
        .il(SP_il),
        .in(SP_in),
        .out(SP_out)
    );

    wire [15:0] IR_high_out;
    reg IR_high_ld, IR_high_cl, IR_high_inc, IR_high_dec, IR_high_sr, IR_high_ir, IR_high_sl, IR_high_il; // signals for IR register

    register #(16) IRHIGHregister(
        .clk(clk),
        .rst_n(rst_n),
        .cl(IR_high_cl),
        .ld(IR_high_ld),
        .inc(IR_high_inc),
        .dec(IR_high_dec),
        .sr(IR_high_sr),
        .ir(IR_high_ir),
        .sl(IR_high_sl),
        .il(IR_high_il),
        .in(mem_in),
        .out(IR_high_out)
    );


    wire [15:0] IR_low_out;
    reg IR_low_ld, IR_low_cl, IR_low_inc, IR_low_dec, IR_low_sr, IR_low_ir, IR_low_sl, IR_low_il; // signals for IR register

    register #(16) IRLOWregister(
        .clk(clk),
        .rst_n(rst_n),
        .cl(IR_low_cl),
        .ld(IR_low_ld),
        .inc(IR_low_inc),
        .dec(IR_low_dec),
        .sr(IR_low_sr),
        .ir(IR_low_ir),
        .sl(IR_low_sl),
        .il(IR_low_il),
        .in(mem_in),
        .out(IR_low_out)
    );

    reg [15:0] A_in;
    wire [15:0] A_out;
    reg A_ld, A_cl, A_inc, A_dec, A_sr, A_ir, A_sl, A_il; // signals for A register

    register #(16) Aregister(
        .clk(clk),
        .rst_n(rst_n),
        .cl(A_cl),
        .ld(A_ld),
        .inc(A_inc),
        .dec(A_dec),
        .sr(A_sr),
        .ir(A_ir),
        .sl(A_sl),
        .il(A_il),
        .in(A_in),
        .out(A_out)
    );

    //reg [DATA_WIDTH-1:0] first_op_in;
    wire [DATA_WIDTH-1:0] first_op_out;
    reg first_op_ld, first_op_cl; // signals for first OP register

    register #(DATA_WIDTH) FirstOPregister(
        .clk(clk),
        .rst_n(rst_n),
        .cl(first_op_cl),
        .ld(first_op_ld),
        .inc(1'b0),
        .dec(1'b0),
        .sr(1'b0),
        .ir(1'b0),
        .sl(1'b0),
        .il(1'b0),
        .in(mem_in),
        .out(first_op_out)
    );

    //reg [DATA_WIDTH-1:0] second_op_in;
    wire [DATA_WIDTH-1:0] second_op_out;
    reg second_op_ld, second_op_cl; // signals for second OP register

    register #(DATA_WIDTH) SecondOPregister(
        .clk(clk),
        .rst_n(rst_n),
        .cl(second_op_cl),
        .ld(second_op_ld),
        .inc(1'b0),
        .dec(1'b0),
        .sr(1'b0),
        .ir(1'b0),
        .sl(1'b0),
        .il(1'b0),
        .in(mem_in),
        .out(second_op_out)
    );


    reg [2:0] alu_op;
    wire [DATA_WIDTH-1 : 0] alu_res;

    alu #(DATA_WIDTH) alu_mod(
        .oc(alu_op),
        .a(first_op_out),
        .b(second_op_out),
        .f(alu_res)
    );

    // address and direct-indirect wires
    wire [2:0] reg_addr_1;
    wire [2:0] reg_addr_2;
    wire [2:0] reg_addr_3;
    wire direct_indirect_1, direct_indirect_2, direct_indirect_3;
    assign reg_addr_1 = IR_high_out[10:8];
    assign reg_addr_2 = IR_high_out[6:4];
    assign reg_addr_3 = IR_high_out[2:0];
    assign direct_indirect_1 = IR_high_out[11];
    assign direct_indirect_2 = IR_high_out[7];
    assign direct_indirect_3 = IR_high_out[3];

    wire [3:0] instruction;
    assign instruction = IR_high_out[15:12];



    reg [DATA_WIDTH-1 : 0] out_next, out_reg;


    assign out = out_reg;
    assign pc = PC_out;
    assign sp = SP_out;
    

    // my additional helping registers
    reg [2:0] state_reg, state_next;

    reg [2:0] cnt_step_next, cnt_step_reg;
   
   
    localparam start_state = 3'b000;
    localparam reading_instruction = 3'b001;
    localparam executing_instruction1 = 3'b010;
    localparam executing_MOV = 3'b011;
    localparam stop_state = 3'b101;
    localparam loading_IR_high = 3'b110;
    localparam loading_IR_low = 3'b110;

   

    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
           
            state_reg <= start_state;
            cnt_step_reg <= 3'd0;
            out_reg <= {DATA_WIDTH{1'b0}};

        end else begin
            // this happens on each clock cycle

            state_reg <= state_next;
            cnt_step_reg <= cnt_step_next;
            out_reg <= out_next;

        end
    end

    always @(*) begin
        mem_addr = {ADDR_WIDTH{1'b0}};
        mem_data = {DATA_WIDTH{1'b0}};
        mem_we = 1'b0;

        state_next = state_reg;
        cnt_step_next = cnt_step_reg;
        out_next = out_reg;

        // reset signals
        first_op_cl = 1'b0;
        first_op_ld = 1'b0;
        second_op_cl = 1'b0;
        second_op_ld = 1'b0;

        PC_in = 6'd8;
        SP_in = {ADDR_WIDTH{1'b1}};
        alu_op = 3'b000;
        A_in = 16'h0000;

        PC_ld = 1'b0;
        PC_cl = 1'b0;
        PC_inc = 1'b0;
        PC_dec = 1'b0;
        PC_sr = 1'b0;
        PC_ir = 1'b0;
        PC_sl = 1'b0;
        PC_il = 1'b0;

        SP_ld = 1'b0;
        SP_cl = 1'b0;
        SP_inc = 1'b0;
        SP_dec = 1'b0;
        SP_sr = 1'b0;
        SP_ir = 1'b0;
        SP_sl = 1'b0;
        SP_il = 1'b0;

        IR_high_ld = 1'b0;
        IR_high_cl = 1'b0;
        IR_high_inc = 1'b0;
        IR_high_dec = 1'b0;
        IR_high_sr = 1'b0;
        IR_high_ir = 1'b0; 
        IR_high_sl = 1'b0;
        IR_high_il = 1'b0;

        IR_low_ld = 1'b0;
        IR_low_cl = 1'b0;
        IR_low_inc = 1'b0;
        IR_low_dec = 1'b0;
        IR_low_sr = 1'b0;
        IR_low_ir = 1'b0;
        IR_low_sl = 1'b0;
        IR_low_il = 1'b0;

        A_ld = 1'b0;
        A_cl = 1'b0;
        A_inc = 1'b0;
        A_dec = 1'b0;
        A_sr = 1'b0;
        A_ir = 1'b0;
        A_sl = 1'b0;
        A_il = 1'b0;

       
        // begin logic

        case (state_reg)
            start_state : begin
                // load values

                SP_ld = 1'b1;
                PC_ld = 1'b1;
                A_ld = 1'b1;
                
                state_next = reading_instruction;
            end
            reading_instruction: begin
                
                mem_addr = PC_out;
                mem_we = 1'b0; // cita podatak

                PC_inc = 1'b1;
                

                state_next = loading_IR_high;  
            end 
            loading_IR_high: begin
                IR_high_ld = 1'b1;
                state_next = executing_instruction1;
            end
            executing_instruction1: begin
                
                case (instruction)
                    4'b0000: begin
                        // MOV
                      
                        // podatak je ucitan u IR_high_out

                        if(IR_high_out[3:0] == 4'b0000) begin
                   
                            // op3 = 0
                            if(direct_indirect_1 == 1'b1 && direct_indirect_2 == 1'b1) begin
                                // both indirect
                                case (cnt_step_reg)
                                    0: begin
                                        mem_addr = reg_addr_2;
                                        mem_we = 1'b0;

                                        cnt_step_next = cnt_step_reg + 1'b1;
                                    end
                                    1: begin
                                        mem_addr = mem_in;
                                        mem_we = 1'b0;

                                        cnt_step_next = cnt_step_reg + 1'b1;
                                    end
                                    2: begin
                                        A_in = mem_in;
                                        A_ld = 1'b1;

                                        mem_addr = reg_addr_1;
                                        mem_we = 1'b0;

                                        cnt_step_next = cnt_step_reg + 1'b1;
                                    end
                                    3: begin
                                        mem_addr = mem_in;
                                        mem_we = 1'b1;
                                        mem_data = A_out;

                                        cnt_step_next = 3'd0;
                                        state_next = reading_instruction;
                                    end
                                endcase

                            end else if(direct_indirect_1 == 1'b0 && direct_indirect_2 == 1'b1) begin
                                // first direct, second indirect
                                case (cnt_step_reg)
                                    0: begin
                                        mem_addr = reg_addr_2;
                                        mem_we = 1'b0;

                                        cnt_step_next = cnt_step_reg + 1'b1;
                                    end
                                    1: begin
                                        mem_addr = mem_in;
                                        mem_we = 1'b0;

                                        cnt_step_next = cnt_step_reg + 1'b1;
                                    end
                                    2: begin
                                        mem_addr = reg_addr_1;
                                        mem_we = 1'b1;
                                        mem_data = mem_in;

                                        cnt_step_next = 3'd0;
                                        state_next = reading_instruction;
                                    end
                                endcase
                                
                            end else if(direct_indirect_1 == 1'b1 && direct_indirect_2 == 1'b0) begin
                                // first indirect, second direct

                                case (cnt_step_reg)
                                    0: begin
                                        mem_addr = reg_addr_2;
                                        mem_we = 1'b0;

                                        cnt_step_next = cnt_step_reg + 1'b1;
                                    end
                                    1: begin
                                        A_in = mem_in;
                                        A_ld = 1'b1;

                                        mem_addr = reg_addr_1;
                                        mem_we = 1'b0;

                                        cnt_step_next = cnt_step_reg + 1'b1;
                                    end
                                    2: begin
                                        mem_addr = mem_in;
                                        mem_we = 1'b1;
                                        mem_data = A_out;

                                        cnt_step_next = 3'd0;
                                        state_next = reading_instruction;
                                    end
                                endcase

                            end else if(direct_indirect_1 == 1'b0 && direct_indirect_2 == 1'b0) begin
                                // both direct
                                
                                case (cnt_step_reg)
                                    0: begin
                                        mem_addr = reg_addr_2;
                                        mem_we = 1'b0;

                                        cnt_step_next = cnt_step_reg + 1'b1;
                                    end 
                                    1: begin
                                        mem_addr = reg_addr_1;
                                        mem_we = 1'b1;
                                        mem_data = mem_in;

                                        cnt_step_next = 3'd0;
                                        state_next = reading_instruction;
                                    end
                                endcase
                                
                            end
                        end else if(IR_high_out[3:0] == 4'b1000) begin
                            // mem_in = 1000

                            // load the second byte of instruction
                            case (cnt_step_reg)
                                0: begin
                                    mem_addr = PC_out;
                                    mem_we = 1'b0; // cita podatak
                                    PC_inc = 1'b1;

                                    cnt_step_next = cnt_step_reg + 1'b1;
                                end 
                                1: begin
                                    IR_low_ld = 1'b1;

                                    cnt_step_next = 3'd0;
                                    state_next = executing_MOV;
                                end
                            endcase
                             
                        end
                            
                    end 
                    4'b0001: begin
                        // ADD
                        
                        if(direct_indirect_1 == 1'b1 && direct_indirect_2 == 1'b1 && direct_indirect_3 == 1'b1) begin
                            // all three indirect
                            case (cnt_step_reg)
                                0: begin
                                    mem_addr = reg_addr_2;
                                    mem_we = 1'b0;

                                    cnt_step_next = cnt_step_reg + 1'b1;
                                end 
                                1: begin
                                    mem_addr = mem_in;
                                    mem_we = 1'b0;

                                    cnt_step_next = cnt_step_reg + 1'b1;
                                end
                                2: begin
                                    first_op_ld = 1'b1; // mem_in ready

                                    mem_addr = reg_addr_3;
                                    mem_we = 1'b0;

                                    cnt_step_next = cnt_step_reg + 1'b1;
                                end
                                3: begin
                                    mem_addr = mem_in;
                                    mem_we = 1'b0;

                                    cnt_step_next = cnt_step_reg + 1'b1;
                                end
                                4: begin
                                    second_op_ld = 1'b1; // mem_in ready

                                    mem_addr = reg_addr_1;
                                    mem_we = 1'b0;

                                    cnt_step_next = cnt_step_reg + 1'b1;
                                end
                                5: begin
                                    // I have both operands ready
                                    alu_op = 3'b000; // add

                                    mem_addr = mem_in;
                                    mem_we = 1'b1;
                                    mem_data = alu_res;

                                    state_next = reading_instruction;
                                    cnt_step_next = 0;
                                end
                            endcase
                            // if(cnt_step_reg == 3'd0) begin
                            //     mem_addr = reg_addr_2;
                            //     mem_we = 1'b0;

                            //     cnt_step_next = cnt_step_reg + 1'b1;
                            // end else if(cnt_step_reg == 3'd1) begin
                            //     mem_addr = mem_in;
                            //     mem_we = 1'b0;

                            //     cnt_step_next = cnt_step_reg + 1'b1;
                            // end else if(cnt_step_reg == 3'd2) begin
                            //     first_op_ld = 1'b1; // mem_in ready

                            //     mem_addr = reg_addr_3;
                            //     mem_we = 1'b0;

                            //     cnt_step_next = cnt_step_reg + 1'b1;
                            // end else if(cnt_step_reg == 3'd3) begin
                            //     mem_addr = mem_in;
                            //     mem_we = 1'b0;

                            //     cnt_step_next = cnt_step_reg + 1'b1;
                            // end else if(cnt_step_reg == 3'd4) begin
                                
                            //     second_op_ld = 1'b1; // mem_in ready

                            //     mem_addr = reg_addr_1;
                            //     mem_we = 1'b0;

                            //     cnt_step_next = cnt_step_reg + 1'b1;
                            // end else if(cnt_step_reg == 3'd5) begin
                            //     // I have both operands ready
                            //     alu_op = 3'b000; // add

                            //     mem_addr = mem_in;
                            //     mem_we = 1'b1;
                            //     mem_data = alu_res;

                            //     state_next = reading_instruction;
                            //     cnt_step_next = 0;
                            // end
                        end else if(direct_indirect_1 == 1'b1 && direct_indirect_2 == 1'b1 && direct_indirect_3 == 1'b0) begin
                            // first and third indirect second direct
                            if(cnt_step_reg == 3'd0) begin
                                mem_addr = reg_addr_3;
                                mem_we = 1'b0;

                                
                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd1) begin

                                second_op_ld = 1'b1; // mem_in ready

                                mem_addr = reg_addr_2;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd2) begin
                                mem_addr = mem_in;
                                mem_we = 1'b0;

                                
                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd3) begin
                                first_op_ld = 1'b1; // mem_in ready
                               
                                mem_addr = reg_addr_1;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd4) begin
                                // I have both operands ready
                                alu_op = 3'b000; // add

                                mem_addr = mem_in;
                                mem_we = 1'b1;
                                mem_data = alu_res;

                                state_next = reading_instruction;
                                cnt_step_next = 3'd0;
                            end
                        end else if(direct_indirect_1 == 1'b1 && direct_indirect_2 == 1'b0 && direct_indirect_3 == 1'b1) begin
                            // first direct, second and third indirect
                            
                            if(cnt_step_reg == 3'd0) begin
                                mem_addr = reg_addr_2;
                                mem_we = 1'b0;

                                
                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd1) begin
                                first_op_ld = 1'b1; // mem_in ready

                                mem_addr = reg_addr_3;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd2) begin
                                mem_addr = mem_in;
                                mem_we = 1'b0;


                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd3) begin

                                second_op_ld = 1'b1; // mem_in ready

                                mem_addr = reg_addr_1;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd4) begin

                                // I have both operands ready
                                alu_op = 3'b000; // add
                                
                                mem_addr = mem_in;
                                mem_we = 1'b1;
                                mem_data = alu_res;

                                state_next = reading_instruction;
                                cnt_step_next = 0;
                            end
                        end else if(direct_indirect_1 == 1'b1 && direct_indirect_2 == 1'b0 && direct_indirect_3 == 1'b0) begin
                            // first and second direct, third indirect
                            if(cnt_step_reg == 3'd0) begin
                                mem_addr = reg_addr_2;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd1) begin

                                first_op_ld = 1'b1; // mem_in ready

                                mem_addr = reg_addr_3;
                                mem_we = 1'b0;

                                
                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd2) begin

                                second_op_ld = 1'b1; // mem_in ready
                               

                                mem_addr = reg_addr_1;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd3) begin
                                // I have both operands ready
                                alu_op = 3'b000; // add

                                mem_addr = mem_in;
                                mem_we = 1'b1;
                                mem_data = alu_res;

                                state_next = reading_instruction;
                                cnt_step_next = 3'd0;

                            end
                        end else if(direct_indirect_1 == 1'b0 && direct_indirect_2 == 1'b1 && direct_indirect_3 == 1'b1) begin
                            // both indirect, res direct
                            if(cnt_step_reg == 3'd0) begin
                                mem_addr = reg_addr_2;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd1) begin
                                mem_addr = mem_in;
                                mem_we = 1'b0;

                                first_op_ld = 1'b1;
                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd2) begin
                                mem_addr = reg_addr_3;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd3) begin
                                mem_addr = mem_in;
                                mem_we = 1'b0;

                                second_op_ld = 1'b1;
                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd4) begin
                                // I have both operands ready
                                alu_op = 3'b000; // add

                                mem_addr = reg_addr_1;
                                mem_we = 1'b1;
                                mem_data = alu_res;

                                state_next = reading_instruction;
                                cnt_step_next = 3'd0;
                            end

                        end else if(direct_indirect_1 == 1'b0 && direct_indirect_2 == 1'b1 && direct_indirect_3 == 1'b0) begin
                            // first indirect, second and third direct
                            
                            if(cnt_step_reg == 3'd0) begin
                                mem_addr = reg_addr_3;
                                mem_we = 1'b0;

                                
                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd1) begin
                                second_op_ld = 1'b1; // mem_in ready

                                mem_addr = reg_addr_2;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd2) begin

                                mem_addr = mem_in;
                                mem_we = 1'b0;

                                
                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd3) begin
                                first_op_ld = 1'b1; // mem_in ready

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd4) begin
                                // I have both operands ready
                                alu_op = 3'b000; // add

                                mem_addr = reg_addr_1;
                                mem_we = 1'b1;
                                mem_data = alu_res;

                                state_next = reading_instruction;
                                cnt_step_next = 3'd0;
                            end
                        end else if(direct_indirect_1 == 1'b0 && direct_indirect_2 == 1'b0 && direct_indirect_3 == 1'b1) begin
                            // first direct, second indirect
                            if(cnt_step_reg == 3'd0) begin
                                mem_addr = reg_addr_2;
                                mem_we = 1'b0;

                               
                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd1) begin
                                first_op_ld = 1'b1; // mem_in ready

                                mem_addr = reg_addr_3;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd2) begin
                                mem_addr = mem_in;
                                mem_we = 1'b0;

                                
                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd3) begin

                                second_op_ld = 1'b1; // mem_in ready
                               
                                cnt_step_next = cnt_step_reg + 1'b1;

                            end else if(cnt_step_reg == 3'd4) begin
                                // I have both operands ready
                                alu_op = 3'b000; // add

                                mem_addr = reg_addr_1;
                                mem_we = 1'b1;
                                mem_data = alu_res;

                                state_next = reading_instruction;
                                cnt_step_next = 3'd0;
                            end
                        end else if(direct_indirect_1 == 1'b0 && direct_indirect_2 == 1'b0 && direct_indirect_3 == 1'b0) begin
                            // all three indirect
                            
                           
                            if(cnt_step_reg == 3'd0) begin
                                mem_addr = reg_addr_2;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd1) begin

                                first_op_ld = 1'b1; // mem_in ready
                                
                                mem_addr = reg_addr_3;
                                mem_we = 1'b0;

                                
                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd2) begin

                                second_op_ld = 1'b1; // mem_in ready
                                

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd3) begin
                                // I have both operands ready
                                alu_op = 3'b000; // add

                                mem_addr = reg_addr_1;
                                mem_we = 1'b1;
                                mem_data = alu_res;

                                state_next = reading_instruction;
                                cnt_step_next = 3'd0;
                            end
                        end
                    end
                    4'b0010: begin
                        // SUB

                        if(direct_indirect_1 == 1'b1 && direct_indirect_2 == 1'b1 && direct_indirect_3 == 1'b1) begin
                            // all three indirect
                            if(cnt_step_reg == 3'd0) begin
                                mem_addr = reg_addr_2;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd1) begin
                                mem_addr = mem_in;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd2) begin
                                first_op_ld = 1'b1; // mem_in ready

                                mem_addr = reg_addr_3;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd3) begin
                                mem_addr = mem_in;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd4) begin
                                
                                second_op_ld = 1'b1; // mem_in ready

                                mem_addr = reg_addr_1;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd5) begin
                                // I have both operands ready
                                alu_op = 3'b001; // sub

                                mem_addr = mem_in;
                                mem_we = 1'b1;
                                mem_data = alu_res;

                                state_next = reading_instruction;
                                cnt_step_next = 0;
                            end
                        end else if(direct_indirect_1 == 1'b1 && direct_indirect_2 == 1'b1 && direct_indirect_3 == 1'b0) begin
                            // first and third indirect second direct
                            if(cnt_step_reg == 3'd0) begin
                                mem_addr = reg_addr_3;
                                mem_we = 1'b0;

                                
                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd1) begin

                                second_op_ld = 1'b1; // mem_in ready

                                mem_addr = reg_addr_2;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd2) begin
                                mem_addr = mem_in;
                                mem_we = 1'b0;

                                
                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd3) begin
                                first_op_ld = 1'b1; // mem_in ready
                               
                                mem_addr = reg_addr_1;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd4) begin
                                // I have both operands ready
                                alu_op = 3'b001; // sub

                                mem_addr = mem_in;
                                mem_we = 1'b1;
                                mem_data = alu_res;

                                state_next = reading_instruction;
                                cnt_step_next = 3'd0;

                            end
                        end else if(direct_indirect_1 == 1'b1 && direct_indirect_2 == 1'b0 && direct_indirect_3 == 1'b1) begin
                            // first direct, second and third indirect
                            if(cnt_step_reg == 3'd0) begin
                                mem_addr = reg_addr_2;
                                mem_we = 1'b0;

                                
                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd1) begin
                                first_op_ld = 1'b1; // mem_in ready

                                mem_addr = reg_addr_3;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd2) begin
                                mem_addr = mem_in;
                                mem_we = 1'b0;


                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd3) begin

                                second_op_ld = 1'b1; // mem_in ready

                                mem_addr = reg_addr_1;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd4) begin

                                // I have both operands ready
                                alu_op = 3'b001; // sub
                                
                                mem_addr = mem_in;
                                mem_we = 1'b1;
                                mem_data = alu_res;

                                state_next = reading_instruction;
                                cnt_step_next = 0;
                            end
                        end else if(direct_indirect_1 == 1'b1 && direct_indirect_2 == 1'b0 && direct_indirect_3 == 1'b0) begin
                            // first and second direct, third indirect
                            if(cnt_step_reg == 3'd0) begin
                                mem_addr = reg_addr_2;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd1) begin

                                first_op_ld = 1'b1; // mem_in ready

                                mem_addr = reg_addr_3;
                                mem_we = 1'b0;

                                
                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd2) begin

                                second_op_ld = 1'b1; // mem_in ready
                               

                                mem_addr = reg_addr_1;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd3) begin
                                // I have both operands ready
                                alu_op = 3'b001; // sub

                                mem_addr = mem_in;
                                mem_we = 1'b1;
                                mem_data = alu_res;

                                state_next = reading_instruction;
                                cnt_step_next = 3'd0;
                            end
                        end else if(direct_indirect_1 == 1'b0 && direct_indirect_2 == 1'b1 && direct_indirect_3 == 1'b1) begin
                            // both indirect, res direct
                            if(cnt_step_reg == 3'd0) begin
                                mem_addr = reg_addr_2;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd1) begin

                                mem_addr = mem_in;
                                mem_we = 1'b0;

                                
                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd2) begin
                                first_op_ld = 1'b1; //  mem_in ready

                                mem_addr = reg_addr_3;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd3) begin
                                mem_addr = mem_in;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd4) begin
                                second_op_ld = 1'b1; // mem_in ready

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd5) begin
                                // I have both operands ready
                                alu_op = 3'b001; // sub

                                mem_addr = reg_addr_1;
                                mem_we = 1'b1;
                                mem_data = alu_res;

                                state_next = reading_instruction;
                                cnt_step_next = 3'd0;
                            end

                        end else if(direct_indirect_1 == 1'b0 && direct_indirect_2 == 1'b1 && direct_indirect_3 == 1'b0) begin
                            // first indirect, second and third direct
                            if(cnt_step_reg == 3'd0) begin
                                mem_addr = reg_addr_3;
                                mem_we = 1'b0;

                                
                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd1) begin
                                second_op_ld = 1'b1; // mem_in ready

                                mem_addr = reg_addr_2;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd2) begin
                                mem_addr = mem_in;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd3) begin
                                first_op_ld = 1'b1; // mem_in ready

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd4) begin
                                // I have both operands ready
                                alu_op = 3'b001; // sub

                                mem_addr = reg_addr_1;
                                mem_we = 1'b1;
                                mem_data = alu_res;

                                state_next = reading_instruction;
                                cnt_step_next = 3'd0;
                            end
                        end else if(direct_indirect_1 == 1'b0 && direct_indirect_2 == 1'b0 && direct_indirect_3 == 1'b1) begin
                            // first direct, second indirect
                            if(cnt_step_reg == 3'd0) begin
                                mem_addr = reg_addr_2;
                                mem_we = 1'b0;

                               
                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd1) begin
                                first_op_ld = 1'b1; // mem_in ready

                                mem_addr = reg_addr_3;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd2) begin
                                mem_addr = mem_in;
                                mem_we = 1'b0;

                                
                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd3) begin
                                second_op_ld = 1'b1; // mem_in ready
                               

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd4) begin
                                // I have both operands ready
                                alu_op = 3'b001; // sub

                                mem_addr = reg_addr_1;
                                mem_we = 1'b1;
                                mem_data = alu_res;

                                state_next = reading_instruction;
                                cnt_step_next = 3'd0;
                            end
                        end else if(direct_indirect_1 == 1'b0 && direct_indirect_2 == 1'b0 && direct_indirect_3 == 1'b0) begin
                            // all three direct
                            
                           
                            if(cnt_step_reg == 3'd0) begin
                                mem_addr = reg_addr_2;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd1) begin

                                first_op_ld = 1'b1; // mem_in ready
                                
                                mem_addr = reg_addr_3;
                                mem_we = 1'b0;

                                
                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd2) begin

                                second_op_ld = 1'b1; // mem_in ready
                                

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd3) begin
                                // I have both operands ready
                                alu_op = 3'b001; // sub

                                mem_addr = reg_addr_1;
                                mem_we = 1'b1;
                                mem_data = alu_res;
                               
                                state_next = reading_instruction;
                                cnt_step_next = 3'd0;
                            end
                        end
                    end
                    4'b0011: begin
                        // MUL
                        if(direct_indirect_1 == 1'b1 && direct_indirect_2 == 1'b1 && direct_indirect_3 == 1'b1) begin
                            // all three indirect
                            if(cnt_step_reg == 3'd0) begin
                                mem_addr = reg_addr_2;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd1) begin
                                mem_addr = mem_in;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd2) begin
                                first_op_ld = 1'b1; // mem_in ready

                                mem_addr = reg_addr_3;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd3) begin
                                mem_addr = mem_in;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd4) begin
                                
                                second_op_ld = 1'b1; // mem_in ready

                                mem_addr = reg_addr_1;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd5) begin
                                // I have both operands ready
                                alu_op = 3'b010; // mul

                                mem_addr = mem_in;
                                mem_we = 1'b1;
                                mem_data = alu_res;

                                state_next = reading_instruction;
                                cnt_step_next = 0;
                            end
                        end else if(direct_indirect_1 == 1'b1 && direct_indirect_2 == 1'b1 && direct_indirect_3 == 1'b0) begin
                            // first and third indirect second direct
                            if(cnt_step_reg == 3'd0) begin
                                mem_addr = reg_addr_3;
                                mem_we = 1'b0;

                                
                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd1) begin

                                second_op_ld = 1'b1; // mem_in ready

                                mem_addr = reg_addr_2;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd2) begin
                                mem_addr = mem_in;
                                mem_we = 1'b0;

                                
                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd3) begin
                                first_op_ld = 1'b1; // mem_in ready
                               
                                mem_addr = reg_addr_1;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd4) begin
                                // I have both operands ready
                                alu_op = 3'b010; // mul

                                mem_addr = mem_in;
                                mem_we = 1'b1;
                                mem_data = alu_res;

                                state_next = reading_instruction;
                                cnt_step_next = 3'd0;

                            end
                        end else if(direct_indirect_1 == 1'b1 && direct_indirect_2 == 1'b0 && direct_indirect_3 == 1'b1) begin
                            // first direct, second and third indirect
                            if(cnt_step_reg == 3'd0) begin
                                mem_addr = reg_addr_2;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd1) begin
                                first_op_ld = 1'b1; // mem_in ready

                                mem_addr = reg_addr_3;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd2) begin
                                mem_addr = mem_in;
                                mem_we = 1'b0;


                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd3) begin

                                second_op_ld = 1'b1; // mem_in ready

                                mem_addr = reg_addr_1;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd4) begin

                                // I have both operands ready
                                alu_op = 3'b010; // mul
                                
                                mem_addr = mem_in;
                                mem_we = 1'b1;
                                mem_data = alu_res;

                                state_next = reading_instruction;
                                cnt_step_next = 0;
                            end
                        end else if(direct_indirect_1 == 1'b1 && direct_indirect_2 == 1'b0 && direct_indirect_3 == 1'b0) begin
                            // first and second direct, third indirect
                            if(cnt_step_reg == 3'd0) begin
                                mem_addr = reg_addr_2;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd1) begin

                                first_op_ld = 1'b1; // mem_in ready

                                mem_addr = reg_addr_3;
                                mem_we = 1'b0;

                                
                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd2) begin

                                second_op_ld = 1'b1; // mem_in ready
                               

                                mem_addr = reg_addr_1;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd3) begin
                                // I have both operands ready
                                alu_op = 3'b010; // mul

                                mem_addr = mem_in;
                                mem_we = 1'b1;
                                mem_data = alu_res;

                                state_next = reading_instruction;
                                cnt_step_next = 3'd0;
                            end
                        end else if(direct_indirect_1 == 1'b0 && direct_indirect_2 == 1'b1 && direct_indirect_3 == 1'b1) begin
                            // both indirect, res direct
                            if(cnt_step_reg == 3'd0) begin
                                mem_addr = reg_addr_2;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd1) begin

                                mem_addr = mem_in;
                                mem_we = 1'b0;

                                
                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd2) begin
                                first_op_ld = 1'b1; // mem_in ready

                                mem_addr = reg_addr_3;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd3) begin
                                mem_addr = mem_in;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd4) begin
                                second_op_ld = 1'b1; // mem_in ready

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd5) begin
                                // I have both operands ready
                                alu_op = 3'b010; // mul

                                mem_addr = reg_addr_1;
                                mem_we = 1'b1;
                                mem_data = alu_res;

                                state_next = reading_instruction;
                                cnt_step_next = 3'd0;
                            end

                        end else if(direct_indirect_1 == 1'b0 && direct_indirect_2 == 1'b1 && direct_indirect_3 == 1'b0) begin
                            // first indirect, second and third direct
                            if(cnt_step_reg == 3'd0) begin
                                mem_addr = reg_addr_3;
                                mem_we = 1'b0;

                                
                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd1) begin
                                second_op_ld = 1'b1; // mem_in ready

                                mem_addr = reg_addr_2;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd2) begin
                                mem_addr = mem_in;
                                mem_we = 1'b0;

                                
                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd3) begin
                                first_op_ld = 1'b1; // mem_in ready

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd4) begin
                                // I have both operands ready
                                alu_op = 3'b010; // mul

                                mem_addr = reg_addr_1;
                                mem_we = 1'b1;
                                mem_data = alu_res;

                                state_next = reading_instruction;
                                cnt_step_next = 3'd0;
                            end
                        end else if(direct_indirect_1 == 1'b0 && direct_indirect_2 == 1'b0 && direct_indirect_3 == 1'b1) begin
                            // first direct, second indirect
                            if(cnt_step_reg == 3'd0) begin
                                mem_addr = reg_addr_2;
                                mem_we = 1'b0;

                               
                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd1) begin
                                first_op_ld = 1'b1; // mem_in ready

                                mem_addr = reg_addr_3;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd2) begin
                                mem_addr = mem_in;
                                mem_we = 1'b0;

                                
                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd3) begin
                                second_op_ld = 1'b1; // mem_in ready
                               

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd4) begin
                                // I have both operands ready
                                alu_op = 3'b010; // mul

                                mem_addr = reg_addr_1;
                                mem_we = 1'b1;
                                mem_data = alu_res;

                                state_next = reading_instruction;
                                cnt_step_next = 3'd0;
                            end
                        end else if(direct_indirect_2 == 1'b0 && direct_indirect_3 == 1'b0 && direct_indirect_1 == 1'b0) begin
                            // all three direct
                        
                            if(cnt_step_reg == 3'd0) begin
                                mem_addr = reg_addr_2;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd1) begin
                                first_op_ld = 1'b1; // mem_in ready
                                
                                mem_addr = reg_addr_3;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd2) begin
                                second_op_ld = 1'b1; // mem_in ready
                                
                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd3) begin
                                // I have both operands ready
                                alu_op = 3'b010; // mul

                                mem_addr = reg_addr_1;
                                mem_we = 1'b1;
                                mem_data = alu_res;

                                state_next = reading_instruction;
                                cnt_step_next = 3'd0;
                            end
                        end
                    end
                    4'b0100: begin
                        // DIV
                        state_next = reading_instruction;
                    end
                    4'b0111: begin
                        // IN

                        if(direct_indirect_1 == 1'b1) begin
                            // first op indirect
                            if(cnt_step_reg == 3'd0) begin
                                mem_addr = reg_addr_1;
                                mem_we = 1'b0;
                                A_in = in;
                                A_ld = 1'b1;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd1) begin
                                mem_addr = mem_in;
                                mem_we = 1'b1;
                                mem_data = A_out;

                                cnt_step_next = 3'd0;
                                state_next = reading_instruction;
                            end
                        end else begin
                            // first op direct
                            mem_addr = reg_addr_1;
                            mem_we = 1'b1;
                            mem_data = in;

                            state_next = reading_instruction;
                        end
                        
                    end
                    4'b1000: begin
                        // OUT

                        if(direct_indirect_1 == 1'b1) begin
                            // first op indirect
                            if(cnt_step_reg == 3'd0) begin
                                mem_addr = reg_addr_1;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd1) begin
                                mem_addr = mem_in;
                                mem_we = 1'b0;
                                
                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd2) begin
                                out_next = mem_in;

                                cnt_step_next = 3'd0;
                                state_next = reading_instruction;
                            end
                        end else begin
                            // first op direct
                           
                            if(cnt_step_reg == 3'd0) begin
                                mem_addr = reg_addr_1;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd1) begin
                                out_next = mem_in;

                                cnt_step_next = 3'd0;
                                state_next = reading_instruction;
                            end
                        end
                    end
                    4'b1111: begin
                        // STOP
                        
                        if(direct_indirect_1 == 1'b1 && direct_indirect_2 == 1'b1 && direct_indirect_3 == 1'b1) begin
                            if(cnt_step_reg == 3'd0) begin
                                mem_addr = reg_addr_1;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd1) begin

                                mem_addr = mem_in;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd2) begin
                                if(mem_in[3:0] != 4'b0000) begin
                                    out_next = mem_in;
                                end

                                mem_addr = reg_addr_2;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;

                            end else if(cnt_step_reg == 3'd3) begin

                                mem_addr = mem_in;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;

                            end else if(cnt_step_reg == 3'd4) begin
                                if(mem_in[3:0] != 4'b0000) begin
                                    out_next = mem_in;
                                end

                                mem_addr = reg_addr_3;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;

                            end else if(cnt_step_reg == 3'd5) begin

                                mem_addr = mem_in;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;

                            end else if(cnt_step_reg == 3'd6) begin
                                if(mem_in[3:0] != 4'b0000) begin
                                    out_next = mem_in;
                                end

                                cnt_step_next = 0;
                                state_next = stop_state;
                            end
                        end else if(direct_indirect_1 == 1'b0 && direct_indirect_2 == 1'b1 && direct_indirect_3 == 1'b1) begin
                            if(cnt_step_reg == 3'd0) begin
                                mem_addr = reg_addr_1;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd1) begin
                                if(mem_in[3:0] != 4'b0000) begin
                                    out_next = mem_in;
                                end

                                mem_addr = reg_addr_2;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd2) begin

                                mem_addr = mem_in;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;

                            end else if(cnt_step_reg == 3'd3) begin
                                if(mem_in[3:0] != 4'b0000) begin
                                    out_next = mem_in;
                                end

                                mem_addr = reg_addr_3;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;

                            end else if(cnt_step_reg == 3'd4) begin

                                mem_addr = mem_in;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;

                            end else if(cnt_step_reg == 3'd5) begin
                                if(mem_in[3:0] != 4'b0000) begin
                                    out_next = mem_in;
                                end

                                cnt_step_next = 0;
                                state_next = stop_state;
                            end
                        end else if(direct_indirect_1 == 1'b1 && direct_indirect_2 == 1'b0 && direct_indirect_3 == 1'b1) begin
                            if(cnt_step_reg == 3'd0) begin
                                mem_addr = reg_addr_1;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd1) begin

                                mem_addr = mem_in;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd2) begin
                                if(mem_in[3:0] != 4'b0000) begin
                                    out_next = mem_in;
                                end

                                mem_addr = reg_addr_2;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;

                            end else if(cnt_step_reg == 3'd3) begin
                                if(mem_in[3:0] != 4'b0000) begin
                                    out_next = mem_in;
                                end

                                mem_addr = reg_addr_3;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;

                            end else if(cnt_step_reg == 3'd4) begin

                                mem_addr = mem_in;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;

                            end else if(cnt_step_reg == 3'd5) begin
                                if(mem_in[3:0] != 4'b0000) begin
                                    out_next = mem_in;
                                end

                                cnt_step_next = 0;
                                state_next = stop_state;
                            end
                        end else if(direct_indirect_1 == 1'b1 && direct_indirect_2 == 1'b1 && direct_indirect_3 == 1'b0) begin
                            if(cnt_step_reg == 3'd0) begin
                                mem_addr = reg_addr_1;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd1) begin

                                mem_addr = mem_in;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd2) begin
                                if(mem_in[3:0] != 4'b0000) begin
                                    out_next = mem_in;
                                end

                                mem_addr = reg_addr_2;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;

                            end else if(cnt_step_reg == 3'd3) begin

                                mem_addr = mem_in;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;

                            end else if(cnt_step_reg == 3'd4) begin
                                if(mem_in[3:0] != 4'b0000) begin
                                    out_next = mem_in;
                                end

                                mem_addr = reg_addr_3;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;

                            end else if(cnt_step_reg == 3'd5) begin
                                if(mem_in[3:0] != 4'b0000) begin
                                    out_next = mem_in;
                                end

                                cnt_step_next = 0;
                                state_next = stop_state;
                            end
                        end else if(direct_indirect_1 == 1'b0 && direct_indirect_2 == 1'b0 && direct_indirect_3 == 1'b1) begin
                            if(cnt_step_reg == 3'd0) begin
                                mem_addr = reg_addr_1;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd1) begin
                                if(mem_in[3:0] != 4'b0000) begin
                                    out_next = mem_in;
                                end

                                mem_addr = reg_addr_2;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;

                            end else if(cnt_step_reg == 3'd2) begin
                                if(mem_in[3:0] != 4'b0000) begin
                                    out_next = mem_in;
                                end

                                mem_addr = reg_addr_3;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;

                            end else if(cnt_step_reg == 3'd3) begin

                                mem_addr = mem_in;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;

                            end else if(cnt_step_reg == 3'd4) begin
                                if(mem_in[3:0] != 4'b0000) begin
                                    out_next = mem_in;
                                end

                                cnt_step_next = 0;
                                state_next = stop_state;
                            end
                        end else if(direct_indirect_1 == 1'b0 && direct_indirect_2 == 1'b1 && direct_indirect_3 == 1'b0) begin
                            if(cnt_step_reg == 3'd0) begin
                                mem_addr = reg_addr_1;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd1) begin
                                if(mem_in[3:0] != 4'b0000) begin
                                    out_next = mem_in;
                                end

                                mem_addr = reg_addr_2;
                                mem_we = 1'b0;
                                cnt_step_next = cnt_step_reg + 1'b1;

                            end else if(cnt_step_reg == 3'd2) begin

                                mem_addr = mem_in;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;

                            end else if(cnt_step_reg == 3'd3) begin
                                if(mem_in[3:0] != 4'b0000) begin
                                    out_next = mem_in;
                                end

                                mem_addr = reg_addr_3;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;

                            end else if(cnt_step_reg == 3'd4) begin
                                if(mem_in[3:0] != 4'b0000) begin
                                    out_next = mem_in;
                                end

                                cnt_step_next = 0;
                                state_next = stop_state;
                            end
                        end else if(direct_indirect_1 == 1'b1 && direct_indirect_2 == 1'b0 && direct_indirect_3 == 1'b0) begin
                            if(cnt_step_reg == 3'd0) begin
                                mem_addr = reg_addr_1;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd1) begin

                                mem_addr = mem_in;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd2) begin
                                if(mem_in[3:0] != 4'b0000) begin
                                    out_next = mem_in;
                                end

                                mem_addr = reg_addr_2;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;

                            end else if(cnt_step_reg == 3'd3) begin
                                if(mem_in[3:0] != 4'b0000) begin
                                    out_next = mem_in;
                                end

                                mem_addr = reg_addr_3;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;

                            end else if(cnt_step_reg == 3'd4) begin
                                if(mem_in[3:0] != 4'b0000) begin
                                    out_next = mem_in;
                                end

                                cnt_step_next = 0;
                                state_next = stop_state;
                            end
                        end else if(direct_indirect_1 == 1'b0 && direct_indirect_2 == 1'b0 && direct_indirect_3 == 1'b0) begin
                            if(cnt_step_reg == 3'd0) begin
                                mem_addr = reg_addr_1;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd1) begin
                                if(mem_in[3:0] != 4'b0000) begin
                                    out_next = mem_in;
                                end

                                mem_addr = reg_addr_2;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;
                            end else if(cnt_step_reg == 3'd2) begin
                                if(mem_in[3:0] != 4'b0000) begin
                                    out_next = mem_in;
                                end

                                mem_addr = reg_addr_3;
                                mem_we = 1'b0;

                                cnt_step_next = cnt_step_reg + 1'b1;

                            end else if(cnt_step_reg == 3'd3) begin
                                if(mem_in[3:0] != 4'b0000) begin
                                    out_next = mem_in;
                                end

                                cnt_step_next = 0;
                                state_next = stop_state;
                            end
                        end
                    end
                    
                endcase
            end
            executing_MOV: begin
                if(direct_indirect_1 == 1'b1) begin
                    // indirect
                    if(cnt_step_reg == 3'd0) begin
                        mem_addr = reg_addr_1;
                        mem_we = 1'b1;

                        cnt_step_next = cnt_step_reg + 1'b1;
                    end else if(cnt_step_reg == 3'd1) begin
                        mem_addr = mem_in;
                        mem_we = 1'b1;
                        mem_data = IR_low_out;

                        cnt_step_next = 3'd0;
                        state_next = reading_instruction;
                    end

                end else begin
                    // direct
                    mem_addr = reg_addr_1;
                    mem_we = 1'b1;
                    mem_data = IR_low_out;

                    state_next = reading_instruction;
                end
            end
            stop_state: begin
                // stay here forever
                
            end
        endcase
    end  
endmodule