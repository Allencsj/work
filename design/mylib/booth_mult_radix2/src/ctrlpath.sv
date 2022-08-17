module Mcontroller_booth
    #(parameter L_word  = 4,
      parameter L_state = 4,
      parameter L_BRC   = 2)
    (
      input          clk
     ,input          rst_n
     ,input          i_start
     ,input          i_m0
     ,output  reg    Load_words
     ,output  reg    Shift
     ,output  reg    Add
     ,output  reg    Sub
     ,output         Ready
     ,output  reg    err
    );

    reg     [L_state-1 : 0]    state,next_state;
    reg                        m0_del;

    wire    [L_BRC-1   : 0]    BRC   = {i_m0,m0_del};

    enum logic [8:0]   {  S_idle = 0
                        , S_1    = 1
                        , S_2    = 2
                        , S_3    = 3
                        , S_4    = 4
                        , S_5    = 5
                        , S_6    = 6
                        , S_7    = 7
                        , S_8    = 8}state_r;

    always_ff @ (posedge clk) begin
        if (!rst_n) begin
            m0_del <= 1'b0;
        end else if (Load_words == 1'b1) begin
            m0_del <= 0;
        end else begin
            m0_del <= i_m0;
        end
    end

    always_ff @ (posedge clk) begin
        if (!rst_n)
            state <= S_idle;
        else begin
            state <= next_state;
        end
    end

    always_comb begin
        Add        = 0;
        Sub        = 0;
        Shift      = 0;
        Load_words = 0;
        case(state)
            S_idle : 
                    if (i_start) begin
                        Load_words = 1;
                        next_state = S_1;
                    end
            S_1:
                    if ((BRC == 2'b00) || (BRC == 2'b11)) begin
                        Shift = 1;
                        next_state = S_3;
                    end else if (BRC == 2'b01) begin
                        Add = 1;
                        next_state = S_2;
                    end else if (BRC == 2'b10) begin
                        Sub = 1;
                        next_state = S_2;
                    end else begin
                        err = 1;
                    end
            S_2:    begin
                        Shift = 1;
                        next_state = S_3;
                    end
            S_3:
                    if ((BRC == 2'b00) || (BRC == 2'b11)) begin
                        Shift = 1;
                        next_state = S_5;
                    end else if (BRC == 2'b01) begin
                        Add = 1;
                        next_state = S_4;
                    end else if (BRC == 2'b10) begin
                        Sub = 1;
                        next_state = S_4;
                    end else begin
                        err = 1;
                    end
            S_4:    begin
                        Shift = 1;
                        next_state = S_5;
                    end
            S_5:
                    if ((BRC == 2'b00) || (BRC == 2'b11)) begin
                        Shift = 1;
                        next_state = S_7;
                    end else if (BRC == 2'b01) begin
                        Add = 1;
                        next_state = S_6;
                    end else if (BRC == 2'b10) begin
                        Sub = 1;
                        next_state = S_6;
                    end else begin
                        err = 1;
                    end
            S_6:    begin
                        Shift = 1;
                        next_state = S_7;
                    end
            S_7:
                    if ((BRC == 2'b00) || (BRC == 2'b11)) begin
                        Shift = 1;
                        next_state = S_8;
                    end else if (BRC == 2'b01) begin
                        Add = 1;
                        next_state = S_8;
                    end else if (BRC == 2'b10) begin
                        Sub = 1;
                        next_state = S_8;
                    end else begin
                        err = 1;
                    end
            S_8:    if (i_start) begin
                        Load_words = 1;
                        next_state = S_1;
                    end else begin
                        next_state = S_idle;
                    end
            default : 
                    next_state = S_idle;
        endcase
    end

    assign                     Ready = (state == S_8);



endmodule
