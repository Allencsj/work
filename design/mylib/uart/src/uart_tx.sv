//uart tx module

module uart_tx(
    input                   uclk
    ,input                  rst_n

    ,input  [ 7:0]          tx_data
    ,input                  tx_en
    
    ,output reg             txd
    ,output                 tx_done
);

//uart parameter
localparam  FRE  =   50000000;
localparam  BAUD =  115200;
localparam  BPS_CNT = FRE/BAUD;

//state parameter
localparam IDLE       =   6'b000001;
localparam START_BIT  =   6'b000010;
localparam DATA       =   6'b000100;
localparam STOP_BIT   =   6'b001000;
localparam DONE       =   6'b010000;
localparam ERR        =   6'b100000;

reg [ 5:0]          cur_state;
reg [ 5:0]          next_state;
reg [15:0]          clk_cnt;
reg [ 3:0]          data_cnt;
reg [ 7:0]          tx_data_r;

    always@(posedge uclk or negedge rst_n) begin
        if (rst_n   ==  1'b0) begin
            cur_state   <=  6'b00_0001;
        end else begin
            cur_state   <=  next_state;
        end
    end

    always_comb begin
        case(cur_state)
            IDLE    :   begin
                if (tx_en   ==  1'b1) begin
                    next_state   =   START_BIT;
                end else begin
                    next_state   =   IDLE;
                end
            end
            START_BIT   :   begin
                if (clk_cnt ==  BPS_CNT - 1) begin
                    next_state  =   DATA;
                end else begin
                    next_state  =   START_BIT;
                end
            end
            DATA    :   begin
                if (data_cnt    ==  4'd8) begin
                    next_state   =   STOP_BIT;
                end else begin
                    next_state   =   DATA;
                end
            end
            STOP_BIT    :   begin
                if (clk_cnt ==  BPS_CNT - 1) begin
                    next_state  =   DONE;
                end else begin
                    next_state  =   STOP_BIT;
                end
            end
            DONE    :   begin
                    next_state  =   IDLE;
            end
            ERR     :   begin
                    next_state  =   ERR;
            end
            default :   next_state  =   IDLE;
        endcase
    end

    //clk count
    always@(posedge uclk or negedge rst_n) begin
        if (rst_n   ==  1'b0) begin
            clk_cnt <=  16'b0;
        end else if (cur_state  ==  IDLE || clk_cnt == BPS_CNT - 1) begin
            clk_cnt <=  16'b0;
        end else begin
            clk_cnt <=  clk_cnt + 1'b1;
        end
    end

    //data count
    always@(posedge uclk or negedge rst_n) begin
        if (rst_n   ==  1'b0) begin
            data_cnt    <=  4'b0;
        end else if (cur_state  ==  DATA && clk_cnt ==  BPS_CNT - 1) begin
            data_cnt    <=  data_cnt + 1'b1;
        end else if (data_cnt == 4'd8) begin
            data_cnt    <=  4'b0;
        end
    end

    //txd transmit, tx_data buffer
    //tx_en should be hole on one cycle
    always@(posedge uclk) begin
        if (tx_en   ==  1'b1) begin
            tx_data_r   <=  tx_data;
        end else if (cur_state  ==  DATA && clk_cnt ==  BPS_CNT - 1) begin
            tx_data_r   <=  tx_data_r >> 1;
        end
    end

    always_comb begin
        case(cur_state)
            START_BIT   :   txd = 1'b0;
            DATA        :   txd = tx_data_r[0];
            STOP_BIT    :   txd = 1'b1;
            default     :   txd = 1'b1;
        endcase
    end

    //tx_done
    assign tx_done  =   cur_state   == DONE;

    //asseration
    property txen;
        @(posedge uclk) disable iff (rst_n != 1)
        $rose(tx_en) |=> $fell(tx_en);
    endproperty
    tx_en_assert : assert property (txen) else
                    $display("tx_en last not a cycle!!");
    tx_en_cov   :   cover property (txen);

    property txdone;
        @(posedge uclk) disable iff (rst_n != 1)
        $rose(tx_done) |=> $fell(tx_done);
    endproperty
    tx_done_assert : assert property (txdone) else
                    $display("tx_done last not a cycle!!");
    tx_done_cov   :   cover property (txdone);

endmodule
