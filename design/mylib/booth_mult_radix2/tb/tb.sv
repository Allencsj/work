module Mbooth_mult_radix2_tb();

    parameter                       L_word = 4;

    logic        [2*L_word-1:0]     product;
    logic                           ready;
    logic                           start;
    logic                           clk;
    logic                           rst_n;
    logic        [L_word-1:0]       mag_1,mag_2;
    logic                           err;

    integer                         word1,word2;//two interger muluti data

    Mbooth_mult_radix2 boot_radix2(clk,rst_n,word1,word2,start,product,err,ready);

    logic        [2*L_word-1:0]     expect_value,expect_mag;
    logic                           code_error;

    parameter                       All_ones  = {L_word{1'b1}};
    parameter                       All_zeros = {L_word{1'b0}};

    initial begin
        clk = 0;
        rst_n = 0;
        #30ns;
        rst_n = 1;
    end

    always #10 clk = ~clk;

    //Error detect
    always_ff@(posedge clk) begin
        if (start) begin
            expect_value = 0;
            case({word1[L_word-1],word2[L_word-1]})
                0 : begin
                    expect_value = word1*word2;
                    expect_mag   = expect_value;
                end
                1 : begin
                    expect_value = word1*{All_ones,word2[L_word-1:0]};
                    expect_mag   = ~expect_value + 1;
                end
                2 : begin
                    expect_value = {All_ones,word1[L_word-1:0]}*word2;
                    expect_mag   = ~expect_value + 1;
                end
                3 : begin
                    expect_value = ({All_zeros,~word1[L_word-1:0]})*({All_zeros,word2[L_word-1:0]});
                    expect_mag   = expect_value;
                end
            endcase
            code_error = 0;
        end else begin
            code_error = ready ? |(product ^ expect_value) : 0;
        end
    end

    initial begin
        #100ns;
        for (word1 = All_zeros;word1<16;word1++) begin
            if (word1[L_word-1] == 0) begin
                mag_1 = word1;
            end else begin
                mag_1 = word1[L_word-1:0];
                mag_1 = ~mag_1 + 1;
            end
            for (word2 = All_zeros;word2<16;word2++) begin
                if (word2[L_word-1] == 0) begin
                    mag_2 = word2;
                end else begin
                    mag_2 = word2[L_word -1:0];
                    mag_2 = ~mag_2 + 1;
                end
                start = 0;
                #40ns;
                start = 1;
                #20ns;
                start = 0;
//                #200ns;
                wait(ready);
            end
        end
        $finish;
    end

    always@(posedge ready) begin
        $display($time,,,"%d * %d = {%d}",word1,word2,product);
    end

    initial begin
        $vcdplusfile("./111.vpd");
        $vcdplusmemon;
        $vcdpluson;
    end

    initial begin
        $fsdbDumpvars();
        $fsdbDumpMDA();
        $dumpvars();
    end

endmodule
