module hdmi_tb();

    logic               sclk;
    logic               rst_n;
    logic               hs;
    logic               vs;
    logic               video_active;
    logic               rdata;
    logic               gdata;
    logic               bdata;


    hdmi_drive u_hdmi_drive(.sclk(sclk)
                           ,.rst_n(rst_n)
                           ,.hs(hs)
                           ,.vs(vs)
                           ,.video_active()
                           ,.rdata()
                           ,.gdata()
                           ,.bdata()
    );

//    hdmi_drive u_hdmi_drive(.clk(sclk)
//                           ,.rst(!rst_n)
//                           ,.hs(hs)
//                           ,.vs(vs)
//                           ,.de()
//                           ,.rgb_r()
//                           ,.rgb_g()
//                           ,.rgb_b()
//    );


    always #10 sclk = ~sclk;

    initial begin
        sclk = 0;
        rst_n = 0;
        repeat (10) begin
            @(posedge sclk);
        end
        #1ns;
        rst_n = 1;
    end
 
    initial begin
        $vcdplusfile("./111.vpd");
        $vcdplusmemon;
        $vcdpluson;
        #50ms;
        $finish;
    end
endmodule
