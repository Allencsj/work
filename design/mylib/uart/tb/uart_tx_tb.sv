module tx_tb();

    logic           uclk;
    logic           rst_n;
    logic           txd;

    logic [ 7:0]    tx_data;
    logic           tx_en;
    logic           tx_done;

    localparam  BPS_CNT = 50000000/115200;
    integer clk_cnt;

    uart_tx u_uart_tx(.uclk(uclk)
                     ,.rst_n(rst_n)
                     ,.tx_data(tx_data)
                     ,.tx_en(tx_en)
                     ,.txd(txd)
                     ,.tx_done(tx_done)
    );

    always #10 uclk = ~uclk;

    initial begin
        clk_cnt = 0;
        uclk    = 0;
        rst_n   = 0;
        tx_data = 8'b0;
        tx_en   = 0;
        #200ns;
        rst_n   = 1;
    end

    integer i;
    reg [7:0] data_tmp;
    initial begin
        wait(rst_n  ==  1'b1);
        repeat(8) begin
            @(posedge uclk);
        end
        for (i=1;i<100;i++) begin
            fork
                get_txd(data_tmp);
            join_none
            tx_en = 1;
            tx_data = i;
            @(posedge uclk)
//            #1;
            tx_en = 0;
            wait(tx_done);
            #1;
            if (data_tmp != i) begin
                $display("data%d compare wrong!!",i);
                $display("ori data = %d, get data = %d",i,data_tmp);
                $finish;
            end else begin
                $display("data%d compare right!!",i);
            end
            @(posedge uclk);
        end
        $finish;
    end

    initial begin
        forever begin
            wait(tx_en  ==  1'b1);
            @(posedge uclk)
            forever begin
                @(posedge uclk)
                clk_cnt = clk_cnt + 1'b1;
                if (clk_cnt == BPS_CNT)
                    clk_cnt = 0;
                if (tx_done)
                    break;
            end
        end
    end

    wire txd_r = txd;
    integer k;
    task get_txd(output reg [7:0] data);
        data = 0;
        wait(txd_r == 1'b0);
        if (txd_r == 1'b0) begin
            wait (clk_cnt == BPS_CNT - 1);
            k = 0;
            repeat(8) begin
                wait(clk_cnt == BPS_CNT/2);
                data[k] = txd_r;
                k = k+1;
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
        wait(tx_done == 1'b1);
    endtask

    initial begin
        $vcdplusfile("./111.vpd");
        $vcdplusmemon;
        $vcdpluson;
    end

endmodule
