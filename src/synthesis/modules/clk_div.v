module clk_div #(
    parameter DIVISOR = 50_000_000
) (
    input clk,
    input rst_n,
    output reg out
); // PROVERI
    // reg out_next, out_reg;

    // assign out = out_reg;

    // integer cnt_reg, cnt_next;

    reg[27:0] counter=28'd0;


    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            out <= 0;
            counter <= 28'd0;
        end else begin
            counter <= counter + 28'd1;
            if(counter>=(DIVISOR-1))
                counter <= 28'd0;
            out <= (counter<DIVISOR/2)?1'b1:1'b0;
        end
    end

    // always @(*) begin
    //     out_next = out_reg;
    //     cnt_next = cnt_reg;

    //     if(cnt_reg == DIVISOR) begin
    //         cnt_next = 0;
    //     end else begin
    //         cnt_next = cnt_reg + 1'b1;
    //     end

    //     out_next = (cnt_reg < DIVISOR/2)? 1'b1:1'b0;
    // end
    
endmodule