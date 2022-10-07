//auto refresh module

module sdram_aref (
    //system signal
     input              sclk
    ,input              srst_n

    //aref signals
    ,input              init_end
    ,output reg         aref_req
    ,input              aref_en
    ,input              aref_ack
    ,output reg         aref_done

    //sdram signals
    ,output     [10:0]  aref_addr
    ,output     [31:0]  aref_data
    ,output             aref_oe_n
    ,output     [ 1:0]  aref_ba
    ,output reg         aref_cs_n
    ,output reg         aref_ras_n
    ,output reg         aref_cas_n
    ,output reg         aref_we_n
    ,output     [ 3:0]  aref_dqm


    );

localparam  IDLE    =   5'b00001;
localparam  NOP     =   5'b00010;    //none operation process
localparam  PRE     =   5'b00100;    //precharge
localparam  AREF    =   5'b01000;    //auto refresh
localparam  NOP2    =   5'b10000;

reg     [ 4:0]          cur_state;
reg     [ 4:0]          next_state;

reg     [ 1:0]          nop_cnt;
reg     [10:0]          aref_cnt;
reg     [ 3:0]          aref_end_cnt;
reg                     aref_start;

    //---------------------------------------------------------------
    //FSM for sdram aref control flow
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
                if (aref_en ==  1'b1) begin
                    next_state  =  PRE;
                end else begin
                    next_state  =  IDLE;
                end
            end
            NOP    :   begin
                if (nop_cnt >=  2'd1 && aref_en ==  1'b1) begin
                    next_state  =   AREF;
                end else begin
                    next_state  =   NOP;
                end
            end
            PRE    :   begin
                    next_state  =   NOP;
            end
            AREF   :   begin
                    next_state  =   NOP2;
            end
            NOP2   :    begin
                if (aref_end_cnt    ==  4'd10) begin
                    next_state  =   IDLE;
                end else begin
                    next_state  =   NOP2;
                end
            end
            default :   next_state  =  IDLE;
        endcase
    end

    //aref_start
    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            aref_start  <=  1'b0;
        end else if (init_end   ==  1'b1) begin
            aref_start  <=  1'b1;
        end
    end

    //nop count
    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            nop_cnt    <=  2'd0;
        end else if (cur_state  ==  NOP) begin
            nop_cnt    <=  nop_cnt  +   1'b1;
        end else begin
            nop_cnt    <= 2'd0;
        end
    end

    //aref count
    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            aref_cnt    <=  11'b000_0000_0000;
        end else if (cur_state  ==  11'd2047) begin
            aref_cnt    <=  11'd0;
        end else if (aref_start   ==  1'b1) begin
            aref_cnt    <=  aref_cnt + 1'b1;
        end
    end

    //aref end count
    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            aref_end_cnt    <=  4'b0000;
        end else if (cur_state  ==  NOP2) begin
            aref_end_cnt    <=  aref_end_cnt + 1'b1;
        end else begin
            aref_end_cnt    <=  4'b0000;
        end
    end

    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
           {aref_cs_n,aref_ras_n,aref_cas_n,aref_we_n}   <=  4'b1000;
        end else if (cur_state  ==  NOP) begin
           {aref_cs_n,aref_ras_n,aref_cas_n,aref_we_n}   <=  4'b0111;
        end else if (cur_state  ==  NOP2) begin
           {aref_cs_n,aref_ras_n,aref_cas_n,aref_we_n}   <=  4'b0111;
        end else if (cur_state  ==  PRE) begin
           {aref_cs_n,aref_ras_n,aref_cas_n,aref_we_n}   <=  4'b0010;
        end else if (cur_state  ==  AREF) begin
           {aref_cs_n,aref_ras_n,aref_cas_n,aref_we_n}   <=  4'b0001;
       end
    end

    //aref request
    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            aref_req    <=  1'b0;
        end else if (aref_cnt   ==  11'd2047) begin
            aref_req    <=  1'b1;
        end else if (aref_ack   ==  1'b1 && cur_state   ==  AREF) begin
            aref_req    <=  1'b0;
        end
    end

    //aref done
    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            aref_done    <=  1'b0;
        end else if (aref_end_cnt   ==  4'd10) begin
            aref_done    <=  1'b1;
        end else begin
            aref_done    <=  1'b0;
        end
    end

    //ouput sdram sinals
    assign  aref_addr = 11'b100_0000_0000;
    assign  aref_data = 32'b0;
    assign  aref_oe_n = 1'b1;
    assign  aref_ba   = 2'b00;
    assign  aref_dqm  = 4'b0;


endmodule
