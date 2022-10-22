module uart_tb();
    logic           uclk;
    logic           rst_n;
    logic           rxd;

    logic [8:0]     rx_data;
    logic           rx_done;
    logic           rx_err;
    logic           txd;

    localparam  BPS_CNT = 50000000/115200;

    uart u_uart(.uclk (uclk)
                     ,.rst_n(rst_n)
                     ,.rxd(rxd)
                     ,.txd(txd)
    );

    always #10 uclk = ~uclk;

    initial begin
        uclk = 0;
        rst_n = 0;
        rxd = 1;
        #200ns;
        rst_n = 1;
    end

    int clk_cnt;
    reg [8:0] din;
    integer i;
    reg [7:0] data_tmp;
    initial begin
        din = 0;
        wait(rst_n  ==  1'b1);
        repeat (BPS_CNT) begin
            $display("1111111");
            @(posedge uclk);
        end
        for (i=0;i<4;i++) begin
            $display("Data num = %d",i);
            rx_trans(i+1);
          //  wait(rx_done);
          //  if (rx_data == (din+1)) begin
//        //    if (rx_data == 9'h055) begin
          //      $display("PASS!");
          //  end else begin
          //      $display("FAIL");
          //      $display("din=%d,dout=%d",(din+1),rx_data);
//        //        $display("din=%h,dout=%d",9'h055,rx_data);
          //      $finish;
          //  end
          //  din = din + 1;
            @(posedge uclk);
            @(posedge uclk);
        end
        for (i=0;i<4;i++) begin
            get_txd(data_tmp);
        end
       // $finish;
    end

    integer k;
    task rx_trans(input [8:0] din);
        k = 0;
        rxd = 1'b0;
//        repeat (BPS_CNT)
//            @(posedge uclk);
//        $display("00");
        forever begin
//            $display("11");
            if (clk_cnt == BPS_CNT) begin
                if (k == 9) begin
                    break;
                end
                rxd = din[k];
                clk_cnt = 0;
                k = k + 1;
            end
            clk_cnt = clk_cnt + 1;
//            $display("clk_cnt=%d",clk_cnt);
            @(posedge uclk);
        end
        clk_cnt = 0;
//        @(posedge uclk);
        rxd = 1;
        repeat (BPS_CNT)
            @(posedge uclk);

    endtask

    wire txd_r = txd;
    integer m;
    task get_txd(output reg [7:0] data);
        data = 0;
        wait(txd_r == 1'b0);
        if (txd_r == 1'b0) begin
            wait (clk_cnt == BPS_CNT - 1);
            m = 0;
            repeat(8) begin
                wait(clk_cnt == BPS_CNT/2);
                data[m] = txd_r;
                m = m+1;
                @(posedge uclk);
                @(posedge uclk);
//                $display("data value is %d",data);
            end
        end
        wait(clk_cnt == BPS_CNT/2);
        if (txd_r != 1'b1) begin
            $display("stop bit error!!");
            $finish;
        end
        wait(clk_cnt == BPS_CNT/2);
        wait(clk_cnt == BPS_CNT);
    endtask

    initial begin
        $vcdplusfile("./111.vpd");
        $vcdplusmemon;
        $vcdpluson;
//        #150000ns;
//        $finish;
    end


endmodule
