//sdram rdite module


module  sdram_read(
    //sys signals
     input                  sclk
    ,input                  srst_n

    //rd enable signals
    ,input                  rd_en
    ,output reg             rd_done

    //rd command signals
    ,output     [10:0]      o_rd_addr
//    ,output     [31:0]      o_rd_data
    ,output                 o_rd_oe_n
    ,output     [ 1:0]      o_rd_ba
    ,output     [ 3:0]      o_rd_dqm
    ,output                 o_rd_cs_n
    ,output                 o_rd_ras_n
    ,output                 o_rd_cas_n
    ,output                 o_rd_we_n
);

localparam  IDLE    =   5'b00001;
localparam  ACTIVE  =   5'b00010;
localparam  NOP     =   5'b00100;
localparam  READ    =   5'b01000;
localparam  NOP2    =   5'b10000;

reg     [ 4:0]          cur_state;
reg     [ 4:0]          next_state;

reg                     rd_cs_n;
reg                     rd_ras_n;
reg                     rd_cas_n;
reg                     rd_we_n;
reg     [ 1:0]          rd_ba;
reg     [ 7:0]          rd_col_addr;
wire                    rd_col_end;
reg                     rd_col_end_r;
wire                    rd_col_end_edge;
reg     [10:0]          rd_row_addr;
wire                    rd_row_end;
reg                     rd_row_end_r;
wire                    rd_row_end_edge;

reg     [10:0]          rd_addr;
reg                     rd_oe_n;

reg     [ 1:0]          trcd_cnt;
reg     [ 3:0]          trc_cnt;

reg                     rd_done_r;

reg                     trcd_cnt_start;
reg                     trc_cnt_start;


    //---------------------------------------------------------------
    //FSM for sdram read control flow
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
                if (rd_en   ==  1'b1)
                    next_state  =   ACTIVE;
                else
                    next_state  =   IDLE;
            end
            ACTIVE :   begin
                    next_state  =   NOP;
            end
            NOP    :   begin
                if (trcd_cnt    ==  2'd3) begin
                    next_state  =   READ;
                end else begin
                    next_state  =   NOP;
                end
            end
            READ   :   begin
                    next_state  =   NOP2;
            end
            NOP2   :   begin
                if (rd_done_r ==  1'b1) begin
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

    //tRCD delay(ACTIVE -> READ)
    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            trcd_cnt <= 2'b00;
        end else if (trcd_cnt_start  ==  1'b1) begin
            trcd_cnt <= trcd_cnt + 1'b1;
        end else if (rd_done    ==  1'b1) begin
            trcd_cnt <= 2'd0;
        end
    end

    //tRC delay(READ -> next ACTIVE)
    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            trc_cnt <= 4'b00;
        end else if (trc_cnt_start  ==  1'b1) begin
            trc_cnt <= trc_cnt + 1'b1;
        end else if (rd_done    ==  1'b1) begin
            trc_cnt <= 4'd0;
        end
    end

    //rd_done
    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            rd_done_r <= 1'b0;
        end else if (trc_cnt    ==  4'd10) begin
            rd_done_r <=  1'b1;
        end else begin
            rd_done_r <=  1'b0;
        end
    end

    //command
    always_comb begin
        case(cur_state)
            ACTIVE  :   {rd_cs_n,rd_ras_n,rd_cas_n,rd_we_n}   =  4'b0011;
            NOP     :   {rd_cs_n,rd_ras_n,rd_cas_n,rd_we_n}   =  4'b0111;
            READ    :   {rd_cs_n,rd_ras_n,rd_cas_n,rd_we_n}   =  4'b0101;
            NOP2    :   {rd_cs_n,rd_ras_n,rd_cas_n,rd_we_n}   =  4'b0111;
            default :   {rd_cs_n,rd_ras_n,rd_cas_n,rd_we_n}   =  4'b1000;
        endcase
    end
    
    //cloumn address
    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            rd_col_addr <=  8'b000_0000;
        end else if (cur_state  ==  READ) begin
            rd_col_addr <= rd_col_addr + 1'b1;
        end
    end

    assign rd_col_end = (rd_col_addr == 8'd255) ? 1'b1 : 1'b0;

    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            rd_col_end_r    <=  1'b0;
        end else if (rd_col_end ==  1'b1) begin
            rd_col_end_r    <=  1'b1;
        end else begin
            rd_col_end_r    <=  1'b0;
        end
    end

    assign rd_col_end_edge = rd_col_end && !rd_col_end_r;
    
    //row address
    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            rd_row_addr <=  11'b000_0000_0000;
        end else if (rd_col_end_edge    ==  1'b1) begin
            rd_row_addr <= rd_row_addr + 1'b1;
        end
    end

    assign rd_row_end = (rd_row_addr == 11'd2047) ? 1'b1 : 1'b0;

    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            rd_row_end_r    <=  1'b0;
        end else if (rd_row_end ==  1'b1) begin
            rd_row_end_r    <=  1'b1;
        end else begin
            rd_row_end_r    <=  1'b0;
        end
    end

    assign rd_row_end_edge = rd_row_end && !rd_row_end_r;
    
    //Bank
    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            rd_ba <=  2'b00;
        end else if (rd_row_end_edge ==  1'b1) begin
            rd_ba <= rd_ba + 1'b1;
        end
    end

    //addr configure
    always_comb begin
        case(cur_state)
            ACTIVE  :   begin
                rd_addr =   rd_row_addr;
            end
            READ    :   begin
                rd_addr =   {4'b100,rd_col_addr};
            end
            default :   begin
                rd_addr =   11'b100_0000_0000;
            end
        endcase
    end

    //data configure
//    assign rd_data = (cur_state ==  READ) ? i_rd_data : 32'b0;
    assign rd_oe_n = (cur_state ==  READ) ? 1'b0      : 1'b1;

    //output
    assign o_rd_addr = rd_addr;
//    assign o_rd_data = rd_data;
    assign o_rd_oe_n = rd_oe_n;
    assign o_rd_ba   = rd_ba;
    assign o_rd_dqm  = 4'b0;
    assign o_rd_cs_n = rd_cs_n;
    assign o_rd_ras_n= rd_ras_n;
    assign o_rd_cas_n= rd_cas_n;
    assign o_rd_we_n = rd_we_n;
    assign rd_done   = rd_done_r;



endmodule
