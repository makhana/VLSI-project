module register (
    input clk,
    input rst_n,
    input cl,
    input ld,
    input [3:0] in,
    input inc,
    input dec,
    input sr,
    input ir,
    input sl,
    input il,
    output [3:0] out
);

    reg [3:0] out_reg, out_next;

    assign out = out_reg;

    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            out_reg <= 4'h0;
        end else begin
            out_reg <= out_next;
        end
    end

    always @(*) begin
        out_next = out_reg;

        if(cl == 1) begin
            out_next = 4'h0;
        end else if(ld == 1) begin
            // koristim in
            out_next = in;
        end else if(inc == 1) begin
            out_next = out_reg + 1'b1;
        end else if(dec == 1) begin
            out_next = out_reg - 1'b1;
        end else if(sr == 1) begin // PROVERI
            // koristim ir
            out_next = out_reg >> 1'b1;
            out_next = out_next | (ir << 3); // shift bit
        end else if(sl == 1) begin
            // koristim il
            out_next = out_reg << 1'b1;
            out_next = out_next & il; // shift bit
        end
    end
    
endmodule