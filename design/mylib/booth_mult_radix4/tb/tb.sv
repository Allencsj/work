module Mbooth_radix4_tb();

`define TEST_WIDTH 4

parameter WIDTH_M = `TEST_WIDTH;
parameter WIDTH_R = `TEST_WIDTH;

    logic                                clk;
    logic                                rstn;
    logic                                vld_in;
    logic     [WIDTH_M-1:0]              multiplicand;
    logic     [WIDTH_M-1:0]              multiplier;

    wire  signed     [WIDTH_M+WIDTH_R-1:0]      mul_out;
    logic                                done;

    wire  signed    [`TEST_WIDTH-1:0]    m1_in;
    wire  signed    [`TEST_WIDTH-1:0]    m2_in;

    reg   signed    [2*`TEST_WIDTH-1:0]  product_ref;
    logic           [2*`TEST_WIDTH-1:0]  product_ref_u;

    assign m1_in = multiplier[`TEST_WIDTH-1:0];
    assign m2_in = multiplicand[`TEST_WIDTH-1:0];

    always #1 clk = ~clk;

    integer i,j;
    integer num_good;

    initial begin
        clk = 0;
        vld_in = 0;
        multiplicand = 0;
        multiplier = 0;
        num_good = 0;
        rstn = 1;
        #4 rstn = 0;
        #2 rstn = 1;
        repeat (2) @(posedge clk);
        for (i=0;i<(1<<`TEST_WIDTH);i++) begin
            for (j=0;j<(1<<`TEST_WIDTH);j++) begin
                vld_in = 1;
                wait(done == 0);
                wait(done == 1);
                product_ref   = m1_in * m2_in;
                product_ref_u = m1_in * m2_in;
                if (product_ref != mul_out) begin
                    $display ("multiplier = %d multiplicand = %d product = %d",m1_in, m2_in, mul_out);
                    @(posedge clk);
                    $finish;
                end else begin
                    num_good = num_good + 1;
                    $display ("!!multiplier = %d multiplicand = %d product = %d",m1_in, m2_in, mul_out);
                end
                multiplicand = multiplicand + 1;
            end
            multiplier = multiplier + 1;
        end
        $display ("sim done. num_good = %d",num_good);
        $finish;
    end

    Mbooth_radix4 #( .WIDTH_M (WIDTH_M)
                    ,.WIDTH_R (WIDTH_R))
    booth_radix4
    (.clk          (clk)
    ,.rstn         (rstn)
    ,.vld_in       (vld_in)
    ,.multiplicand (multiplicand)
    ,.multiplier   (multiplier)
    ,.mul_out      (mul_out)
    ,.done         (done)
    );
    
    initial begin
        $vcdplusfile("./111.vpd");
        $vcdplusmemon;
        $vcdpluson;
    end

//    initial begin
//        $fsdbDumpvars();
//        $fsdbDumpMDA();
//        $dumpvars();
//    end
//
endmodule
