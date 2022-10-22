module apb_master(
    input               pclk
    ,input              presetn
    
    ,input              start
    ,input  [31:0]      addr
    ,input  [31:0]      wdata
    ,input              wr_rd
    ,output [31:0]      o_data

    ,input              pready
    ,input  [31:0]      prdata
    ,output [31:0]      paddr
    ,output             psel
    ,output             penable
    ,output             pwrite
    ,output [31:0]      pwdata

    );

    localparam IDLE    =   4'b0001;
    localparam SETUP   =   4'b0010;
    localparam WRITE   =   4'b0100;
    localparam READ    =   4'b1000;

    reg [3:0]   cur_state;
    reg [3:0]   next_state;

    always@(posedge pclk or negedge presetn) begin
        if (presetn == 1'b0) begin
            cur_state   <=  4'b0;
        end else begin
            cur_state   <=  next_state;
        end
    end

    always_comb begin
        case(cur_state)
            IDLE    :   begin
                if (pstart  ==  1'b1) begin
                    next_state  =   SETUP;
                end else begin
                    next_state  =   IDLE;
                end
            end
            SETUP   :   begin
                if (wr_rd   ==  1'b1) begin
                    next_state  =   WRITE;
                end else begin
                    next_state  =   READ;
                end
            end
            WIRTE   :   begin
                if (pready  ==  1'b1) begin
                    next_state  =   IDLE;
                end else begin
                    next_state  =   WRITE;
                end
            end
            READ    :   begin
                if (pready  ==  1'b1) begin
                    next_state  =   IDLE;
                end else begin
                    next_state  =   READ;
                end
            end
            default :   next_state  =   IDLE;
        endcase
    end
    
    always_comb begin
        case (cur_state) 
            IDLE    :   begin
                psel    =   1'b0;
                paddr   =   32'b0;
                penable =   1'b0;
                pwrite  =   1'b0;
                pwdata  =   32'b0
                o_data  =   32'b0;
            end
            SETUP   :   begin
                psel    =   1'b1;
                paddr   =   addr;
                penable =   1'b0;
                pwrite  =   wr_rd;
                pwdata  =   32'b0;
                o_data  =   32'b0;
            end
            WRITE   :   begin
                psel    =   1'b1;
                paddr   =   addr;
                penable =   1'b1;
                pwrite  =   wr_rd;
                pwdata  =   wdata;
                o_data  =   32'b0;
            end
            READ    :   begin
                psel    =   1'b1;
                paddr   =   addr;
                penable =   1'b1;
                pwrite  =   wr_rd;
                pwdata  =   32'b0;
                o_data  =   prdata;
            end
        endcase
    end


endmodule
