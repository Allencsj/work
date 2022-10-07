//sdram arbiter for write, read, auto refresh

module sdram_arb(
    //sys signals
     input                  sclk
    ,input                  srst_n

    //request & enable signals
    ,input                  init_end
    ,input                  wr_req
    ,input                  rd_req
    ,input                  aref_req
    ,input                  wr_done
    ,input                  rd_done
    ,input                  aref_done

//    ,output reg             wr_en
//    ,output reg             rd_en
//    ,output reg             aref_en
    ,output                 wr_ack
    ,output                 rd_ack
    ,output                 aref_ack
);

localparam  IDLE    =   4'b0001;    //idle mode when power up
localparam  WRITE   =   4'b0010;    //write operation
localparam  READ    =   4'b0100;    //read operation    
localparam  AREF    =   4'b1000;    //auto refresh
//locakparam  ERR     =   5'b1_0000;  //error si

reg     [ 3:0]          cur_state;
reg     [ 3:0]          next_state;

reg                     aref_op;
reg                     wr_op;
reg                     rd_op;
reg                     last_op; 

//arb start
reg                     arb_start;

reg                     wr_ack_r;
reg                     wr_ack_rr;
reg                     wr_ack_rrr;
reg                     rd_ack_r;
reg                     rd_ack_rr;
reg                     rd_ack_rrr;
reg                     aref_ack_r;
reg                     aref_ack_rr;
reg                     aref_ack_rrr;

//===================================================================
//Main code
//===================================================================

    always_comb begin
        casez({wr_req,rd_req,aref_req})
            3'b??1  :   begin
                        aref_op =   1'b1;
                        wr_op   =   1'b0;
                        rd_op   =   1'b0;
            end
            3'b100  :   begin
                        aref_op =   1'b0;
                        wr_op   =   1'b1;
                        rd_op   =   1'b0;
            end
            3'b010  :   begin
                        aref_op =   1'b0;
                        wr_op   =   1'b0;
                        rd_op   =   1'b1;
            end
            default :   begin
                        aref_op =   1'b0;
                        wr_op   =   1'b0;
                        rd_op   =   1'b0;
            end
        endcase
    end

    //---------------------------------------------------------------
    //FSM for sdram main control flow
    //---------------------------------------------------------------
    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            arb_start   <=  1'b0;
        end else if (init_end   ==  1'b1) begin
            arb_start   <=  1'b1;
        end
    end
    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            cur_state   <=  IDLE; 
        end else if (arb_start  ==  1'b1) begin
            cur_state   <=  next_state;
        end
    end

    always_comb begin
        case(cur_state)
            IDLE   :   begin
                if (wr_op   ==  1'b1)
                    next_state  =   WRITE;
                else if (rd_op  ==  1'b1)
                    next_state  =   READ;
                else if (aref_op    ==  1'b1)
                    next_state  =   AREF;
                else
                    next_state  =   IDLE;
            end
            WRITE  :    begin
                if (wr_done ==  1'b1) begin
                    next_state  =   IDLE;
                end else begin
                    next_state  =   WRITE;
                end
            end
            READ   :    begin
                if (rd_done ==  1'b1) begin
                    next_state  =   IDLE;
                end else begin
                    next_state  =   READ;
                end
            end
            AREF   :    begin
                if (last_op ==  1'b1    &&  aref_done   ==  1'b1)
                    next_state  =   WRITE;
                else if (last_op    ==  1'b0    &&  aref_done   ==  1'b1)
                    next_state  =   READ;
                else
                    next_state  =   AREF;
            end
            default :   next_state  =  IDLE;
        endcase
    end

    //last_op value for auto refresh
    //last_op   operation
    //  1           write
    //  0           read
    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            last_op <=  1'b0;
        end else if (cur_state  ==  WRITE) begin
            last_op <=  1'b1;
        end else if (cur_state  ==  READ) begin
            last_op <=  1'b0;
        end
    end

    //write operation start
    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            wr_ack_r  <=  1'b0;
        end else if (cur_state  ==  WRITE) begin
            wr_ack_r  <=  1'b1;
        end else begin
            wr_ack_r  <=  1'b0;
        end
    end

    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            wr_ack_rr  <=  1'b0;
            wr_ack_rrr  <=  1'b0;
        end else begin
            wr_ack_rr  <=  wr_ack_r;
            wr_ack_rrr  <=  wr_ack_rr;
        end
    end

    assign wr_ack = wr_ack_r && !wr_ack_rrr;

//    always@(posedge sclk or negedge srst_n) begin
//        if (srst_n  ==  1'b1) begin
//            wr_en  <=  1'b0;
//        end else if (cur_state  ==  WRITE) begin
//            wr_en  <=  1'b1;
//        end else begin
//            wr_en  <=  1'b0;
//        end
//    end

    //read operation start
    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            rd_ack_r  <=  1'b0;
        end else if (cur_state  ==  READ) begin
            rd_ack_r  <=  1'b1;
        end else begin
            rd_ack_r  <=  1'b0;
        end
    end

    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            rd_ack_rr  <=  1'b0;
            rd_ack_rrr  <=  1'b0;
        end else begin
            rd_ack_rr  <=  rd_ack_r;
            rd_ack_rrr  <=  rd_ack_rr;
        end
    end

    assign rd_ack = rd_ack_r && !rd_ack_rrr;

//    always@(posedge sclk or negedge srst_n) begin
//        if (srst_n  ==  1'b1) begin
//            rd_en  <=  1'b0;
//        end else if (cur_state  ==  READ) begin
//            rd_en  <=  1'b1;
//        end else begin
//            rd_en  <=  1'b0;
//        end
//    end

    //write operation start
    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            aref_ack_r  <=  1'b0;
        end else if (cur_state  ==  AREF) begin
            aref_ack_r  <=  1'b1;
        end else begin
            aref_ack_r  <=  1'b0;
        end
    end

    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            aref_ack_rr  <=  1'b0;
            aref_ack_rrr  <=  1'b0;
        end else begin
            aref_ack_rr  <=  rd_ack_r;
            aref_ack_rrr  <=  rd_ack_rr;
        end
    end

    assign aref_ack = aref_ack_r && !aref_ack_rrr;



//    always@(posedge sclk or negedge srst_n) begin
//        if (srst_n  ==  1'b1) begin
//            aref_en  <=  1'b0;
//        end else if (cur_state  ==  AREF) begin
//            aref_en  <=  1'b1;
//        end else begin
//            aref_en  <=  1'b0;
//        end
//    end


    //asseration

endmodule
