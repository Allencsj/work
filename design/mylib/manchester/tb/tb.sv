module man_tb();
    logic    [7:0]    din;
    logic             rstn;
    logic             clk;
    logic             wr;
    logic             mdo;
    logic             ready;

    //manchester instance
    manch_en dut (.rstn   (rstn  )
                 ,.clk16x (clk   )
                 ,.wrn    (wr    )
                 ,.din    (din   )
                 ,.tbre   (ready )
                 ,.mdo    (mdo   ));


    initial begin
        rstn = 1'b0;
        clk  = 1'b0;
        din  = 8'b0;
        wr   = 1'b0;
    end

    integer me_chann;

    initial begin
        me_chann = $fopen("manch_en.rpt");
        $fdisplay (me_chann,"\nSimulation of Manchester encoder Start!");
        $timeformat(-9,,,5);
    end

    parameter clk_period = 10,setup_time = clk_period/4;

    always #(clk_period/2) clk = ~clk;

    initial begin
        fork
            begin
                #10000ns;
                $finish;
            end
        join_none

        $fmonitor (me_chann,"rstn=%b,wr=%b,din=%x,mdo=%b,ready=%b",rstn,wr,din,mdo,ready);
        #5 rstn = 1'b1;
        #15 rstn = 1'b0;
        #(3*clk_period - setup_time) din = 8'hff;
        #(1*clk_period) wr = 1'b1;
        #(1*clk_period) wr = 1'b0;
        wait(ready);
        #(20*clk_period) din = 8'haa;
        #(1*clk_period) wr = 1'b1;
        #(1*clk_period) wr = 1'b0;
        wait(ready);
        #(20*clk_period) din = 8'h00;
        #(1*clk_period) wr = 1'b1;
        #(1*clk_period) wr = 1'b0;
        wait(ready);
        #(20*clk_period) din = 8'hf0;
        #(1*clk_period) wr = 1'b1;
        #(1*clk_period) wr = 1'b0;
        wait(ready);
        #(20*clk_period) din = 8'h0f;
        #(1*clk_period) wr = 1'b1;
        #(1*clk_period) wr = 1'b0;
        wait(ready);
        #(100*clk_period);
        $fdisplay(me_chann,"\nSimulation of Manchester encoder complete!");
        $finish;
    end

    initial begin
        $vcdplusfile("./111.vpd");
        $vcdplusmemon;
        $vcdpluson;
    end
              



    
endmodule
