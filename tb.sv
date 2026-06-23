`timescale 1ns/1ps

module tb_async_fifo;

    localparam DATA_WIDTH = 8;
    localparam ADDR_WIDTH = 4;
    
    localparam WCLK_PERIOD = 10; // 100 MHz Write Clock
    localparam RCLK_PERIOD = 25; //  40 MHz Read Clock

    logic w_clk;
    logic w_rst;
    logic w_en;
    logic full;
    logic [DATA_WIDTH-1:0] data_in;

    logic r_clk;
    logic r_rst;
    logic r_en;
    logic empty;
    logic [DATA_WIDTH-1:0] data_out;

    async_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dut (
        .w_clk(w_clk),
        .w_rst(w_rst),
        .w_en(w_en),
        .data_in(data_in),
        .full(full),
        .r_clk(r_clk),
        .r_rst(r_rst),
        .r_en(r_en),
        .data_out(data_out),
        .empty(empty)
    );

    // Clock Generation
    initial begin
        w_clk = 0;
        forever #(WCLK_PERIOD/2) w_clk = ~w_clk;
    end

    initial begin
        r_clk = 0;
        forever #(RCLK_PERIOD/2) r_clk = ~r_clk;
    end
    
    // Task to write a single word into FIFO
    task automatic write_word(input logic [DATA_WIDTH-1:0] data);
        @(posedge w_clk);
        if (full) begin
            $display("Write skipped! FIFO is FULL.");
        end else begin
            w_en  <= 1'b1;
            data_in <= data;
            $display("Writing Data: 0x%h", data);
        end
        @(posedge w_clk);
        w_en  <= 1'b0;
    endtask

    // Task to read a single word from FIFO
    task automatic read_word();
        @(posedge r_clk);
        if (empty) begin 
            $display("Read skipped! FIFO is EMPTY.");
            @(posedge r_clk); // Still wait the clock cycle to mimic the timing
        end else begin
            r_en <= 1'b1;
            @(posedge r_clk);
            r_en <= 1'b0;
            $display("Reading Data: 0x%h", data_out);
        end
    endtask

    // Main Test
    initial begin
        w_en   = 0;
        data_in  = 0;
        r_en   = 0;
        w_rst = 1;
        r_rst = 1;

        // Reset
        #(WCLK_PERIOD * 2);
        w_rst = 0;
        r_rst = 0;
        #(WCLK_PERIOD * 2);

        // Performing Write & Read operations
        write_word(8'hAA);
        write_word(8'hBB);
        
        // Wait for synchronization delay before reading
        #(RCLK_PERIOD * 3); 
        read_word();
        read_word();

        // Fill the FIFO until Full flag asserts
        for (int i = 1; i <= 18; i++) begin
            write_word(i);
            if (full) begin
                $display("[%0t NT] FULL flag detected successfully at item %0d!", $time, i);
            end
        end

        // Empty the FIFO until Empty flag asserts
        for (int j = 1; j <= 18; j++) begin
            read_word();
            if (empty) begin
                $display("[%0t NT] EMPTY flag detected successfully at read %0d!", $time, j);
            end
        end

        //Simultaneous Write and Read
        fork
            begin
                for(int k=0; k<10; k++) write_word(8'hF0 + k);
            end
            begin
                // Delay read slightly so data is available
                #(RCLK_PERIOD * 3);
                for(int l=0; l<10; l++) read_word();
            end
        join

        // Finish simulation
        #(WCLK_PERIOD * 10);
        $finish;
    end

    // Safety Check
    always @(posedge w_clk) begin
        if (full && w_en) begin
            $error("Violation: w_en asserted while FIFO is FULL!");
        end
    end

    
    always @(posedge r_clk) begin
        if (empty && r_en) begin
            $error("Violation: r_en asserted while FIFO is EMPTY!");
        end
    end

endmodule