module top #(
    parameter DIVISOR = 50_000_000,
    parameter FILE_NAME = "mem_init.mif",
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 16
) (
    input clk,
    input rst_n,
    input [8:0] sw,
    output [9:0] led,
    output [27:0] hex
);


wire clk_div_out;
clk_div #(DIVISOR) dut_clk_div(
    .clk(clk),
    .rst_n(rst_n),
    .out(clk_div_out)
);

wire [DATA_WIDTH-1:0] mem_out;
wire mem_we_cpu;
wire [ADDR_WIDTH-1:0] mem_addr_cpu;
wire [DATA_WIDTH-1:0] mem_data_cpu;

wire [ADDR_WIDTH-1:0] pc_out;
wire [ADDR_WIDTH-1:0] sp_out;



wire [DATA_WIDTH-1:0] cpu_out;
assign led[4:0] = cpu_out[4:0];

cpu #(
    .ADDR_WIDTH (ADDR_WIDTH), 
    .DATA_WIDTH (DATA_WIDTH)
) dut_cpu(
    .clk(clk_div_out),
    .rst_n(rst_n),
    .mem_in(mem_out),
    .in(sw[3:0]),
    .mem_we(mem_we_cpu),
    .mem_addr(mem_addr_cpu),
    .mem_data(mem_data_cpu),
    .out(cpu_out),
    .pc(pc_out),
    .sp(sp_out)
);

memory #(
    .FILE_NAME(FILE_NAME), 
    .ADDR_WIDTH(ADDR_WIDTH), 
    .DATA_WIDTH(DATA_WIDTH)
) dut_memory(
    .clk(clk_div_out),
    .we(mem_we_cpu),
    .addr(mem_addr_cpu),
    .data(mem_data_cpu),
    .out(mem_out)
);

wire [3:0] ones_pc_out;
wire [3:0] tens_pc_out;

bcd dut_pc_bcd(
    .in(pc_out),
    .ones(ones_pc_out),
    .tens(tens_pc_out)
);

wire [3:0] ones_sp_out;
wire [3:0] tens_sp_out;

bcd dut_sp_bcd(
    .in(sp_out),
    .ones(ones_sp_out),
    .tens(tens_sp_out)
);

ssd dut_ssd1(
    .in(tens_pc_out),
    .out(hex[13:7])
);
ssd dut_ssd2(
    .in(ones_pc_out),
    .out(hex[6:0])
);
ssd dut_ssd3(
    .in(tens_sp_out),
    .out(hex[27:21])
);
ssd dut_ssd4(
    .in(ones_sp_out),
    .out(hex[20:14])
);
    
endmodule