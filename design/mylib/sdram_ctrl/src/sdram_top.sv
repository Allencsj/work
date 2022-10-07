//sdram controller top

module sdram_top(
    //system input
     input              sclk
    ,input              srst_n

    //sdram work signal
    ,input              sdr_start
    ,input              wr_req
    ,input              rd_req
    ,output             wr_ack
    ,output             rd_ack
    ,output             wr_done
    ,output             rd_done

    //sdram control signals
    ,input      [31:0]  sdata_i
    ,output reg [31:0]  sdata_o
    ,output reg         sdata_oe_n
    ,output reg         scke
    ,output reg [10:0]  saddr
    ,output reg [ 1:0]  sba
    ,output reg         scs_n
    ,output reg         sras_n
    ,output reg         scas_n
    ,output reg         swe_n
    ,output reg [ 3:0]  sdqm
);

//init wire signals
wire                    init_start;
wire                    init_end;

wire        [10:0]      init_addr;
wire        [31:0]      init_data;
wire        [ 1:0]      init_ba;
wire                    init_cs_n;
wire                    init_ras_n;
wire                    init_cas_n;
wire                    init_we_n;
wire        [ 3:0]      init_dqm;

//write wire signals
wire                    wr_en;

wire        [10:0]      wr_addr;
wire        [31:0]      wr_data;
wire                    wr_oe_n;
wire        [ 1:0]      wr_ba;
wire                    wr_cs_n;
wire                    wr_ras_n;
wire                    wr_cas_n;
wire                    wr_we_n;
wire        [ 3:0]      wr_dqm;

//read wire signals
wire                    rd_en;

wire        [10:0]      rd_addr;
wire                    rd_oe_n;
wire        [ 1:0]      rd_ba;
wire                    rd_cs_n;
wire                    rd_ras_n;
wire                    rd_cas_n;
wire                    rd_we_n;
wire        [ 3:0]      rd_dqm;

//aref wire signals
wire                    aref_en;

wire        [10:0]      aref_addr;
wire        [31:0]      aref_data;
wire                    aref_oe_n;
wire        [ 1:0]      aref_ba;
wire                    aref_cs_n;
wire                    aref_ras_n;
wire                    aref_cas_n;
wire                    aref_we_n;
wire        [ 3:0]      aref_dqm;

    //--------------------------------------
    //sdram control module
    //--------------------------------------
    sdram_ctrl u_sdram_ctrl(.sclk         (sclk         )
                          ,.srst_n        (srst_n       )

                          //sdram ctrl signals
                          ,.sdr_start     (sdr_start    )
                          ,.wr_req        (wr_req       )
                          ,.wr_ack        (wr_ack       )
                          ,.wr_en         (wr_en        )
                          ,.wr_done       (wr_done      )
                          ,.rd_req        (rd_req       )
                          ,.rd_ack        (rd_ack       )
                          ,.rd_en         (rd_en        )
                          ,.rd_done       (rd_done      )
                          ,.aref_req      (aref_req     )
                          ,.aref_ack      (aref_ack     )
                          ,.aref_en       (aref_en      )
                          ,.aref_done     (aref_done    )
                          ,.init_start    (init_start   )
                          ,.init_end      (init_end     )
    );

    //--------------------------------------
    //sdram init module
    //--------------------------------------
    sdram_init u_sdram_init(
                        //system input
                         .sclk            (sclk         ) 
                        ,.srst_n          (srst_n       )

                        //init signals
                        ,.init_start      (init_start   )
                        ,.init_end        (init_end     )

                        //sdram signals
                        ,.init_addr       (init_addr    )
                        ,.init_data       (init_data    )
                        ,.init_ba         (init_ba      )
                        ,.init_cs_n       (init_cs_n    )
                        ,.init_ras_n      (init_ras_n   )
                        ,.init_cas_n      (init_cas_n   )
                        ,.init_we_n       (init_we_n    )
                        ,.init_dqm        (init_dqm     )
    );

    //--------------------------------------
    //sdram write module
    //--------------------------------------
    sdram_write u_sdram_write(
                            //sys signals
                             .sclk           (sclk       )
                            ,.srst_n         (srst_n     )

                            //wr enable signals
                            ,.wr_en          (wr_en      )
                            ,.wr_done        (wr_done    )

                            //wr command signals
                            ,.i_wr_data      (sdata_i    )
                                                         
                            ,.o_wr_addr      (wr_addr    )
                            ,.o_wr_data      (wr_data    )
                            ,.o_wr_oe_n      (wr_oe_n    )
                            ,.o_wr_ba        (wr_ba      )
                            ,.o_wr_dqm       (wr_dqm     )
                            ,.o_wr_cs_n      (wr_cs_n    )
                            ,.o_wr_ras_n     (wr_ras_n   )
                            ,.o_wr_cas_n     (wr_cas_n   )
                            ,.o_wr_we_n      (wr_we_n    )

    );

    //--------------------------------------
    //sdram read module
    //--------------------------------------
    sdram_read  u_sdram_read(
                            //sys signals
                             .sclk           (sclk       )
                            ,.srst_n         (srst_n     )

                            //wr enable signals
                            ,.rd_en          (rd_en      )
                            ,.rd_done        (rd_done    )

                            //rd command signals
                            ,.o_rd_addr      (rd_addr    )
                            ,.o_rd_oe_n      (rd_oe_n    )
                            ,.o_rd_ba        (rd_ba      )
                            ,.o_rd_dqm       (rd_dqm     )
                            ,.o_rd_cs_n      (rd_cs_n    )
                            ,.o_rd_ras_n     (rd_ras_n   )
                            ,.o_rd_cas_n     (rd_cas_n   )
                            ,.o_rd_we_n      (rd_we_n    )

    );

    //--------------------------------------
    //sdram aref module
    //--------------------------------------
    sdram_aref u_sdram_aref(
                            //sys signals
                             .sclk           (sclk       )
                            ,.srst_n         (srst_n     )

                            //wr enable signals
                            ,.init_end       (init_end   )
                            ,.aref_req       (aref_req   )
                            ,.aref_en        (aref_en    )
                            ,.aref_ack       (aref_ack   )
                            ,.aref_done      (aref_done  )

                            //aref command signals
                            ,.aref_addr      (aref_addr  )
                            ,.aref_data      (aref_data  )
                            ,.aref_oe_n      (aref_oe_n  )
                            ,.aref_ba        (aref_ba    )
                            ,.aref_dqm       (aref_dqm   )
                            ,.aref_cs_n      (aref_cs_n  )
                            ,.aref_ras_n     (aref_ras_n )
                            ,.aref_cas_n     (aref_cas_n )
                            ,.aref_we_n      (aref_we_n  )

    );

    // sdram output interface
    always_comb begin
        case({wr_en,rd_en,aref_en})
            3'b100   :   begin
               saddr        = wr_addr ;
               sdata_o      = wr_data ;
               sdata_oe_n   = wr_oe_n ;
               sba          = wr_ba   ; 
               scs_n        = wr_cs_n ;
               sras_n       = wr_ras_n;
               scas_n       = wr_cas_n;
               swe_n        = wr_we_n ;
               sdqm         = wr_dqm ;
               scke         = 1'b1;
            end
            3'b010   :   begin
               saddr        = rd_addr ;
               sdata_oe_n   = rd_oe_n ;
               sba          = rd_ba   ; 
               scs_n        = rd_cs_n ;
               sras_n       = rd_ras_n;
               scas_n       = rd_cas_n;
               swe_n        = rd_we_n ;
               sdqm         = rd_dqm ;
               scke         = 1'b1;
            end
            3'b001   :   begin
               saddr        = aref_addr ;
               sdata_oe_n   = aref_oe_n ;
               sba          = aref_ba   ; 
               scs_n        = aref_cs_n ;
               sras_n       = aref_ras_n;
               scas_n       = aref_cas_n;
               swe_n        = aref_we_n ;
               sdqm         = aref_dqm ;
               scke         = 1'b1;
            end
            default :   begin
               saddr        = init_addr;
               sdata_o      = init_data;
               sdata_oe_n   = 1'b1;
               sba          = init_ba;
               scs_n        = init_cs_n;
               sras_n       = init_ras_n;
               scas_n       = init_cas_n;
               swe_n        = init_we_n;
               sdqm         = init_dqm;
               scke         = 1'b1;
            end
        endcase
    end


endmodule
