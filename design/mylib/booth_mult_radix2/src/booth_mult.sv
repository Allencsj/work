module Mbooth_mult_radix2
    #(parameter  L_word = 4
     ,parameter  L_SRC  = 2)
     (
      input                      i_clk
     ,input                      i_rst_n
     ,input     [L_word-1:0]     i_word1
     ,input     [L_word-1:0]     i_word2
     ,input                      i_start
     ,output    [2*L_word-1:0]   o_product
     ,output                     o_err
     ,output                     Ready
     );

    parameter                    All_ones  = {L_word{1'b1}};
    parameter                    All_zeros = {L_word{1'b0}};

    wire                         m0;
    wire                         Load_words;
    wire                         Shift;
    wire                         Add;
    wire                         Sub;
    wire                         Ready;
    
    Mcontroller_booth controller_booth
      (
        .clk                     (i_clk        )
       ,.rst_n                   (i_rst_n      )
       ,.i_start                 (i_start      )
       ,.i_m0                    (m0           )
       ,.Load_words              (Load_words   )
       ,.Shift                   (Shift        )
       ,.Add                     (Add          )
       ,.Sub                     (Sub          )
       ,.Ready                   (Ready        )
       ,.err                     (o_err        )
      );

    Mdatapath_booth datapath_booth
      (
        .clk                     (i_clk        )
       ,.rst_n                   (i_rst_n      )
       ,.word1                   (i_word1      )
       ,.word2                   (i_word2      )
       ,.Load_words              (Load_words   )
       ,.Shift                   (Shift        )
       ,.Add                     (Add          )
       ,.Sub                     (Sub          )
       ,.Ready                   (Ready        )
       ,.m0                      (m0           )
       ,.product                 (o_product    )
      );



endmodule
