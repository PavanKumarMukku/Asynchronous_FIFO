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

    How it works?
        - the input signal generated in one clock domain is sampled by first flipflop that works
        on destination clk. Since input may change close to sampling edge, the first flipflop can enter metastable state, where
        output is neither 0 or 1
        - the second flipflop samples the output of first one on next destination clock edge, giving firstone an
        entire clock cycle to resolve meta stability
    */
    
    logic[WIDTH-1 : 0] q1;

    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            q1 <= '0;
            q <= '0;
        end
        else begin
            q1 <= d;
            q <= q1;
        end
    end  
endmodule
