//uart module
//BAUD:115200  Main clk:50MHz

module uart_rx(
     input                      uclk
    ,input                      rst_n
    ,input                      rxd

    ,output [7:0]               rx_data
    ,output                     rx_done
    ,output                     rx_err
);

//define receive parameter
localparam  FRE  = 50000000;
localparam  BAUD = 115200;
localparam  BPS_CNT = FRE/BAUD;

//define FSM state
localparam  IDLE        =   6'b00_0001;
localparam  START_BIT   =   6'b00_0010;
localparam  DATA        =   6'b00_0100;
localparam  STOP_BIT    =   6'b00_1000;
localparam  DONE        =   6'b01_0000;
localparam  ERR         =   6'b10_0000;

reg [ 5:0]              cur_state;
reg [ 5:0]              next_state;

reg [ 3:0]              data_cnt;
reg [ 7:0]              rx_data_r;

reg                     rxd_d0;
reg                     rxd_d1;
reg                     rxd_d2;

reg [15:0]              clk_cnt;
reg                     clk_cnt_start;
wire                    rx_start;

reg                     stop_bit_r;

    //---------------------------------------------
    //Main code
    //---------------------------------------------

    //two DFF to avord unsatble state
    always@(posedge uclk or negedge rst_n) begin
        if (rst_n   ==  1'b0) begin
            rxd_d0  <=  1'b0;
            rxd_d1  <=  1'b0;
            rxd_d2  <=  1'b0;
        end else begin
            rxd_d0  <=  rxd;
            rxd_d1  <=  rxd_d0;
            rxd_d2  <=  rxd_d1;
        end
    end


    //FSM
    always@(posedge uclk or negedge rst_n) begin
        if (rst_n   ==  1'b0) begin
            cur_state  <=  IDLE;
        end else begin
            cur_state   <=  next_state;
        end
    end

    always_comb begin
        case(cur_state)
            IDLE        :   begin
                if (rx_start    ==  1'b1) begin
                    next_state  =   START_BIT;
                end else begin
                    next_state  =   IDLE;
                end
            end
            START_BIT   :   begin
                if (clk_cnt ==  BPS_CNT - 1) begin
                    next_state  =   DATA;
                end else begin
                    next_state  =   START_BIT;
                end
            end
            DATA        :   begin
                if (data_cnt    ==  4'd8) begin
                    next_state  =   STOP_BIT;
                end else begin
                    next_state  =   DATA;
                end
            end
            STOP_BIT    :   begin
                if (clk_cnt ==  BPS_CNT - 1) begin
                    if (rxd_d2   ==  1'b1) begin
                        next_state  =   DONE;
                    end else begin
                        next_state  =   ERR;
                    end
                end else begin
                    next_state  =   STOP_BIT;
                end
            end
            DONE        :   begin
                    next_state  =   IDLE;
            end
            ERR         :   begin
                    next_state  =   ERR;
            end
            default     :   next_state  =   START_BIT;
        endcase
    end

    //rise edge detect
    assign rx_start = (cur_state == IDLE ) ? (!rxd_d1 & rxd_d2) : 1'b0;
//    always@(posedge uclk or negedge rst_n) begin
//        if (rst_n   ==  1'b0) begin
//        end else begin
//        end
//    end

    //clk generate
    always@(posedge uclk or negedge rst_n) begin
        if (rst_n   ==  1'b0) begin
            clk_cnt <=  16'b0;
        end else if (cur_state  ==  IDLE || clk_cnt == BPS_CNT - 1) begin
            clk_cnt <=  16'b0;
        end else begin
            clk_cnt <=  clk_cnt + 1'b1;
        end
    end

    //data count 9bits the 9th bit is used to judge some state
    always@(posedge uclk or negedge rst_n) begin
        if (rst_n   ==  1'b0) begin
            data_cnt    <=  4'b0;
        end else if (cur_state  ==  DATA) begin
            if (clk_cnt == BPS_CNT - 1) begin
                data_cnt    <=  data_cnt + 1'b1;
            end else begin
                data_cnt    <=  data_cnt;
            end
        end else begin
            data_cnt    <=  4'b0;
        end
    end

    //rx_data
    always@(posedge uclk or negedge rst_n) begin
        if (rst_n   ==  1'b0) begin
            rx_data_r   <=  8'b0;
        end else if (cur_state  ==  DATA && clk_cnt ==  BPS_CNT/2) begin
            rx_data_r   <=  {rxd_d2,rx_data_r[7:1]};
        end else begin
            rx_data_r   <=  rx_data_r;
        end
    end

    //stop_bit_r
    always@(posedge uclk or negedge rst_n) begin
        if (rst_n   ==  1'b0) begin
            stop_bit_r  <=  1'b0;
        end else if (cur_state  ==  STOP_BIT) begin
            if (clk_cnt ==  BPS_CNT/2) begin
                stop_bit_r  <=  rxd_d2;
            end else begin
                stop_bit_r  <=  stop_bit_r;
            end
        end else begin
            stop_bit_r  <=  1'b0;
        end
    end

    reg     stop_bit_rr;
    always@(posedge uclk or negedge rst_n) begin
        if (rst_n   ==  1'b0) begin
            stop_bit_rr <=  1'b0;
        end else begin
            stop_bit_rr <=  stop_bit_r;
        end
    end

    //rx_done
    assign rx_done  =   (cur_state == STOP_BIT && stop_bit_r   ==  1'b1 && stop_bit_rr == 1'b0) ? 1'b1 : 1'b0;

    assign rx_data  =   rx_done ? rx_data_r : 8'b0;

    assign rx_err   =   cur_state   ==  ERR;

    //assertaion


endmodule
