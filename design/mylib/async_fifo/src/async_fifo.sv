//Asynchronous FIFO

module async_fifo 
(   parameter   FIFO_DEPTH  =   64,
    parameter   FIFO_WIDTH  =   32

)

(
    //reset
     input                          rst_n

    //write
    ,input                          winc    //write input clk
    ,input                          wen     //write enable
    ,input  [FIFO_WIDTH-1:0]        din     //data input

    //read
    ,input                          rinc    //read input clk
    ,input                          ren     //read ebable
    ,input  [FIFO_WIDTH-1:0]        dout    //data output

    ,output                         full
    ,output                         empty

    );



endmodule
