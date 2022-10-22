//uart top

module uart(
     input               uclk
    ,input               rst_n

    ,input               rxd
    ,output              txd

    //apb master
    

);

//receiver fifo
reg [31:0]              rx_fifo_din;     //data into rx fifo
reg [31:0]              rx_fifo_dout;     //data rx fifo output
reg [ 2:0]              drx_cnt;
wire                    rx_fifo_wen;     //fifo write enable
reg                     rx_fifo_ren;     //fifo read enable
wire                    rx_wfull;          //fifo write full
wire                    rx_empty;        //rx fifo empty
reg [ 7:0]              rx_fifo_dnum;
wire [31:0]             rx_fifo_out;

//transmitor fifo
reg [31:0]              tx_fifo_din;    //data tx fifo input
reg [31:0]              tx_fifo_dout;    //data tx fifo output

//uart tx rx
reg  [8:0]               rx_data;
wire                    rx_done;
wire                    rx_err;

wire [7:0]              tx_data;
wire                    tx_en;
wire                    tx_done;

    uart_tx u_uart_tx(.uclk         (uclk)
                     ,.rst_n        (rst_n)
                     ,.tx_data      (tx_data)
                     ,.tx_en        (tx_en)
                     ,.txd          (txd)
                     ,.tx_done      (tx_done)
    );

    uart_rx u_uart_rx(.uclk         (uclk)
                     ,.rst_n        (rst_n)
                     ,.rxd          (rxd)
                     ,.rx_data      (rx_data)
                     ,.rx_done      (rx_done)
                     ,.rx_err       (rx_err)
    );

    //uart rx reveive data into fifo buffer
    always@(posedge uclk or negedge rst_n) begin
        if (rst_n   ==  1'b0) begin
            rx_fifo_din <=  32'b0;
        end else if (drx_cnt    ==  3'd4) begin
            rx_fifo_din <=  32'b0;
        end else if (rx_done    ==  1'b1) begin
            rx_fifo_din <=  {rx_fifo_din[23:0],rx_data[7:0]};
        end
    end

    always@(posedge uclk or negedge rst_n) begin
        if (rst_n   ==  1'b0) begin
            drx_cnt <=  3'd0;
        end else if (drx_cnt    ==  4'd4) begin
            drx_cnt <=  3'd0;
        end else if (rx_done    ==  1'b1) begin
            drx_cnt <=  drx_cnt + 1'b1;
        end
    end

    //rx_fifo write enable
    assign rx_fifo_wen = (rx_wfull   ==  1'b0) ? ((drx_cnt == 4'd4) ? 1'b1 : 1'b0) : 1'b0;

    //fifo data num count
    always@(posedge uclk or negedge rst_n) begin
        if (rst_n   ==  1'b0) begin
            rx_fifo_dnum    <=  8'd0;
        end else if (drx_cnt    ==  3'd4) begin
            rx_fifo_dnum    <=  rx_fifo_dnum + 1'b1;
        end else if (rx_fifo_ren ==  1'b1) begin
            rx_fifo_dnum    <=  rx_fifo_dnum - 1'b1;
        end
    end

    //rx_fifo read enable
    always@(posedge uclk or negedge rst_n) begin
        if (rst_n   ==  1'b0) begin
            rx_fifo_ren <=  1'b0;
        end else if (rx_fifo_ren    ==  1'b1) begin
            rx_fifo_ren <=  1'b0; 
        end else if (rx_empty ==  1'b0 && rx_fifo_wen ==  1'b0) begin
            rx_fifo_ren <=  1'b1;
        end
    end

    //fifo instance and data input
    async_fifo#(.FIFO_DEPTH(64)
               ,.FIFO_WIDTH(32)
               ,.ADDR_WIDTH(6)
               ) rx_fifo
               (.rst_n     (rst_n      )
               //write
               ,.wclk      (uclk       )
               ,.wen       (rx_fifo_wen )
               ,.wdata     (rx_fifo_din)
               ,.wfull     (rx_wfull      )
               //read
               ,.rclk      (uclk       )
               ,.ren       (rx_fifo_ren )
               ,.rdata     (rx_fifo_out)
               ,.rempty    (rx_empty  )
    );

    reg tx_en_d1;
    always@(posedge uclk or negedge rst_n) begin
        if (rst_n == 1'b0) begin
            tx_en_d1    <=  1'b0;
        end else begin
            tx_en_d1    <=  rx_fifo_ren;
        end
    end
    assign tx_en = tx_en_d1;
    assign tx_data = rx_fifo_out[7:0];

    //receiver asseration
    property wenxren;
        @(posedge uclk) disable iff(rst_n == 1'b0)
        (rx_fifo_wen == 1'b1) |-> (rx_fifo_ren  !=  1'b1);
    endproperty

    wen_ren_assert: assert property (wenxren) else
                    $display("wen ren into high the same time");
    wen_ren_cover: cover property (wenxren);


endmodule
