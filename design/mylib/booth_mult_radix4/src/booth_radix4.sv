module Mbooth_radix4 #(
    parameter  WIDTH_M = 8,
    parameter  WIDTH_R = 8
    )(
     input                           clk            //clk
    ,input                           rstn           //reset low active
    ,input                           vld_in         //input data valid
    ,input     [WIDTH_M-1:0]         multiplicand   //a quantity which is to be multiplied by another(the multiplier)
    ,input     [WIDTH_R-1:0]         multiplier     //a person or thing that multiplies
    ,output    [WIDTH_M+WIDTH_R-1:0] mul_out        //output result
    ,output    reg                   done           //flag of multi done
    );

    enum logic [1:0] { IDLE    = 2'b00
                      ,ADD     = 2'b01
                      ,SHIFT   = 2'b11
                      ,OUTPUT  = 2'b10
                     }state;

    reg        [1:0]                 current_state, next_state; 

    reg        [WIDTH_M+WIDTH_R+2:0] add1;
    reg        [WIDTH_M+WIDTH_R+2:0] sub1;
    reg        [WIDTH_M+WIDTH_R+2:0] add_x2;
    reg        [WIDTH_M+WIDTH_R+2:0] sub_x2;
    reg        [WIDTH_M+WIDTH_R+2:0] p_dct;
    reg        [WIDTH_R-1        :0] count;

    
    always_ff@ (posedge clk or negedge rstn) begin
        if (!rstn) begin
            current_state <= IDLE;
        end else if (!vld_in) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    always_comb begin
        next_state = 2'bx;
        case (current_state)
            IDLE   : if(vld_in)
                         next_state = ADD;
                     else
                         next_state = IDLE;
            ADD    : next_state = SHIFT;
            SHIFT  : if (count == WIDTH_R/2)
                         next_state = OUTPUT;
                     else
                         next_state = ADD;
            OUTPUT : next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    always_ff@(posedge clk or negedge rstn) begin
        if (!rstn) begin
            {add1,sub1,add_x2,sub_x2,p_dct,count,done} <= 0;
        end else begin
            case (current_state)
                IDLE   : begin
                    add1     <= {{2{multiplicand[WIDTH_R-1]}},multiplicand,{WIDTH_R+1{1'b0}}};
                    sub1     <= {-{{2{multiplicand[WIDTH_R-1]}},multiplicand},{WIDTH_R+1{1'b0}}};
                    add_x2   <= {{multiplicand[WIDTH_R-1],multiplicand,1'b0},{WIDTH_R+1{1'b0}}};
                    sub_x2   <= {-{multiplicand[WIDTH_R-1],multiplicand,1'b0},{WIDTH_R+1{1'b0}}};
                    p_dct    <= {{WIDTH_M+1{1'b0}},multiplier,1'b0};
                    count    <= 0;
                    done     <= 0;
                end
                ADD    : begin
                    case (p_dct[2:0])
                        3'b000,3'b111 : p_dct <= p_dct;
                        3'b001,3'b010 : p_dct <= p_dct + add1;
                        3'b101,3'b110 : p_dct <= p_dct + sub1;
                        3'b100        : p_dct <= p_dct + sub_x2;
                        3'b011        : p_dct <= p_dct + add_x2;
                        default       : p_dct <= p_dct;
                    endcase
                    count = count + 1;
                end
                SHIFT  : begin
                    p_dct <= {p_dct[WIDTH_M+WIDTH_R+2],p_dct[WIDTH_M+WIDTH_R+2],p_dct[WIDTH_M+WIDTH_R+2:2]};
                end
                OUTPUT : begin
                    done <= 1;
                end
            endcase
        end
    end
    
    assign mul_out = p_dct[WIDTH_M+WIDTH_R:1];

endmodule



