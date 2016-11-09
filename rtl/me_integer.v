module me_integer
(
  input  wire        rst_n,
  input  wire        clk,
  input  wire        req,
  input  wire [11:0] init_pos,
  output wire [15:0] min_sad,
  output wire [3:0]  min_diff,
  output wire        ack,

  // memory access ports
  input  wire [7:0]  pel_sw,
  input  wire [7:0]  pel_tb,
  output wire [11:0] addr_sw,
  output wire [7:0]  addr_tb
);

wire [11:0] init_mvec;
wire        en_addr_sw;
wire        en_addr_tb;
wire        clr;
wire        en_sadarray_sw;
wire        en_sadarray_tb;
wire [3:0]  vec_diff;
wire [15:0] sad;

control_integer _control_integer
(
  .rst_n          ( rst_n          ) ,
  .clk            ( clk            ) ,
  .req            ( req            ) ,
  .sad            ( sad            ) ,
  .vec_diff       ( vec_diff       ) ,
  .init_pos       ( init_pos       ) ,
  .clr            ( clr            ) ,
  .en_addr_sw     ( en_addr_sw     ) ,
  .en_addr_tb     ( en_addr_tb     ) ,
  .en_sadarray_sw ( en_sadarray_sw ) ,
  .en_sadarray_tb ( en_sadarray_tb ) ,
  .init_mvec      ( init_mvec      ) ,
  .min_sad        ( min_sad        ) ,
  .min_diff       ( min_diff       ) ,
  .ack            ( ack            )
);

addr_gen_integer _addr_gen_integer
(
  .rst_n     ( rst_n      ) ,
  .clk       ( clk        ) ,
  .clr       ( clr        ) ,
  .en_sw     ( en_addr_sw ) ,
  .en_tb     ( en_addr_tb ) ,
  .init_mvec ( init_mvec  ) ,
  .addr_sw   ( addr_sw    ) ,
  .addr_tb   ( addr_tb    )
);

SAD_array _SAD_array
(
  .rst_n    ( rst_n          ) ,
  .clk      ( clk            ) ,
  .clr      ( clr            ) ,
  .en_sw    ( en_sadarray_sw ) ,
  .en_tb    ( en_sadarray_tb ) ,
  .pel_sw   ( pel_sw         ) ,
  .pel_tb   ( pel_tb         ) ,
  .vec_diff ( vec_diff       ) ,
  .sad      ( sad            )
);

endmodule
