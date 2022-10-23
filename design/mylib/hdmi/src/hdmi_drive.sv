//hdmi output color_bar in 1920x1080@16Hz

module hdmi_drive(
    input                   sclk
    ,input                  rst_n

    ,output reg               hs
    ,output reg               vs
    ,output                 video_active

    ,output reg [ 7:0]          rdata
    ,output reg [ 7:0]          gdata
    ,output reg [ 7:0]          bdata
);


//define hdmi parameter
localparam  H_ACTIVE    =   16'd1920;   //hor addr time
localparam  H_FP        =   16'd88;      //hor front porch time
localparam  H_ST        =   16'd44;      //hor sycn time
localparam  H_BP        =   16'd148;    //hor back porch time
localparam  H_TOTAL     =   H_ACTIVE + H_FP + H_ST + H_BP;

localparam  V_ACTIVE    =   16'd1080;
localparam  V_FP        =   16'd4;
localparam  V_BP        =   16'd36;
localparam  V_ST        =   16'd5;
localparam  V_TOTAL     =   V_ACTIVE + V_FP + V_ST + V_BP;


//define color parameter
parameter WHITE_R       = 8'hff;
parameter WHITE_G       = 8'hff;
parameter WHITE_B       = 8'hff;
parameter YELLOW_R      = 8'hff;
parameter YELLOW_G      = 8'hff;
parameter YELLOW_B      = 8'h00;                                
parameter CYAN_R        = 8'h00;
parameter CYAN_G        = 8'hff;
parameter CYAN_B        = 8'hff;                                
parameter GREEN_R       = 8'h00;
parameter GREEN_G       = 8'hff;
parameter GREEN_B       = 8'h00;
parameter MAGENTA_R     = 8'hff;
parameter MAGENTA_G     = 8'h00;
parameter MAGENTA_B     = 8'hff;
parameter RED_R         = 8'hff;
parameter RED_G         = 8'h00;
parameter RED_B         = 8'h00;
parameter BLUE_R        = 8'h00;
parameter BLUE_G        = 8'h00;
parameter BLUE_B        = 8'hff;
parameter BLACK_R       = 8'h00;
parameter BLACK_G       = 8'h00;
parameter BLACK_B       = 8'h00;

//define register and wire
reg     [11:0]              h_cnt;
reg     [11:0]              v_cnt;

reg     [10:0]              active_x;
reg     [10:0]              active_y;

reg                         video_active_r;
reg                         video_active_rr;


//-------------------------------------------------------------------
//Main code
//-------------------------------------------------------------------
    //cnt up
    always@(posedge sclk or negedge rst_n) begin
        if (rst_n   ==  1'b0) begin
            h_cnt   <=  12'd0;
        end else if (h_cnt  ==  H_TOTAL - 1) begin
            h_cnt   <=  0;
        end else begin
            h_cnt   <=  h_cnt + 1'b1;
        end
    end

    always@(posedge sclk or negedge rst_n) begin
        if (rst_n   ==  1'b0) begin
            v_cnt   <=  12'd0;
        end else if (v_cnt  ==  V_TOTAL - 1) begin
            v_cnt   <=  0;
        end else if (h_cnt  ==  H_FP - 1) begin
            if (v_cnt   ==  V_TOTAL) begin
                v_cnt   <=  12'd0;
            end else begin
                v_cnt   <=  v_cnt + 1'b1;
            end
        end else begin
            v_cnt   <=  v_cnt;
        end
    end
    
    //hsync
    always@(posedge sclk or negedge rst_n) begin
        if (rst_n   ==  1'b0) begin
            hs  <=  1'b0;  
        end else if (h_cnt  ==  H_FP - 1) begin
            hs  <=  1'b1;
        end else if (h_cnt  ==  H_ST + H_FP - 1) begin
            hs  <=  1'b0;
        end
    end

    //horization active
    always@(posedge sclk or negedge rst_n) begin
        if (rst_n   ==  1'b0) begin
            active_x    <=  11'd0;
        end else if (active_x   ==  H_ACTIVE) begin
            active_x    <=  11'd0;
        end else if (h_cnt  >=  H_FP + H_ST + H_BP  - 1) begin
            active_x    <=  active_x + 1'b1;
        end
    end
    
    //vsync
    always@(posedge sclk or negedge rst_n) begin
        if (rst_n   ==  1'b0) begin
            vs  <=  1'b0;  
        end else if (v_cnt  ==  V_FP - 1) begin
            vs  <=  1'b1;
        end else if (v_cnt  ==  V_ST + V_FP - 1) begin
            vs  <=  1'b0;
        end
    end

//    //v active
//    always@(posedge sclk or negedge rst_n) begin
//        if (rst_n   ==  1'b0) begin
//            active_y    <=  11'd0;
//        end else if (active_y   ==  V_ACTIVE) begin
//            active_y    <=  11'd0;
//        end else if (v_cnt  >=  V_FP + V_ST + V_BP) begin
//            active_y    <=  active_y + 1'b1;
//        end
//    end

    //video active
    assign video_active_r = (h_cnt >= H_FP + H_ST + H_BP - 1) && (v_cnt >= V_FP + V_ST + V_BP - 1);

    always@(posedge sclk) begin
        video_active_rr <= video_active_r;
    end

    assign video_active = video_active_rr;


    always@(posedge sclk or negedge rst_n) begin
        if (rst_n   ==  1'b0) begin
            rdata   <=  BLACK_R;
            gdata   <=  BLACK_G;
            bdata   <=  BLACK_B;
        end else if (video_active_r   ==  1'b1) begin
            if (active_x    ==  0) begin
                rdata   <=  WHITE_R;
                gdata   <=  WHITE_G;
                bdata   <=  WHITE_B;
            end if (active_x == H_ACTIVE/8 * 1) begin
                rdata   <=  YELLOW_R;
                gdata   <=  YELLOW_G;
                bdata   <=  YELLOW_B;
            end else if (active_x == H_ACTIVE/8 * 2) begin
                rdata   <=  CYAN_R;
                gdata   <=  CYAN_G;
                bdata   <=  CYAN_B;
            end else if (active_x == H_ACTIVE/8 * 3) begin
                rdata   <=  GREEN_R;
                gdata   <=  GREEN_G;
                bdata   <=  GREEN_B;
            end else if (active_x == H_ACTIVE/8 * 4) begin
                rdata   <=  MAGENTA_R;
                gdata   <=  MAGENTA_G;
                bdata   <=  MAGENTA_B;
            end else if (active_x == H_ACTIVE/8 * 5) begin
                rdata   <=  RED_R;
                gdata   <=  RED_G;
                bdata   <=  RED_B;
            end else if (active_x == H_ACTIVE/8 * 6) begin
                rdata   <=  BLUE_R;
                gdata   <=  BLUE_G;
                bdata   <=  BLUE_B;
            end else if (active_x == H_ACTIVE/8 * 7) begin
                rdata   <=  BLACK_R;
                gdata   <=  BLACK_G;
                bdata   <=  BLACK_B;
            end
        end else begin
            rdata   <=  rdata;
            gdata   <=  gdata;
            bdata   <=  bdata;
        end
    end
    

endmodule
