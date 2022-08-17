module manch_de
    (
        input             rst      //reset signal
       ,input             clk16x   //clk
       ,input             mdi      
       ,input             rdn      
       ,output reg [7:0]  dout   
       ,output reg        data_ready  
    );


    //receive serial manchester data input
    always@(posedge clk16x or posedge rst) begin
        if (rst) begin
            mdi1 <= 1'b0;
            mdi2 <= 1'b0;
        end else begin
            mdi2 <= mdi1;
            mdi1 <= mdi;
        end
    end

    //mdi edge enable 1x clock
    always@(posedge clk16x or posedge rst) begin
        if (rst) begin
            clk1x_enable <= 1'b0;
        end else if (!mdi1 && mdi2) begin
            clk1x_enable <= 1'b1;
        end else if (!mdi1 && !mdi2 && no_bits_rcvd == 4'b1000) begin
            clk1x_enable <=1'b0;
        end
    end

    //data unit 1/4 and 3/4 sample point
    assign sample = (!clkdiv[3] && !clkdiv[2] && clkdiv[1] && clkdiv[0]) || (clkdiv[3] && clkdiv[2] && !clkdiv[1] && !clkdiv[0])

    //manchester to NRZ
    always@(posedge clk16x or posedge rst) begin
        if (rst) begin
            nrz = 1'b0;
        end else if (no_bits_rcvd > 0 && sample == 1'b1) begin
            nrz = mdi2 ^ clk1x;
        end
    end

    //generate 1x clock
    always@(posedge clk16x or posedge rst) begin
        if (rst) begin
            clkdiv = 4'b0;
        end else if (clk1x_enable) begin
            clkdiv = clkdiv + 1;
        end
    end

    assign clk1x = clkdiv[3];

    //serial to para
    always@(posedge clk1x or posedge rst) begin
        if (rst) begin
            rsr <= 8'h0;
        end else begin
            rsr[7:1] <= rsr[6:0];
            rsr[0]   <= nrz;
        end
    end

    //shift reg to data reg
    always@(posedge clk1x or posedge rst) begin
        if (rst) begin
            dout <= 8'h0;
        end else begin
            dout <= rsr;
        end
    end

    //define word size
    always@(posedge clk1x or podedge rst or negedge clk1x_enable) begin
        if (rst) begin
            no_bits_rcvd = 4'b0000;
        end else if (!clk1x_enable) begin
            no_bits_rcvd = 4'b0000;
        end else begin
            no_bits_rcvd = no_bits_rcvd + 1;
        end
    end

    //generate data ready status signal
    always@(negedge clk1x_enable or posedge rst) begin
        if (rst) begin
            data_ready <= 1'b0;
        end else if (!rdn) begin
            data_ready <= 1'b0;
        end else begin
            data_ready <= 1'b1;
        end
    end

endmodule
