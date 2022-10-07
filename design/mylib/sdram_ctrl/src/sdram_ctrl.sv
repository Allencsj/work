//----------------------------------------
//Description: design sdram clk 166MHz
//----------------------------------------

module sdram_ctrl (

    //system signals
     input                  sclk
    ,input                  srst_n

    //sdram ctrl signals
    ,input                  sdr_start   //sdram start to work
    ,input                  wr_req      //write request signal
    ,output reg             wr_ack      //write ackonwage signal
    ,output reg             wr_en       //write enable
    ,input                  wr_done
    
//    ,output reg             wr_start    //write start
    ,input                  rd_req      //read  request signal
    ,output reg             rd_ack      //read  acknowage signal
    ,output reg             rd_en       //read enable
    ,input                  rd_done
//    ,output reg             rd_start    //read start
    ,input                  aref_req      //aref request signal
    ,output reg             aref_ack      //aref ackonwage signal
    ,output reg             aref_en       //aref enable
    ,input                  aref_done
    
    ,output reg             init_start  //initial start
    ,input                  init_end

);


localparam  IDLE    =   7'b000_0001;    //idle mode when power up
localparam  INIT    =   7'b000_0010;    //init mode after power up
localparam  NOP     =   7'b000_0100;    //none operation process
localparam  WRITE   =   7'b000_1000;    //write operation
localparam  READ    =   7'b001_0000;    //read operation    
localparam  AREF    =   7'b010_0000;    //auto refresh
localparam  PRE     =   7'b100_0000;    //precharge

reg     [ 6:0]          cur_state;
reg     [ 6:0]          next_state;

//write wire signals
//wire                    wr_en;
//wire                    wr_ack;

//===================================================================
//Main code
//===================================================================

    //---------------------------------------------------------------
    //FSM for sdram main control flow
    //---------------------------------------------------------------
    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            cur_state   <=  IDLE; 
        end else if (sdr_start    ==  1'b1) begin
            cur_state   <=  next_state;
        end
    end

    always_comb begin
        case(cur_state)
            IDLE   :   begin
                if (sdr_start   ==  1'b1)
                    next_state  =   INIT;
                else
                    next_state  =   IDLE;

            end
            INIT   :   begin
                if (init_end    ==  1'b1) begin
                    next_state  =   NOP;
                end else begin
                    next_state  =   INIT;
                end
            end
            NOP    :   begin
                if (aref_ack    ==  1'b1) begin
                    next_state  =   AREF;
                end else if (wr_ack ==  1'b1 && rd_ack   ==  1'b0) begin
                    next_state  =   WRITE;
                end else if (rd_ack ==  1'b1    &&  wr_ack  ==  1'b0) begin
                    next_state  =   READ;
                end else begin
                    next_state  =   NOP;
                end
            end
            WRITE  :    begin
                if (aref_ack    ==  1'b1) begin
                    next_state  =   AREF;
                end else if (wr_ack ==  1'b1 && rd_ack  ==  1'b0  &&  aref_ack ==  1'b0) begin
                    next_state  =   WRITE;
                end else if (rd_ack ==  1'b1 && wr_ack  ==  1'b0  &&  aref_ack ==  1'b0) begin
                    next_state  =   READ;
                end else if (wr_done    ==  1'b1) begin
                    next_state  =   NOP;
                end else begin
                    next_state  =   WRITE;
                end
            end
            READ   :    begin
                if (aref_ack    ==  1'b1) begin
                    next_state  =   AREF;
                end else if (wr_ack ==  1'b0 && rd_ack  ==  1'b1  &&  aref_ack ==  1'b0) begin
                    next_state  =   READ;
                end else if (rd_ack ==  1'b0 && wr_ack  ==  1'b1  &&  aref_ack ==  1'b0) begin
                    next_state  =   WRITE;
                end else if (rd_done    ==  1'b1) begin
                    next_state  =   NOP;
                end else begin
                    next_state  =   READ;
                end
            end
            AREF   :    begin
                if (aref_ack    ==  1'b0) begin
                    next_state  =   NOP;
                end else begin
                    next_state  =   AREF;
                end
            end
//            `PRE    :
            default :   next_state  =  IDLE;
        endcase
    end


    //---------------------------------------------------------------
    //sdram init
    //if FSM change into INIT, jump into init module
    //---------------------------------------------------------------
    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            init_start  <=  1'b0;
        end else if (cur_state  ==  INIT) begin
            init_start  <=  1'b1;
        end else begin
            init_start  <=  1'b0;
        end
    end

    //---------------------------------------------------------------
    //write && read
    //---------------------------------------------------------------
    assign wr_en = (cur_state == WRITE) ? 1'b1 : 1'b0;
    assign rd_en = (cur_state == READ ) ? 1'b1 : 1'b0;
    assign aref_en = (cur_state == AREF ) ? 1'b1 : 1'b0;

    //--------------------------------------
    //sdram arb module
    //--------------------------------------
    sdram_arb u_sdram_arb(
                            //sys signals
                            .sclk           (sclk       )
                            ,.srst_n         (srst_n     )

                            //request & enable signals
                            ,.init_end       (init_end   )
                            ,.wr_req         (wr_req     )
                            ,.rd_req         (rd_req     )
                            ,.aref_req       (aref_req   )
                            ,.wr_done        (wr_done    )
                            ,.rd_done        (rd_done    )
                            ,.aref_done      (aref_done  )

//                            .wr_en          (wr_en      )
//                            .rd_en          (           )
//                            .aref_en        (           )
                            ,.wr_ack         (wr_ack     )
                            ,.rd_ack         (rd_ack     )
                            ,.aref_ack       (aref_ack   )

    );



endmodule
