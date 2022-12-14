interface counter_if(input clk);
      
    logic rst,updown,load;
    logic [3:0] data;
    logic [3:0] data_out;


    // direction depend on verification platform
    clocking wr_cb@(posedge clk);
//        default input #1ns output #1ns;
        output load, updown,rst;
        output data;
    endclocking

    clocking wrmon_cb@(posedge clk);
        input data;
        input load, rst, updown;
    endclocking

    clocking rdmon_cb@(posedge clk);
        input data_out;
    endclocking

    modport WR_BFM(clocking wr_cb);
    modport WR_MON(clocking wrmon_cb);
    modport RD_MON(clocking rdmon_cb);


endinterface
