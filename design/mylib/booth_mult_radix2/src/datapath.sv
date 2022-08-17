module Mdatapath_booth
    #(parameter L_word = 4)
    (
      input                        clk
     ,input                        rst_n
     ,input    [L_word-1:0]        word1
     ,input    [L_word-1:0]        word2
     ,input                        Load_words
     ,input                        Shift
     ,input                        Add
     ,input                        Sub
     ,input                        Ready
     ,output                       m0
     ,output   reg [2*L_word-1:0]  product
    );

    reg        [2*L_word-1:0]      multiplicand;
    reg        [L_word-1  :0]      multiplier;

    parameter                      All_ones  = {L_word{1'b1}};
    parameter                      All_zeros = {L_word{1'b0}};

    //data path
    always_ff @ (posedge clk) begin
        if (!rst_n) begin
            multiplier   <= 0;
            multiplicand <= 0;
            product      <= 0;
        end else if (Load_words) begin
            if (word1[L_word -1] == 0) begin
                multiplicand <= word1;
            end else begin
                multiplicand <= {All_ones,word1};
            end
            multiplier <= word2;
            product    <= 0;
        end else if (Shift) begin
            multiplier   <= multiplier   >> 1;
            multiplicand <= multiplicand << 1;
        end else if (Add) begin
            product <= product + multiplicand;
        end else if (Sub) begin
            product <= product - multiplicand;
        end
    end

    assign                         m0 = multiplier[0];

endmodule

