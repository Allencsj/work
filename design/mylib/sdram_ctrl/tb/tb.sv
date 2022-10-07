module sdram_tb();
    //system input
    logic              sclk;
    logic              srst_n;

    //sdram work signal
    logic              sdr_start;
    logic              wr_req;
    logic              rd_req;
    logic              wr_ack;
    logic              rd_ack;
    logic              wr_done;
    logic              rd_done;

    //sdram control signals
    logic              scke;
    logic     [10:0]   saddr;
    logic     [31:0]   sdata_i;
    logic     [31:0]   sdata_o;
    logic              sdata_oe_n;
    logic     [ 1:0]   sba;
    logic              scs_n;
    logic              sras_n;
    logic              scas_n;
    logic              swe_n;
    logic     [ 3:0]   sdqm;

    initial begin
        sclk = 0;
        srst_n = 0;
        sdr_start = 0;
        wr_req = 0;
        rd_req = 0;
        repeat(10)
            @(posedge sclk);
        srst_n = 1;
        repeat(10)
            @(posedge sclk);

        sdr_start = 1;
    end

    wire #2 sclk_d = sclk;

    always #3 sclk = ~sclk;

    sdram_top u_sdram_top(
                        //system input
                        .sclk       (sclk       ),
                        .srst_n     (srst_n     ),
                                                 
                        //sdram work signal      
                        .sdr_start  (sdr_start  ),
                        .wr_req     (wr_req     ),
                        .rd_req     (rd_req     ),
                        .wr_ack     (wr_ack     ),
                        .rd_ack     (rd_ack     ),
                        .wr_done    (wr_done    ),
                        .rd_done    (rd_done    ),
                                                 
                        //sdram control signals  
                        .scke       (scke       ),
                        .saddr      (saddr      ),
                        .sdata_i    (sdata_i    ),
                        .sdata_o    (sdata_o    ),
                        .sdata_oe_n (sdata_oe_n ),
                        .sba        (sba        ),
                        .scs_n      (scs_n      ),
                        .sras_n     (sras_n     ),
                        .scas_n     (scas_n     ),
                        .swe_n      (swe_n      ),
                        .sdqm       (sdqm       )
    );

    wire [31:0] sdata = ~sdata_oe_n ? sdata_o : 32'hz;
    mt48lc2m32b2 sdram_model(
                            .Dq     (sdata      ),
                            .Addr   (saddr      ),
                            .Ba     (sba        ),
                            .Clk    (sclk_d     ),
                            .Cke    (scke       ),
                            .Cs_n   (scs_n      ),
                            .Ras_n  (sras_n     ),
                            .Cas_n  (scas_n     ),
                            .We_n   (swe_n      ),
                            .Dqm    (sdqm       )
    );

    integer i,j,k;
    initial begin
        repeat(15) begin
            @(posedge sclk);
        end
        for (i=0;i<2097152;i++) begin
//        for (i=0;i<1000;i++) begin
            @(posedge sclk)
            wr_req = 1'b1;
            wait(wr_ack);
            wr_req = 1'b0;
            @(posedge sclk)
            sdata_i = i+1;
            wait(wr_done);
        end
//        $finish;
        @(posedge sclk_d)
        k=0;
        for (i=0;i<2097152;i++) begin
//        for (j=0;j<1000;j++) begin
            @(posedge sclk_d)
            rd_req = 1'b1;
            wait(rd_ack);
            $display("2323232");
            rd_req = 1'b0;
            forever begin
                @(posedge sclk_d)
                if (|sdata !=0) begin
//                    $display("11111");
                    $display("sdata = %d,i+1=%d",sdata,k+1);
                    if (sdata   ==  (k+1)) begin
                        $display("Num:%d PASS!",k);
                        break;
                    end
                    else begin
                        #1ns;
                        $finish;
                    end
                end
            end
            wait(rd_done);
            k = k + 1;
        end
        $finish;
    end
    
    initial begin
//        $vcdplusfile("./111.vpd");
//        $vcdplusmemon;
//        $vcdpluson;
     //   #400000ns;
//        $finish;
    end

endmodule
