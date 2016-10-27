module me_double
(
  input  wire        rst_n,
  input  wire        clk,
  input  wire        req,
  output wire [15:0] min_sad,
  output wire [9:0]  min_mvec,
  output wire        ack,

  // memory access ports
  input  wire [31:0] pel_sw,
  input  wire [31:0] pel_tb,
  output wire [9:0]  addr_sw,
  output wire [5:0]  addr_tb
);

wire        en_addr_sw;
wire        en_addr_tb;
wire        clr;
wire        en_paarray_sw;
wire        en_paarray_tb;
wire [15:0] sad;

control_double _control_double
(
  .rst_n         ( rst_n         ) ,
  .clk           ( clk           ) ,
  .req           ( req           ) ,
  .sad           ( sad           ) ,
  .clr           ( clr           ) ,
  .en_addr_sw    ( en_addr_sw    ) ,
  .en_addr_tb    ( en_addr_tb    ) ,
  .en_paarray_sw ( en_paarray_sw ) ,
  .en_paarray_tb ( en_paarray_tb ) ,
  .min_sad       ( min_sad       ) ,
  .min_mvec      ( min_mvec      ) ,
  .ack           ( ack           )
);

addr_gen _addr_gen
(
  .rst_n   ( rst_n      ) ,
  .clk     ( clk        ) ,
  .en_sw   ( en_addr_sw ) ,
  .en_tb   ( en_addr_tb ) ,
  .clr     ( clr        ) ,
  .addr_sw ( addr_sw    ) ,
  .addr_tb ( addr_tb    )
);

pa_array _pa_array
(
  .rst_n  ( rst_n         ) ,
  .clk    ( clk           ) ,
  .en_sw  ( en_paarray_sw ) ,
  .en_tb  ( en_paarray_tb ) ,
  .pel_sw ( pel_sw        ) ,
  .pel_tb ( pel_tb        ) ,
  .sad    ( sad           )
);

endmodule
