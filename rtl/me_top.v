module me_top
(
  input  wire        rst_n,
  input  wire        clk,
  input  wire        req,
  output wire [15:0] min_sad,
  output wire [11:0] min_mvec,
  output wire        ack,

  // memory access ports
  input  wire [31:0] pel_sw_d,
  input  wire [31:0] pel_tb_d,
  input  wire [7:0]  pel_sw_i,
  input  wire [7:0]  pel_tb_i,
  output wire [9:0]  addr_sw_d,
  output wire [5:0]  addr_tb_d,
  output wire [11:0] addr_sw_i,
  output wire [7:0]  addr_tb_i
);

wire        req_d;
wire        ack_d;
wire        req_i;
wire        ack_i;
wire [11:0] init_pos_i;
wire [9:0]  min_mvec_d;
wire [15:0] min_sad_i;
wire [3:0]  min_diff_i;

control_top _control_top
(
  .rst_n      ( rst_n      ) ,
  .clk        ( clk        ) ,

  .req        ( req        ) ,
  .ack        ( ack        ) ,
  .min_mvec   ( min_mvec   ) ,
  .min_sad    ( min_sad    ) ,

  // between me_double
  .req_d      ( req_d      ) ,
  .min_mvec_d ( min_mvec_d ) ,
  .ack_d      ( ack_d      ) ,

  // between me_integer
  .req_i      ( req_i      ) ,
  .init_pos_i ( init_pos_i ) ,
  .min_sad_i  ( min_sad_i  ) ,
  .min_diff_i ( min_diff_i ),
  .ack_i      ( ack_i      )
);

me_double _me_double
(
  .rst_n    ( rst_n      ) ,
  .clk      ( clk        ) ,
  .req      ( req_d      ) ,
  .min_sad  (            ) ,
  .min_mvec ( min_mvec_d ) ,
  .ack      ( ack_d      ) ,

  // memory access ports
  .pel_sw  ( pel_sw_d  ) ,
  .pel_tb  ( pel_tb_d  ) ,
  .addr_sw ( addr_sw_d ) ,
  .addr_tb ( addr_tb_d )
);

me_integer _me_integer
(
  .rst_n    ( rst_n      ) ,
  .clk      ( clk        ) ,
  .req      ( req_i      ) ,
  .init_pos ( init_pos_i ) ,
  .min_sad  ( min_sad_i  ) ,
  .min_diff ( min_diff_i ) ,
  .ack      ( ack_i      ) ,

  // memory access ports
  .pel_sw  ( pel_sw_i  ) ,
  .pel_tb  ( pel_tb_i  ) ,
  .addr_sw ( addr_sw_i ) ,
  .addr_tb ( addr_tb_i )
);

endmodule
