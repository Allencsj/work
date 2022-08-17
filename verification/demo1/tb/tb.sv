// tb for mic

module Mram_tb(
    
    output logic [ram_width-1:0] wrdata,
    input logic [ram_width-1:0] rddata,
    output logic [ram_depth-1:0] wraddr,
    output  logic [ram_depth-1:0] rdaddr,
    output logic                 wr_en ,
    output logic                 rd_en ,
    input   wrclk,
    input   rdclk,
    input   rst_n
    );

    parameter ram_width  = 32;
    parameter ram_depth  = 32;

    //configure enable signal
    initial begin
        wrdata =0;
        rddata =0;
        wraddr =0;
        rdaddr =0;
        wr_en =0;
        rd_en =0;
        #200 wr_en=1;
        #10  rd_en=1;
    end
 
    always @ (posedge wrclk) begin
    if (wr_en) begin
        for (i=0;i<ram_depth;i++) begin
        wraddr = wraddr + 1;
        #10
        wrdata = wrdata + 1;
        end
    end
end

    always @ (posedge rdclk) begin
        if (rd_en) begin
            rdaddr = rdaddr + 1;
        end
    end
//    always @ (posedge wrclk) begin
//        if (~rst_n) begin
//            wrdata <= 'b0;
//            wraddr <= 'b0;
//        end else (wr_en) begin
//            wrdata <= wrdata + 1'b1;
//            addr_a <= addr_a + 1'b1;
//        end
//    end
//
//    always @ (posedge clk) begin
//        if (rd_b) begin
//            addr_b <= addr_b + 1'b1;
//        end else begin
//            addr_b <= 0;
//        end
//    end

    //check value is right or not
//
//    always @ (posedge clk)
//        if (q) begin
//            mem <=1;
//            meme <=1;
//        end else if (mem == 1) begin
//            mem <= 0;
//            $display ("the test is right! q=1!");
//        end
//
//    //dump wave
//    initial begin
//        $vcdpluson;
//    end
endmodule
