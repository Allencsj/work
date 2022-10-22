//Asynchronous FIFO

module async_fifo 
#(   parameter   FIFO_DEPTH  =   64,
    parameter   FIFO_WIDTH  =   32,
    parameter   ADDR_WIDTH  =   6

)
(
    //reset
     input                          rst_n

    //write
    ,input                          wclk    //write input clk
    ,input                          wen     //write enable
    ,input  [FIFO_WIDTH-1:0]        wdata   //write data input
    ,output                         wfull   //write full signal

    //read
    ,input                          rclk    //read input clk
    ,input                          ren     //read ebable
    ,output reg [FIFO_WIDTH-1:0]        rdata   //read data output
    ,output                         rempty

    );

    reg [FIFO_WIDTH-1:0] fifo_mem [FIFO_DEPTH-1:0];

    reg [ADDR_WIDTH:0] waddr;
    reg [ADDR_WIDTH-1:0] waddr_fifo;
    reg [ADDR_WIDTH:0] wptr;
    reg [ADDR_WIDTH:0] wptr_r;
    reg [ADDR_WIDTH:0] wptr_rr;

    reg [ADDR_WIDTH:0] raddr;
    reg [ADDR_WIDTH-1:0] raddr_fifo;
    reg [ADDR_WIDTH:0] rptr;
    reg [ADDR_WIDTH:0] rptr_r;
    reg [ADDR_WIDTH:0] rptr_rr;

    //-------------------------------------
    //write part
    //-------------------------------------

    //write data into fifo mem
    always@(posedge wclk) begin
        if (wen ==  1'b1 && wfull == 1'b0) begin
            fifo_mem[waddr_fifo] <=  wdata;
        end
    end

    //write addr
    always@(posedge wclk or negedge rst_n) begin
        if (rst_n   ==  1'b0) begin
            waddr   <=  {(2**ADDR_WIDTH-1){1'b0}};
        end else if (wen    ==  1'b1) begin
            waddr   <=  waddr + 1'b1;
        end else begin
            waddr   <=  waddr;
        end
    end

    //grey2binary
    assign wptr = (waddr>>1) ^ waddr;
    assign waddr_fifo = waddr[ADDR_WIDTH-1:0];

    //read part
    always@(posedge rclk or negedge rst_n) begin
        if (rst_n   ==  1'b0) begin
            rdata   <=  'b0;
        end else if (ren    ==  1'b1 && rempty  ==  1'b0) begin
            rdata   <=  fifo_mem[raddr_fifo];
        end else begin
            rdata   <= 'b0;
        end
    end

    //read addr
    always@(posedge rclk or negedge rst_n) begin
        if (rst_n   ==  1'b0) begin
            raddr   <=  'b0;
        end else if (ren    ==  1'b1 && rempty == 1'b0) begin
            raddr   <=  raddr + 1'b1;
        end
    end

    //grey2binary
    assign rptr = (raddr>>1) ^ raddr;
    assign raddr_fifo = raddr[ADDR_WIDTH-1:0];

    //clk domain sync
    always@(posedge rclk or negedge rst_n) begin
        if (rst_n   ==  1'b0) begin
            wptr_r   <=  'b0;
            wptr_rr  <=  'b0;
        end else begin
            wptr_r  <=  wptr;
            wptr_rr <=  wptr_r;
        end
    end

    always@(posedge wclk or negedge rst_n) begin
        if (rst_n   ==  1'b0) begin
            rptr_r   <=  'b0;
            rptr_rr  <=  'b0;
        end else begin
            rptr_r  <=  rptr;
            rptr_rr <=  rptr_r;
        end
    end

    assign wfull = wptr == {{~rptr_rr[ADDR_WIDTH:ADDR_WIDTH-1]},rptr_rr[ADDR_WIDTH-2:0]};
    assign rempty = rptr == wptr_rr;

endmodule
