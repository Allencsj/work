module tb();
   reg A,B;
   wire sum,cout;

   integer i,j;

   M1bit_adder dut(.A(A),.B(B),.sum(sum),.cout(cout));

   initial begin
       for (i=0;i<16;i++) begin
            #20ns;
            A = i;
       end
   end
   
   initial begin
       for (j=0;j<16;j++) begin
            #10ns;
            B = j;
       end
   end

   initial begin
       $monitor($time,,,"%d + %d = {%b,%d}",A,B,cout,sum);
       #400ns;
       $finish;
   end

   initial begin
       $vcdplusfile("./111.vpd");
       $vcdplusmemon;
       $vcdpluson;
   end

endmodule
