`include "test.sv"

module  top;
    bit clk;
    
    counter_if intf(clk);

    counter DUV (.clk         (clk)
                ,.rst         (intf.rst)
                ,.load        (intf.load)
                ,.updown      (intf.updown)
                ,.data        (intf.data)
                ,.data_out    (intf.data_out)
                );

    bind DUV counter_assertation C_A (.clk(clk)
                                  ,.rst(intf.rst)
                                  ,.load(intf.load)
                                  ,.updown(intf.updown)
                                  ,.data(intf.data)
                                  ,.count(intf.data_out)
                                  );

    test test_h;

    initial begin
        test_h = new(intf,intf,intf);
        test_h.build_and_run();
    end

    initial begin
        clk = 0;
        forever #10ns clk = ~clk;
    end

    initial begin
        $vcdplusfile("./111.vpd");
        $vcdplusmemon;
        $vcdpluson;
//        #5500ns;
//        $finish;
    end



endmodule
