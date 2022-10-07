//sdram write module


module  sdram_write(
    //sys signals
     input                  sclk
    ,input                  srst_n

    //wr enable signals
    ,input                  wr_en
    ,output reg             wr_done

    //wr command signals
    ,input      [31:0]      i_wr_data

    ,output     [10:0]      o_wr_addr
    ,output     [31:0]      o_wr_data
    ,output                 o_wr_oe_n
    ,output     [ 1:0]      o_wr_ba
    ,output     [ 3:0]      o_wr_dqm
    ,output                 o_wr_cs_n
    ,output                 o_wr_ras_n
    ,output                 o_wr_cas_n
    ,output                 o_wr_we_n
);

localparam  IDLE    =   5'b00001;
localparam  ACTIVE  =   5'b00010;
localparam  NOP     =   5'b00100;
localparam  WRITE   =   5'b01000;
localparam  NOP2    =   5'b10000;

reg     [ 4:0]          cur_state;
reg     [ 4:0]          next_state;

reg                     wr_cs_n;
reg                     wr_ras_n;
reg                     wr_cas_n;
reg                     wr_we_n;
reg     [ 1:0]          wr_ba;
reg     [ 7:0]          wr_col_addr;
wire                    wr_col_end;
reg                     wr_col_end_r;
wire                    wr_col_end_edge;
reg     [10:0]          wr_row_addr;
wire                    wr_row_end;
reg                     wr_row_end_r;
wire                    wr_row_end_edge;

reg     [10:0]          wr_addr;
reg     [31:0]          wr_data;
reg                     wr_oe_n;

reg     [ 1:0]          trcd_cnt;
reg     [ 3:0]          trc_cnt;

reg                     wr_done_r;

reg                     trcd_cnt_start;
reg                     trc_cnt_start;


    //---------------------------------------------------------------
    //FSM for sdram write control flow
    //---------------------------------------------------------------
    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            cur_state   <=  IDLE; 
        end else begin
            cur_state   <=  next_state;
        end
    end

    always_comb begin
        case(cur_state)
            IDLE   :   begin
                if (wr_en   ==  1'b1)
                    next_state  =   ACTIVE;
                else
                    next_state  =   IDLE;
            end
            ACTIVE :   begin
                    next_state  =   NOP;
            end
            NOP    :   begin
                if (trcd_cnt    ==  2'd3) begin
                    next_state  =   WRITE;
                end else begin
                    next_state  =   NOP;
                end
            end
            WRITE  :   begin
                    next_state  =   NOP2;
            end
            NOP2   :   begin
                if (wr_done_r ==  1'b1) begin
                    next_state  =   IDLE;
                end else begin
                    next_state  =   NOP2;
                end
            end
            default :   next_state  =  IDLE;
        endcase
    end

    //cnt start
    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            trcd_cnt_start   <=  1'b0;
        end else if (cur_state  ==  ACTIVE) begin
            trcd_cnt_start   <=  1'b1;
        end else if (trcd_cnt   ==  2'd3) begin
            trcd_cnt_start   <=1'b0;
        end
    end

    //cnt start
    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            trc_cnt_start   <=  1'b0;
        end else if (cur_state  ==  ACTIVE) begin
            trc_cnt_start   <=  1'b1;
        end else if (trc_cnt  == 4'd10) begin
            trc_cnt_start   <=1'b0;
        end
    end

    //tRCD delay(ACTIVE -> WRITE)
    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            trcd_cnt <= 2'b00;
        end else if (trcd_cnt_start  ==  1'b1) begin
            trcd_cnt <= trcd_cnt + 1'b1;
        end else if (wr_done    ==  1'b1) begin
            trcd_cnt <= 2'd0;
        end
    end

    //tRC delay(WRITE -> next ACTIVE)
    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            trc_cnt <= 4'b00;
        end else if (trc_cnt_start  ==  1'b1) begin
            trc_cnt <= trc_cnt + 1'b1;
        end else if (wr_done    ==  1'b1) begin
            trc_cnt <= 4'd0;
        end
    end

    //wr_done
    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            wr_done_r <= 1'b0;
        end else if (trc_cnt    ==  4'd10) begin
            wr_done_r <=  1'b1;
        end else begin
            wr_done_r <=  1'b0;
        end
    end

    //command
    always_comb begin
        case(cur_state)
            ACTIVE  :   {wr_cs_n,wr_ras_n,wr_cas_n,wr_we_n}   <=  4'b0011;
            NOP     :   {wr_cs_n,wr_ras_n,wr_cas_n,wr_we_n}   <=  4'b0111;
            WRITE   :   {wr_cs_n,wr_ras_n,wr_cas_n,wr_we_n}   <=  4'b0100;
            NOP2    :   {wr_cs_n,wr_ras_n,wr_cas_n,wr_we_n}   <=  4'b0111;
            default :   {wr_cs_n,wr_ras_n,wr_cas_n,wr_we_n}   <=  4'b1000;
        endcase
    end
    
    //cloumn address
    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            wr_col_addr <=  8'b000_0000;
        end else if (cur_state  ==  WRITE) begin
            wr_col_addr <= wr_col_addr + 1'b1;
        end
    end

    assign wr_col_end = (wr_col_addr == 8'd255) ? 1'b1 : 1'b0;

    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            wr_col_end_r    <=  1'b0;
        end else if (wr_col_end ==  1'b1) begin
            wr_col_end_r    <=  1'b1;
        end else begin
            wr_col_end_r    <=  1'b0;
        end
    end

    assign wr_col_end_edge = wr_col_end && !wr_col_end_r;
    
    //row address
    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            wr_row_addr <=  11'b000_0000_0000;
        end else if (wr_col_end_edge    ==  1'b1) begin
            wr_row_addr <= wr_row_addr + 1'b1;
        end
    end

    assign wr_row_end = (wr_row_addr == 11'd2047) ? 1'b1 : 1'b0;

    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            wr_row_end_r    <=  1'b0;
        end else if (wr_row_end ==  1'b1) begin
            wr_row_end_r    <=  1'b1;
        end else begin
            wr_row_end_r    <=  1'b0;
        end
    end

    assign wr_row_end_edge = wr_row_end && !wr_row_end_r;
    
    //Bank
    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            wr_ba <=  2'b00;
        end else if (wr_row_end_edge ==  1'b1) begin
            wr_ba <= wr_ba + 1'b1;
        end
    end

    //addr configure
    always_comb begin
        case(cur_state)
            ACTIVE  :   begin
                wr_addr =   wr_row_addr;
            end
            WRITE   :   begin
                wr_addr =   {4'b100,wr_col_addr};
            end
            default :   begin
                wr_addr =   11'b100_0000_0000;
            end
        endcase
    end

    //data configure
    assign wr_data = (cur_state ==  WRITE) ? i_wr_data : 32'b0;
    assign wr_oe_n = (cur_state ==  WRITE) ? 1'b0      : 1'b1;

    //output
    assign o_wr_addr = wr_addr;
    assign o_wr_data = wr_data;
    assign o_wr_oe_n = wr_oe_n;
    assign o_wr_ba   = wr_ba;
    assign o_wr_dqm  = 4'b0;
    assign o_wr_cs_n = wr_cs_n;
    assign o_wr_ras_n= wr_ras_n;
    assign o_wr_cas_n= wr_cas_n;
    assign o_wr_we_n = wr_we_n;
    assign wr_done   = wr_done_r;



endmodule
