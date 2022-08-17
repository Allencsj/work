module manch_en
    (
        input             rstn     //reset signal
       ,input             clk16x   //clk
       ,input             wrn      //write enable
       ,input    [7:0]    din      //data input
       ,output reg        tbre     //output ready signal
       ,output            mdo      //manchester data output
    );

    reg rst_1,rst_2;
    reg wrn_1,wrn_2;
    reg clk1x_en;
    reg [3:0] clkdiv;
    reg [3:0] no_bits_send;
    reg [7:0] tbr;
    reg [7:0] tsr;
    reg parity;
    wire sync_rstn;
    wire clk1x;
    wire clk1x_dis;

    //asynchronous reset and synchronous release
    always_ff@(posedge clk16x or posedge rstn) begin
        if (rstn) begin
            rst_1 <= 1'b1;
            rst_2 <= 1'b1;
        end else begin
            rst_1 <= rstn;
            rst_2 <= rst_1;
        end
    end

    assign sync_rstn = rst_2;

    //write pluse detect
    always_ff@(posedge clk16x) begin
        if (sync_rstn) begin
            wrn_1 <= 1'b1;
            wrn_2 <= 1'b1;
        end else begin
            wrn_1 <= wrn;
            wrn_2 <= wrn_1;
        end
    end

    //enable clk signal after detect wrrite pluse
    always_ff@(posedge clk16x) begin
        if (sync_rstn) begin
            clk1x_en <= 1'b1;
        end else if (wrn_2 == 1'b0 & wrn_1 == 1'b1)begin
            clk1x_en <= 1'b1;
        end else if (no_bits_send == 4'b1111) begin
            clk1x_en <= 1'b0;
        end
    end

    //generate buffer empty signal
    always_ff@(posedge clk16x) begin
        if (sync_rstn) begin
            tbre <= 1'b1;
        end else if (wrn_2 == 1'b0 & wrn_1 == 1'b1) begin
            tbre <= 1'b0;
        end else if (no_bits_send == 4'b1010) begin
            tbre <= 1'b1;
        end else begin
            tbre <= 1'b0;
        end
    end

    //after detecting write pluse, load transfer buffer data
    always_ff@(posedge clk16x) begin
        if (sync_rstn) begin
            tbr <= 8'b0;
        end else if(wrn_1 == 1'b1 & wrn_2 == 1'b0) begin
            tbr <= din;
        end
    end

    //internal clk
    always_ff@(posedge clk16x) begin
        if (sync_rstn) begin
            clkdiv <= 4'b0000;
        end else if (clk1x_en == 1'b1) begin
            clkdiv <= clkdiv + 1'b1;
        end
    end
    
    assign clk1x = clkdiv[3];

    //load tbr tsr to tsr
    always_ff@(posedge clk1x or posedge rstn) begin
        if (rstn) begin
            tsr <= 8'h0;
        end else if (no_bits_send == 4'b0001) begin
            tsr <= tbr;
        end else if (no_bits_send >= 4'b0010 && no_bits_send < 4'b1010) begin
            tsr[7:0] <= {tsr[6:0],1'b0};
        end
    end

    //NRZ(non return zero) into manchester encode
    assign mdo = tsr[7] ^ clk1x;

    //generate parity
    always_ff@(posedge clk1x or posedge rstn) begin
        if (rstn) begin
            parity <= 1'b0;
        end else begin
            parity <= parity ^ tsr[7];
        end
    end

    //caulate bits number
    always_ff@(posedge clk1x or posedge rstn) begin
        if (rstn) begin
            no_bits_send <= 4'b0;
        end else if (tbre) begin
            no_bits_send <= 4'b0;
        end else if (clk1x_en) begin
            no_bits_send <= no_bits_send + 1'b1;
        end else if (clk1x_dis) begin
            no_bits_send <= 4'b0;
        end
    end

    assign clk1x_dis = !clk1x_en;


endmodule
