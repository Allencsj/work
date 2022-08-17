// tb for mic

module tb();

    parameter WIDTH=2;

    logic               clk;
    logic               rstn;
    logic  [WIDTH-1:0]  quotiend;
    logic  [WIDTH-1:0]  remainder;
    logic  [WIDTH-1:0]  divisor;
    logic  [WIDTH-1:0]  divised;
    logic               start;
    logic               done;

    Mdivider #(.WIDTH(WIDTH))
    dut
    (.clk(clk)
    ,.rstn(rstn)
    ,.start(start)
    ,.divisor(divisor)
    ,.divised(divised)
    ,.quotiend(quotiend)
    ,.remainder(remainder)
    ,.done(done)
    );

    always #5 clk = ~clk;
    
    initial begin
        clk = 0;
        rstn = 0;
        start = 0;
        divisor = 0;
        divised = 0;
        #100ns;
        rstn = 1;
    end

    integer i,j;
    integer quo;
    integer rem;
    integer pass_num = 0;

    initial begin
        wait(rstn);
        @(posedge clk);
        #1ns;
        for(i=0;i<2**WIDTH;i++) begin
            for(j=0;j<2**WIDTH;j++) begin
//                quo = 10/6;
//                rem = 10%6;
//                $display("%d",i);
//                $display("%d",j);
                divisor = i;
                divised = j;
                #1ns;
                start = 1;
                @(posedge clk);
                #1ns;
                start = 0;
                $display("position111!");
                wait (done);
                $display("position222!");
                if (i ==0 ) begin
                    if (quotiend == {WIDTH{1'b1}} && remainder == {WIDTH{1'b1}}) begin
                        $display("PASS! quotiend = %d, remainder = %d",quotiend,remainder);
                    end else  begin
                        $display("FAILED! quotiend = %d, remainder = %d",quotiend,remainder);
                        #1ns;
                        $finish;
                    end
                end else if (j == 0 && i != 0) begin
                    if (quotiend ==0 && remainder ==0) begin
                        $display("PASS! quotiend = %d, remainder = %d",quotiend,remainder);
                    end else begin 
                        $display("FAILED! quotiend = %d, remainder = %d",quotiend,remainder);
                        #1ns;
                        $finish;
                    end
                end else begin
                    quo = j/i;
                    rem = j%i;
                    $display("%d",quo);
                    $display("%d",rem);
                    if (quo == quotiend && rem == remainder) begin
                        $display("PASS! quotiend = %d, remainder = %d",quotiend,remainder);
                    end else begin
                        $display("FAILED! quotiend = %d, remainder = %d",quotiend,remainder);
                        #1ns;
                        $finish;
                    end
                end
                @(posedge clk);
                pass_num =pass_num + 1;
                $display("pass_num is %d",pass_num);
            end
        end
        $finish;
    end

    //dump wave
    initial begin
        $vcdplusfile("111.vpd");
        $vcdplusmemon;
        $vcdpluson;
//        #400ns;
//        $finish;
    end
endmodule
