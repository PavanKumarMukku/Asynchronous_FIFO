module fifo_wptr #(
    parameter ADDR_WIDTH = 4
) (
    input logic w_clk,
    input logic w_rst,
    input logic w_inc,
    input logic[ADDR_WIDTH : 0] wq2_rptr,
    output logic full,
    output logic[ADDR_WIDTH-1 : 0] w_addr,
    output logic[ADDR_WIDTH : 0] wptr
);
    /*
    This module handles write pointer logic, binary to gray code conversion and
    generates full flag by comparing local write pointer with synchronized read pointer

    - Full flag is generated when Gray-coded read pointer matches synchronized write pointer
    - Generates the write address for memory access and updates the read pointer on successful read operations.
    */

    logic[ADDR_WIDTH : 0] w_bin;
    logic[ADDR_WIDTH : 0] wbin_nxt;
    logic[ADDR_WIDTH : 0] wgray_nxt;

    wire is_full;

    always_ff @(posedge w_clk or posedge w_rst) begin
        if(w_rst) begin
            w_bin <= 0;
            wptr  <= 0;
        end
        else begin
            w_bin <= wbin_nxt;
            wptr  <= wgray_nxt; 
        end
    end

    assign w_addr    = w_bin[ADDR_WIDTH-1 : 0];

    assign wbin_nxt  = (w_bin) + (w_inc & ~full);
    assign wgray_nxt = (wbin_nxt >> 1) ^ wbin_nxt;

    // Full when MSBs match wrap-around conditions (top two bits inverted, remaining match)
    assign is_full   = (wgray_nxt == {~(wq2_rptr[ADDR_WIDTH : ADDR_WIDTH-1]), wq2_rptr[ADDR_WIDTH-2 : 0]});

    always_ff @(posedge w_clk or posedge w_rst) begin
        if(w_rst) begin
            full <= 1'b0;
        end
        else begin
            full <= is_full;
        end
    end
    
endmodule
