module register #(
    parameter DATA_WIDTH = 16
) (
    input clk,
    input rst_n,
    input cl,
    input ld,
    input [DATA_WIDTH-1:0] in,
    input inc,
    input dec,
    input sr,
    input ir,
    input sl,
    input il,
    output [DATA_WIDTH-1:0] out
);

    reg [DATA_WIDTH-1:0] out_reg, out_next;

    assign out = out_reg;

    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            out_reg <= {DATA_WIDTH{1'b0}};
        end else begin
            out_reg <= out_next;
        end
    end

    always @(*) begin
        out_next = out_reg;

        if(cl == 1) begin
            out_next = {DATA_WIDTH{1'b0}};
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
            out_next = out_next & (ir << (DATA_WIDTH-1)); // shift bit
        end else if(sl == 1) begin // PROVERI
            // koristim il
            out_next = out_reg << 1'b1;
            out_next = out_next & il; // shift bit
        end
    end
    
endmodule