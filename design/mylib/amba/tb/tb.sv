module tb();
    logic               pclk
    logic               presetn
    logic               start
    logic   [31:0]      addr
    logic   [31:0]      wdata
    logic               wr_rd
    logic               pready
    logic   [31:0]      prdata
    logic   [31:0]      paddr
    logic               psel
    logic               penable
    logic               pwrite
    logic   [31:0]      pwdata

    logic   [31:0]      r0;
    logic   [31:0]      r1;
    logic   [31:0]      r2;

    apb_slave_test u_apb_slave(
                            .pclk       (pclk)
                            ,.presetn   (presetn)
                            ,.psel      (psel)
                            ,.penable   (penable)
                            ,.pwrite    (pwrite)
                            ,.paddr     (paddr)
                            ,.pwdata    (pwdata)
                            ,.prdata    (prdata)
                            ,.pready    (pready)
                            ,.r0        (r0)
                            ,.r1        (r1)
                            ,.r2        (r2)
    
    );

    apb_master u_apb_master(
                        .pclk           (pclk)
                        .,presetn       (presetn)
    
                        .,start         (start)
                        .,addr          (addr)
                        .,wdata         (wdata)
                        .,wr_rd         (wr_rd)
                        .,o_data        (o_data)

                        .,pready        (pready)
                        .,prdata        (prdata)
                        .,paddr         (paddr)
                        .,psel          (psel)
                        .,penable       (penable)
                        .,pwrite        (pwrite)
                        .,pwdata        (pwdata)
    
    );

    always #10 pclk = ~pclk;

    initial begin
        pclk = 0;
        presetn = 1'b0;
        start    =   0;
        addr    =   32'b0;
        wdata   =   32'b0;
        wr_rd   =   1'b0;
    end

    integer i;
    initial begin
        wait (!presetn);
        repeat(10) @(posedge pclk)
        for (i=1;i<100;i++) begin
            start = 1;
            repeat(1) @(posedge pclk)
            start = 0;
            addr  = 32'b4;
            wr_rd   =   1;
            wdata   =   i;
            repeat(4) @(posedge pclk)
            start = 1;
            addr  = 32'b4;
            wr_rd   =   0;
            repeat(3) @(posedge pclk)
            if (o_data  ==  i) begin
                $display("PASS");
            end else begin
                $display("FAIL");
                #1;
                $finish;
            end
        end
       
    end





endmodule
