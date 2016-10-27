`default_nettype none

module pa_array
(
  input  wire        rst_n,
  input  wire        clk,
  input  wire        en_sw,
  input  wire        en_tb,
  input  wire [31:0] pel_sw,
  input  wire [31:0] pel_tb,
  output reg  [15:0] sad
);

wire [13:0] sad_A;
wire [13:0] sad_B;
wire [13:0] sad_C;
wire [13:0] sad_D;

pe_array pe_array_A
(
  .rst_n  ( rst_n         ) ,
  .clk    ( clk           ) ,
  .en_sw  ( en_sw         ) ,
  .en_tb  ( en_tb         ) ,
  .pel_sw ( pel_sw[31:24] ) ,
  .pel_tb ( pel_tb[31:24] ) ,
  .sad    ( sad_A         )
);

pe_array pe_array_B
(
  .rst_n  ( rst_n         ) ,
  .clk    ( clk           ) ,
  .en_sw  ( en_sw         ) ,
  .en_tb  ( en_tb         ) ,
  .pel_sw ( pel_sw[23:16] ) ,
  .pel_tb ( pel_tb[23:16] ) ,
  .sad    ( sad_B         )
);

pe_array pe_array_C
(
  .rst_n  ( rst_n        ) ,
  .clk    ( clk          ) ,
  .en_sw  ( en_sw        ) ,
  .en_tb  ( en_tb        ) ,
  .pel_sw ( pel_sw[15:8] ) ,
  .pel_tb ( pel_tb[15:8] ) ,
  .sad    ( sad_C        )
);

pe_array pe_array_D
(
  .rst_n  ( rst_n       ) ,
  .clk    ( clk         ) ,
  .en_sw  ( en_sw       ) ,
  .en_tb  ( en_tb       ) ,
  .pel_sw ( pel_sw[7:0] ) ,
  .pel_tb ( pel_tb[7:0] ) ,
  .sad    ( sad_D       )
);

always @(posedge clk or negedge rst_n) begin
  if (~rst_n)
    sad <= 16'd0;
  else
    sad <= (sad_A + sad_B) + (sad_C + sad_D);
end

endmodule

`default_nettype wire
