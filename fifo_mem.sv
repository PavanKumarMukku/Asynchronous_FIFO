module fifo_mem #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
) (
    input logic w_clk,
    input logic w_en,
    input logic full,
    input logic[ADDR_WIDTH-1 : 0] w_addr,
    input logic[DATA_WIDTH-1 : 0] w_data,
    input logic[ADDR_WIDTH-1 : 0] r_addr,
    output logic[DATA_WIDTH-1 : 0] r_data
);
    /*
    This module represents the main FIFO, memory array.
    It is written synchronously in the write clock domain and read asynchronously
    to minimize latency in the read path.
    */

    // depth = 2^(addr_width)
    localparam DEPTH = 1 << ADDR_WIDTH;
    logic[DATA_WIDTH-1 : 0] mem[DEPTH-1 : 0];

    always_ff @(posedge w_clk) begin
        if(w_en && !full) begin
            mem[w_addr] <= w_data;
        end
    end

    assign r_data = mem[r_addr];

endmodule
