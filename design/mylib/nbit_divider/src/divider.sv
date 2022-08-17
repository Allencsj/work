//Description: nbit shift divider, can define parameter to change bit WIDTH
//divisor:nbit
//divised:nbit
//quotiend:nbit
//remainder:nbit
//divised/divisor = quotiend ... remainder
//shift: define 2n bits register

module Mdivider
  #(parameter WIDTH = 4)
   (input                 clk
   ,input                 rstn
   ,input                 start
   ,input    [WIDTH-1:0]  divisor
   ,input    [WIDTH-1:0]  divised
   ,output   [WIDTH-1:0]  quotiend
   ,output   [WIDTH-1:0]  remainder
   ,output   reg          done
   );

   reg       [2*WIDTH-1:0]   calu1;
   reg       [2*WIDTH-1:0]   calu2;
   reg       [1:0]           state_r;
   reg       [1:0]           state_next;
   wire      [WIDTH-1:0]     calu1_r;
   wire      [WIDTH-1:0]     calu2_r;
   reg       [WIDTH-1:0]     cnt;
   reg       [WIDTH-1:0]     divisor_r;
   reg       [WIDTH-1:0]     divised_r;
   reg                       start_r;



   enum logic [1:0] {IDLE = 2'b00
                    ,SHIFT= 2'b01
                    ,CALU = 2'b10
                    ,END  = 2'b11
                    }state;

   always_ff@(posedge clk or negedge rstn) begin
       if (!rstn) begin
           start_r <= 0;
       end else if (start == 1) begin
           start_r <= 1;
       end else begin
           start_r <= 0;
       end
   end

   always_ff@(posedge clk or negedge rstn) begin
       if (!rstn) begin
           divisor_r <= 0;
       end else if (start == 1) begin
           divisor_r <= divisor;
       end else begin
           divisor_r <= divisor_r;
       end
   end

   always_ff@(posedge clk or negedge rstn) begin
       if (!rstn) begin
           divised_r <= 0;
       end else if (start == 1) begin
           divised_r <= divised;
       end else begin
           divised_r <= divised_r;
       end
   end

   always_ff@(posedge clk or negedge rstn) begin
       if (!rstn) begin
           state_r <= IDLE;
       end else begin
           state_r <= state_next;
       end
   end

   always_comb begin
       case (state_r)
           IDLE   :   begin
               if (start_r)begin
                   if (divisor_r !=0 && divised_r != 0) begin
                       state_next = SHIFT;
                   end else if (divisor_r == 0) begin
                       state_next = END;
                   end else begin
                       state_next = END;
                   end
               end else begin
                   state_next = IDLE;
               end
           end
           SHIFT  :   begin
               state_next = CALU;
           end
           CALU   :   begin
               if (cnt == WIDTH) begin
                   state_next = END;
               end else begin
                   state_next = SHIFT;
               end
           end
           END    :   begin
               state_next = IDLE;
           end
       endcase
   end

   always_ff@(posedge clk or negedge rstn) begin
       if (!rstn) begin
           done <= 0;
       end else if (state_r == END) begin
           done <= 1;
       end else begin
           done <= 0;
       end
   end

   always_ff@(posedge clk or negedge rstn) begin
       if (!rstn) begin
           cnt <= 0;
       end else if (state_r == END) begin
           cnt <= 0;
       end else if (state_r == SHIFT) begin
           cnt <= cnt + 1;
       end
   end


   always_ff@(posedge clk or negedge rstn) begin
       if (!rstn) begin
           calu1 <= 0;
       end else if (state_r == IDLE) begin
           calu1 = {{WIDTH{1'b0}},divised_r};
       end else if (divisor_r == 0) begin
           calu1 <= '1;
       end else if (divised_r == 0) begin
           calu1 <= 0;
       end else if (state_r == SHIFT) begin
           calu1 <= {calu1[2*WIDTH-2:0],1'b0};
       end else if (state_r == CALU) begin
           if (calu1_r >= calu2_r) begin
               calu1 = calu1 - calu2 + 1;
           end
       end
   end

   always_ff@(posedge clk or negedge rstn) begin
       if (!rstn) begin
           calu2 <= 0;
       end else if (state_r == IDLE) begin
           calu2 = {divisor_r,{WIDTH{1'b0}}};
       end
   end


   assign calu1_r   = calu1[2*WIDTH-1:WIDTH];
   assign calu2_r   = calu2[2*WIDTH-1:WIDTH];
   assign quotiend  = done ? calu1[WIDTH-1:0] : 0;
   assign remainder = done ? calu1[2*WIDTH-1:WIDTH] : 0;


endmodule
