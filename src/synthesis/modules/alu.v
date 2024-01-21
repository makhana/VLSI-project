module alu #(
    parameter DATA_WIDTH = 16
) (
    input [2:0] oc,
    input [DATA_WIDTH-1 : 0] a,
    input [DATA_WIDTH-1 : 0] b,
    output reg [DATA_WIDTH-1 : 0] f
);

    always @(*) begin
        case (oc)
            3'b000: f = a + b; // add
            3'b001: f = a - b; // sub
            3'b010: f = a * b; // mul
            3'b011: f = a / b; // div
            3'b100: f = ~a; // not
            3'b101: f = a ^ b; // xor
            3'b110: f = a | b; // or
            3'b111: f = a & b; // and
        endcase
    end
    
endmodule