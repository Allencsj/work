//sdram initial module


module  sdram_init( 
    //system input
     input              sclk              
    ,input              srst_n

    //init signals
    ,input              init_start
    ,output reg         init_end

    //sdram signals
    ,output reg [10:0]  init_addr
    ,output reg [31:0]  init_data
    ,output     [ 1:0]  init_ba
    ,output reg         init_cs_n
    ,output reg         init_ras_n
    ,output reg         init_cas_n
    ,output reg         init_we_n
    ,output     [ 3:0]  init_dqm
);

localparam  WAIT    =   5'b00001;    //wait 200us
localparam  NOP     =   5'b00010;    //none operation process
localparam  PRE     =   5'b00100;    //precharge
localparam  AREF    =   5'b01000;    //auto refresh
localparam  LM      =   5'b10000;    //load mode register

reg     [ 4:0]          cur_state;
reg     [ 4:0]          next_state;

reg                     flag_pre_end;
reg                     flag_aref1_end;
reg                     flag_aref2_end;
reg                     flag_lm_end;

reg     [ 1:0]          pre_cnt;
reg     [ 4:0]          aref_cnt;
reg                     aref_cnt_start;

reg     [31:0]          wait_cnt;
reg                     wait_end;

    //---------------------------------------------------------------
    //FSM for sdram init control flow
    //---------------------------------------------------------------
    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            cur_state   <=  WAIT; 
        end else if (init_start    ==  1'b1) begin
            cur_state   <=  next_state;
        end
    end

    always_comb begin
        case(cur_state)
            WAIT   :   begin
                if (wait_end    ==  1'b1) begin
                    next_state  =   NOP;
                end else begin
                    next_state  =   WAIT;
                end
            end
            NOP    :   begin
                if (init_start  ==  1'b1 && flag_pre_end != 1'b1) begin
                    next_state  =  PRE;
                end else if (flag_aref1_end ==  1'b1) begin
                    next_state  =  AREF;
                end else if (flag_aref2_end ==  1'b1) begin
                    next_state  =  LM;
                end else begin
                    next_state  =  NOP;
                end
            end
            PRE    :   begin
                if (flag_pre_end    ==  1'b1) begin
                    next_state  =  AREF;
                end else begin
                    next_state  =  PRE;
                end
            end
            AREF   :   begin
                    next_state  =  NOP;
            end
            LM     :   begin
                if (flag_lm_end ==  1'b1) begin
                    next_state  =  NOP;
                end else begin
                    next_state  =  LM;
                end
            end
            default :   next_state  =  NOP;
        endcase
    end

    //---------------------------------------------------------------
    //sdram init
    //---------------------------------------------------------------

    //wait 200us
    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            wait_cnt    <=  32'b0;
        end else if (init_start ==  1'b1) begin
            wait_cnt    <=  wait_cnt + 1'b1;
        end else begin
            wait_cnt    <=  32'b0;
        end
    end

    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            wait_end    <=  1'b0;
        end else if (wait_cnt   ==  32'd33000) begin
            wait_end    <=  1'b1;
        end else begin
            wait_end    <=  1'b0;
        end
    end

    //NOP -> PRE -> AREF -> LM
    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
           {init_cs_n,init_ras_n,init_cas_n,init_we_n}   <=  4'b1000;
        end else if (cur_state  ==  NOP) begin
           {init_cs_n,init_ras_n,init_cas_n,init_we_n}   <=  4'b0111;
        end else if (cur_state  ==  PRE) begin
           {init_cs_n,init_ras_n,init_cas_n,init_we_n}   <=  4'b0010;
        end else if (cur_state  ==  AREF) begin
           {init_cs_n,init_ras_n,init_cas_n,init_we_n}   <=  4'b0001;
        end else if (cur_state  ==  LM) begin
           {init_cs_n,init_ras_n,init_cas_n,init_we_n}   <=  4'b0000;
        end
    end

    //sdram addr
    //precharge -> load mode register
    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            init_addr   <=  11'b000_0000_0000;
        end else if (cur_state  ==  PRE) begin
            init_addr   <=  11'b100_0000_0000;
        end else if (cur_state  ==  LM) begin
            init_addr   <=  11'b100_0011_0000;
        end
    end

    //flag_pre_end
    //Trp = 15ns(3 cycles)
    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            pre_cnt <=  2'b00;
        end else if (cur_state  ==  PRE)begin
            pre_cnt <=  pre_cnt + 1'b1;
        end
    end

    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            flag_pre_end    <=  1'b0;
        end else if (pre_cnt    ==  2'd3) begin
            flag_pre_end    <=  1'b1;
        end
    end

    //auto refresh
    //Trfc = 60ns(12 cycles)
    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            aref_cnt_start  <=  1'b0;
        end else if (cur_state  ==  AREF) begin
            aref_cnt_start  <=  1'b1;
        end else if (flag_aref2_end  ==  1'b1) begin
            aref_cnt_start  <=  1'b0;
        end
    end

    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            aref_cnt    <=  5'b0;
        end else if (aref_cnt_start ==  1'b1) begin
            aref_cnt    <=  aref_cnt + 1'b1;
        end else if (aref_cnt_start ==  1'b0) begin
            aref_cnt    <=  5'b0;
        end
    end

    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            flag_aref1_end  <=  1'b0;
        end else if (aref_cnt   ==  5'd11) begin
            flag_aref1_end  <=  1'b1;
        end else begin
            flag_aref1_end  <=  1'b0;
        end
    end

    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            flag_aref2_end  <=  1'b0;
        end else if (aref_cnt   ==  5'd23) begin
            flag_aref2_end  <=  1'b1;
        end else begin
            flag_aref2_end  <=  1'b0;
        end
    end

    //load mode register flag end
    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            flag_lm_end    <=  1'b0;
        end else if (flag_aref2_end ==  1'b1) begin
            flag_lm_end    <=  1'b1;
        end else begin
            flag_lm_end    <=  1'b0;
        end
    end

    //init end
    always@(posedge sclk or negedge srst_n) begin
        if (srst_n  ==  1'b0) begin
            init_end    <=  1'b0;
        end else if (cur_state  ==  LM) begin
            init_end    <=  1'b1;
        end else begin
            init_end    <=  1'b0;
        end
    end


    assign  init_ba     = 'b0;
    assign  init_dqm    = 'b0;
    assign  init_data   = 'bz;

endmodule
