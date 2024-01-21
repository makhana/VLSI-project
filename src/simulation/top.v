module top;

    // alu
    reg [2:0] dut_oc;
    reg [3:0] dut_a;
    reg [3:0] dut_b;
    wire [3:0] dut_f;

    alu dut_alu(
        .oc(dut_oc),
        .a(dut_a),
        .b(dut_b),
        .f(dut_f)
    );

    // register
    reg dut_rst_n;
    reg dut_clk;
    reg dut_cl;
    reg dut_ld;
    reg dut_inc;
    reg dut_dec;
    reg [3:0] dut_in;
    reg dut_sr;
    reg dut_ir;
    reg dut_sl;
    reg dut_il;
    wire [3:0] dut_out;

    register dut_register(
        .rst_n(dut_rst_n),
        .clk(dut_clk),
        .cl(dut_cl),
        .ld(dut_ld),
        .in(dut_in),
        .inc(dut_inc),
        .dec(dut_dec),
        .sr(dut_sr),
        .ir(dut_ir),
        .sl(dut_sl),
        .il(dut_il),
        .out(dut_out)
    );

    // simulation

    integer i;
    integer resume;

    initial begin
        for (i = 0; i < 2**12 ; i = i + 1) begin
            {dut_oc, dut_a, dut_b} = i;
            #5;
        end
        
        $stop;
        resume = 1; // resume register simulation
       
        dut_in = 4'h0;
        dut_cl = 1'b0;
        dut_ld = 1'b0;
        dut_inc = 1'b0;
        dut_dec = 1'b0;
        dut_sr = 1'b0;
        dut_ir = 1'b0;
        dut_sl = 1'b0;
        dut_il = 1'b0;
        #7 dut_rst_n = 1'b1;
        repeat (1000) begin
            #10;
            dut_in = $urandom % 16;
            dut_cl = $urandom % 2;
            dut_ld = $urandom % 2;
            dut_inc = $urandom % 2;
            dut_dec = $urandom % 2;
            dut_sr = $urandom % 2;
            dut_ir = $urandom % 2;
            dut_sl = $urandom % 2;
            dut_il = $urandom % 2;
        end
        $finish;

    end

    always @(resume) begin
        dut_rst_n = 1'b0;
        dut_clk = 1'b0;
        forever begin
            #5 dut_clk = ~dut_clk;
        end
    end

    always @(dut_f) begin
        $display("time = %0d, oc = %b, a = %b, b = %b, f = %b", $time, dut_oc, dut_a, dut_b, dut_f);
    end

    always @(dut_out) begin
        $display("time = %0d, in = %b, cl = %b, ld = %b, inc = %b, dec = %b, sr = %b, ir = %b, sl = %b, il = %b, out = %b", $time, dut_in, dut_cl, dut_ld, dut_inc, dut_dec, dut_sr, dut_ir, dut_sl, dut_il, dut_out);
    end
    
endmodule