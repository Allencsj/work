module aync_fifo_tb();

    parameter FIFO_DEPTH = 64;
    parameter FIFO_WIDTH = 32;
    parameter ADDR_WIDTH = 6;

    logic               rst_n;
    logic               wclk;
    logic               wen;
    logic  [FIFO_WIDTH-1:0]             wdata;
    logic               wfull;

    logic               rclk;
    logic               ren;
    logic  [FIFO_WIDTH-1:0]             rdata;
    logic               rempty;

    async_fifo #(
                            .FIFO_DEPTH ( 64 ),
                            .FIFO_WIDTH ( 32 ),
                            .ADDR_WIDTH ( 6  )
    ) u_async_fifo
    (
                            .rst_n  (rst_n  )
                            ,.wclk  (wclk   )
                            ,.wen   (wen    )
                            ,.wdata (wdata  )
                            ,.wfull (wfull  )

                            ,.rclk  (rclk   )
                            ,.ren   (ren    )
                            ,.rdata (rdata  )
                            ,.rempty(rempty )
    );

    initial begin
        wclk = 0;
        rclk = 0;
        wen  = 0;
        ren  = 0;
        wdata = 0;
        rst_n = 0;
        #100ns;
        rst_n = 1;
    end

    always #23 wclk = !wclk;
    always #10 rclk = !rclk;

    integer i;
    logic [FIFO_WIDTH-1:0] rdata_t;
    int fd [$];
    int tmp;
    initial begin
        wait(rst_n);
        fork
            for (i=1;i<100;i++) begin
                wait(wfull == 1'b0);
                fifo_write(i);
                fd.push_back(i);
            end
            forever begin
                @(posedge rclk);
                $display("%d",fd.size());
                if (fd.size()<2) begin
                    $display("1111");
                    continue;
                end
                fifo_read(rdata_t);
//                $display("rdata_t = %d",rdata_t);
//                $display("wdata = %d",fd.pop_front());
                
                if (fd.size() != 0) begin
                    tmp = fd.pop_front();
                    if (rdata_t == tmp) begin
                        $display("PASS");
                    end else begin
                        $display("wdata=%d,rdata=%d",tmp,rdata_t);
                        $display("FAIL");
                        #1ns;
                        $finish;
                    end
                end
            end
        join

    end

    task fifo_write(input [31:0] data);
        if (wfull == 1'b0) begin
            @(posedge wclk)
            wen = 1;
            wdata = data;
            @(posedge wclk)
            wen = 0;
        end
    endtask

    task fifo_read(output [31:0] data);
        if (rempty  ==  1'b0) begin
            @(posedge rclk)
            ren = 1;
            #1ns;
            data = rdata;
            @(posedge rclk);
            ren = 0;
        end
    endtask

    initial begin
        $vcdplusfile("./111.vpd");
        $vcdplusmemon;
        $vcdpluson;
    end



endmodule
