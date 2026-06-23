module fifo_rptr #(
    parameter ADDR_WIDTH = 4
) (
    input logic r_clk,
    input logic r_rst,
    input logic r_inc,
    input logic[ADDR_WIDTH : 0] rq2_wptr,   // Synchronized write pointer form write pointer domain
    output logic empty,
    output logic[ADDR_WIDTH-1 : 0] r_addr,
    output logic[ADDR_WIDTH : 0] rptr
);
    /*
    This module handles read pointer logic, binary to gray code conversion and
    generates empty flag by comparing local read pointer with synchronized write pointer.

    - Empty flag is generated when Gray-coded read pointer matches synchronized write pointer
    - Generates the read address for memory accessa and updates the read pointer on successful read operations.
    */
    logic[ADDR_WIDTH : 0] r_bin;
    wire [ADDR_WIDTH : 0] rbin_nxt;
    wire [ADDR_WIDTH : 0] rgray_nxt;

    wire is_empty;

    always_ff @(posedge r_clk or posedge r_rst) begin
        if(r_rst) begin
            r_bin <= 0;
            rptr  <= 0;
        end
        else begin
            r_bin <= rbin_nxt;
            rptr  <= rgray_nxt;
        end
    end

    assign r_addr    = r_bin[ADDR_WIDTH-1 : 0];

    assign rbin_nxt  = (r_bin) + (r_inc & ~empty);
    assign rgray_nxt = (rbin_nxt >> 1) ^ rbin_nxt;

    assign is_empty  = (rgray_nxt == rq2_wptr);

    always_ff @(posedge r_clk or posedge r_rst) begin
        if(r_rst) begin
            empty <= 1'b1;
        end
        else begin
            empty <= is_empty;
        end
    end

endmodule
