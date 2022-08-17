module M1bit_adder(

    input  A,
    input  B,
    output wire sum,
    output wire cout
    );

    assign {cout,sum} = A + B;

endmodule
