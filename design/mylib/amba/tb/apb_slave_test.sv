module apb_slave_test(
    input                   pclk
    ,input                  presetn
    ,input                  psel
    ,input                  penable
    ,input                  pwrite
    ,input [15:0]           paddr
    ,input [31:0]           pwdata
    ,output [31:0]          prdata
    ,output [31:0]          r0
    ,output [31:0]          r1
    ,output [31:0]          r2
    ,output                 pready

);

parameter   R0_ADDR =   16'h0000;
parameter   R1_ADDR =   16'h0004;
parameter   R2_ADDR =   16'h0008;

wire    write_access;
wire    read_access;
wire    r0_w_access;
wire    r0_r_access;
wire    r1_w_access;

assign r0_w_access = write_access && (paddr[15:0] == R0_ADDR);
assign r0_r_access = read_access  && (paddr[15:0] == R0_ADDR);
assign r1_w_access = write_access && (paddr[15:0] == R1_ADDR);
assign r1_w_access = read_access  && (paddr[15:0] == R1_ADDR);
assign r2_w_access = write_access && (paddr[15:0] == R2_ADDR);
assign r2_w_access = read_access  && (paddr[15:0] == R2_ADDR);

reg [31:0]  pwdata_r;

    always@(posedge pclk) begin
        if (!presetn) begin
            pwdata_r    <=  32'b0;
        end else begin
            pwdata_r    <=  pwdata;
        end
    end

    always@(posedge pclk) begin
        if (!presetn) begin
            r0  <=  32'b0;
            r1  <=  32'b0;
            r2  <=  32'b0;
        end else if (r0_w_access) begins
            r0  <=  pwdata_r;
        end else if (r1_w_access) begins
            r1  <=  pwdata_r;
        end else if (r2_w_access) begins
            r2  <=  pwdata_r;
        end
    end

    always@(posedge pclk) begin
        if (!presetn) begin
            prdata  <=  32'hxxxx_xxxx;
        end else begin
            case(1'b1)
                r0_w_access :   prdata  <=  r0;
                r1_w_access :   prdata  <=  r1;
                r2_w_access :   prdata  <=  r2;
                default     :   prdata  <=  prdata;
            endcase
        end
    end

    assign pready = 1'b1;

endmodule
