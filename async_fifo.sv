module async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
) (
    // Write Domain
    input wire[DATA_WIDTH - 1 : 0] data_in,
    input wire  w_en,
    input wire  w_clk,
    input wire  w_rst,
    output wire full,

    // Read Domain
    output reg[DATA_WIDTH - 1 : 0] data_out,
    input wire  r_en,
    input wire  r_clk,
    input wire  r_rst,
    output wire empty
);
    /*
    The top module that ties all the submodules of the ASYNCHRONOUS FIFO together
    using combinational structure interconnects.
    */
    
    // Internal routing nets
    logic [ADDR_WIDTH-1:0] w_addr, r_addr;
    logic [ADDR_WIDTH:0]   wptr, rptr;
    logic [ADDR_WIDTH:0]   wq2_rptr, rq2_wptr;

    fifo_sync #(.WIDTH(ADDR_WIDTH + 1)) sync_r2w (.clk(w_clk), .rst(w_rst), .d(rptr), .q(wq2_rptr));
    fifo_sync #(.WIDTH(ADDR_WIDTH + 1)) sync_w2r (.clk(r_clk), .rst(r_rst), .d(wptr), .q(rq2_wptr));

    fifo_mem #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) core_memory (
        .w_clk(w_clk),
        .w_en(w_en),
        .full(full),
        .w_addr(w_addr),
        .w_data(data_in),
        .r_addr(r_addr),
        .r_data(data_out)
    );

    fifo_rptr #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) read_ptr_handler (
        .r_clk(r_clk),
        .r_rst(r_rst),
        .r_inc(r_en),
        .rq2_wptr(rq2_wptr),
        .empty(empty),
        .r_addr(r_addr),
        .rptr(rptr)
    );

    fifo_wptr #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) write_ptr_handler (
        .w_clk(w_clk),
        .w_rst(w_rst),
        .w_inc(w_en),
        .wq2_rptr(wq2_rptr),
        .full(full),
        .w_addr(w_addr),
        .wptr(wptr)
    );

endmodule