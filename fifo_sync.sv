module fifo_sync #(
    parameter WIDTH = 4
) (
    input logic clk,
    input logic rst,
    input logic[WIDTH-1 : 0] d,
    output logic[WIDTH-1 : 0] q
);
    /*
    This is a two stage filp flop synchronizer used to safely pass
    Gray-coded pointers from one block to other[read to write and viceversa]
    */
    logic[WIDTH-1 : 0] q1;

    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            q1 <= 1'b0;
            q <= 1'b0;
        end
        else begin
            q1 <= d;
            q <= q1;
        end
    end  
endmodule