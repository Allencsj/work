//-----------------------------
// 4-bit loadable up_down counter
//-----------------------------

module counter(
     input            clk
    ,input           rst
    ,input           load
    ,input           updown
    ,input [3:0]     data
    ,output reg [3:0] data_out
    );

    always @(posedge clk) begin
        if (rst)
            data_out <= 4'b0;
        else if (load)
            data_out <= data;
        else
            data_out <= ((updown)?(data_out + 1'b1) : (data_out - 1'b1));
    end

    


endmodule
