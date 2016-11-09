`default_nettype none

module SAD_array
(
  input  wire        rst_n,
  input  wire        clk,
  input  wire        clr,
  input  wire        en_sw,
  input  wire        en_tb,
  input  wire [7:0]  pel_sw,
  input  wire [7:0]  pel_tb,
  output reg  [3:0]  vec_diff,
  output reg  [15:0] sad
);

wire [15:0] sad_A;
wire [15:0] sad_B;
wire [15:0] sad_C;
wire [15:0] sad_D;
wire [15:0] sad_E;
wire [15:0] sad_F;
wire [15:0] sad_G;
wire [15:0] sad_H;
wire [15:0] sad_I;

wire [7:0] pel_sw_I;
wire [7:0] pel_sw_H;
wire [7:0] pel_sw_G;
wire [7:0] pel_sr_G_to_F;
wire [7:0] pel_sw_F;
wire [7:0] pel_sw_E;
wire [7:0] pel_sw_D;
wire [7:0] pel_sr_D_to_C;
wire [7:0] pel_sw_C;
wire [7:0] pel_sw_B;

SAD SAD_I
(
  .rst_n  ( rst_n    ) ,
  .clk    ( clk      ) ,
  .clr    ( clr      ) ,
  .en_sw  ( en_sw    ) ,
  .en_tb  ( en_tb    ) ,
  .pel_sw ( pel_sw   ) ,
  .pel_tb ( pel_tb   ) ,
  .nxt_sw ( pel_sw_I ) ,
  .sad    ( sad_I    )
);

SAD SAD_H
(
  .rst_n  ( rst_n    ) ,
  .clk    ( clk      ) ,
  .clr    ( clr      ) ,
  .en_sw  ( en_sw    ) ,
  .en_tb  ( en_tb    ) ,
  .pel_sw ( pel_sw_I ) ,
  .pel_tb ( pel_tb   ) ,
  .nxt_sw ( pel_sw_H ) ,
  .sad    ( sad_H    )
);

SAD SAD_G
(
  .rst_n  ( rst_n    ) ,
  .clk    ( clk      ) ,
  .clr    ( clr      ) ,
  .en_sw  ( en_sw    ) ,
  .en_tb  ( en_tb    ) ,
  .pel_sw ( pel_sw_H ) ,
  .pel_tb ( pel_tb   ) ,
  .nxt_sw ( pel_sw_G ) ,
  .sad    ( sad_G    )
);

shift_register #(.DEPTH(15), .DWIDTH(8) )
sr_G_to_F
(
  .rst_n ( rst_n         ) ,
  .clk   ( clk           ) ,
  .en    ( en_sw         ) ,
  .d     ( pel_sw_G      ) ,
  .q     ( pel_sr_G_to_F )
);

SAD SAD_F
(
  .rst_n  ( rst_n         ) ,
  .clk    ( clk           ) ,
  .clr    ( clr           ) ,
  .en_sw  ( en_sw         ) ,
  .en_tb  ( en_tb         ) ,
  .pel_sw ( pel_sr_G_to_F ) ,
  .pel_tb ( pel_tb        ) ,
  .nxt_sw ( pel_sw_F      ) ,
  .sad    ( sad_F         )
);

SAD SAD_E
(
  .rst_n  ( rst_n    ) ,
  .clk    ( clk      ) ,
  .clr    ( clr      ) ,
  .en_sw  ( en_sw    ) ,
  .en_tb  ( en_tb    ) ,
  .pel_sw ( pel_sw_F ) ,
  .pel_tb ( pel_tb   ) ,
  .nxt_sw ( pel_sw_E ) ,
  .sad    ( sad_E    )
);

SAD SAD_D
(
  .rst_n  ( rst_n    ) ,
  .clk    ( clk      ) ,
  .clr    ( clr      ) ,
  .en_sw  ( en_sw    ) ,
  .en_tb  ( en_tb    ) ,
  .pel_sw ( pel_sw_E ) ,
  .pel_tb ( pel_tb   ) ,
  .nxt_sw ( pel_sw_D ) ,
  .sad    ( sad_D    )
);

shift_register #(.DEPTH(15), .DWIDTH(8) )
sr_D_to_C
(
  .rst_n ( rst_n         ) ,
  .clk   ( clk           ) ,
  .en    ( en_sw         ) ,
  .d     ( pel_sw_D      ) ,
  .q     ( pel_sr_D_to_C )
);

SAD SAD_C
(
  .rst_n  ( rst_n         ) ,
  .clk    ( clk           ) ,
  .clr    ( clr           ) ,
  .en_sw  ( en_sw         ) ,
  .en_tb  ( en_tb         ) ,
  .pel_sw ( pel_sr_D_to_C ) ,
  .pel_tb ( pel_tb        ) ,
  .nxt_sw ( pel_sw_C      ) ,
  .sad    ( sad_C         )
);

SAD SAD_B
(
  .rst_n  ( rst_n    ) ,
  .clk    ( clk      ) ,
  .clr    ( clr      ) ,
  .en_sw  ( en_sw    ) ,
  .en_tb  ( en_tb    ) ,
  .pel_sw ( pel_sw_C ) ,
  .pel_tb ( pel_tb   ) ,
  .nxt_sw ( pel_sw_B ) ,
  .sad    ( sad_B    )
);

SAD SAD_A
(
  .rst_n  ( rst_n    ) ,
  .clk    ( clk      ) ,
  .clr    ( clr      ) ,
  .en_sw  ( en_sw    ) ,
  .en_tb  ( en_tb    ) ,
  .pel_sw ( pel_sw_B ) ,
  .pel_tb ( pel_tb   ) ,
  .sad    ( sad_A    )
);

// --------------------------------------------
// minimum detector
localparam VEC_DIFF_A = 4'b1111;
localparam VEC_DIFF_B = 4'b1100;
localparam VEC_DIFF_C = 4'b1101;
localparam VEC_DIFF_D = 4'b0011;
localparam VEC_DIFF_E = 4'b0000;
localparam VEC_DIFF_F = 4'b0001;
localparam VEC_DIFF_G = 4'b0111;
localparam VEC_DIFF_H = 4'b0100;
localparam VEC_DIFF_I = 4'b0101;

// 1st stage
reg [15:0] min_AB;
reg [15:0] min_CD;
reg [15:0] min_EF;
reg [15:0] min_GH;
reg [15:0] min_I;
reg [3:0]  diff_AB;
reg [3:0]  diff_CD;
reg [3:0]  diff_EF;
reg [3:0]  diff_GH;
reg [3:0]  diff_I;

always @(posedge clk or negedge rst_n) begin
  if(~rst_n) begin
    min_AB  <= 0;
    min_CD  <= 0;
    min_EF  <= 0;
    min_GH  <= 0;
    min_I   <= 0;
    diff_AB <= 0;
    diff_CD <= 0;
    diff_EF <= 0;
    diff_GH <= 0;
    diff_I  <= 0;
  end else begin
    if(sad_A < sad_B) begin
      min_AB  <= #1 sad_A;
      diff_AB <= #1 VEC_DIFF_A;
    end else begin
      min_AB  <= #1 sad_B;
      diff_AB <= #1 VEC_DIFF_B;
    end

    if(sad_C < sad_D) begin
      min_CD  <= #1 sad_C;
      diff_CD <= #1 VEC_DIFF_C;
    end else begin
      min_CD  <= #1 sad_D;
      diff_CD <= #1 VEC_DIFF_D;
    end

    if(sad_E < sad_F) begin
      min_EF  <= #1 sad_E;
      diff_EF <= #1 VEC_DIFF_E;
    end else begin
      min_EF  <= #1 sad_F;
      diff_EF <= #1 VEC_DIFF_F;
    end

    if(sad_G < sad_H) begin
      min_GH  <= #1 sad_G;
      diff_GH <= #1 VEC_DIFF_G;
    end else begin
      min_GH  <= #1 sad_H;
      diff_GH <= #1 VEC_DIFF_H;
    end

    min_I  <= #1 sad_I;
    diff_I <= #1 VEC_DIFF_I;
  end
end

// 2nd stage
reg [15:0] min_ABCD;
reg [15:0] min_EFGH;
reg [15:0] min_I_2;
reg [3:0]  diff_ABCD;
reg [3:0]  diff_EFGH;
reg [3:0]  diff_I_2;

always @(posedge clk or negedge rst_n) begin
  if(~rst_n) begin
    min_ABCD  <= 0;
    min_EFGH  <= 0;
    min_I_2   <= 0;
    diff_ABCD <= 0;
    diff_EFGH <= 0;
    diff_I_2  <= 0;
  end else begin
    if(min_AB < min_CD) begin
      min_ABCD  <= #1 min_AB;
      diff_ABCD <= #1 diff_AB;
    end else begin
      min_ABCD  <= #1 min_CD;
      diff_ABCD <= #1 diff_CD;
    end

    if(min_EF < min_GH) begin
      min_EFGH  <= #1 min_EF;
      diff_EFGH <= #1 diff_EF;
    end else begin
      min_EFGH  <= #1 min_GH;
      diff_EFGH <= #1 diff_GH;
    end

    min_I_2  <= #1 min_I;
    diff_I_2 <= #1 diff_I;
  end
end

// 3rd stage
reg [15:0] min_ABCDEFGH;
reg [15:0] min_I_3;
reg [3:0]  diff_ABCDEFGH;
reg [3:0]  diff_I_3;

always @(posedge clk or negedge rst_n) begin
  if(~rst_n) begin
    min_ABCDEFGH  <= 0;
    min_I_3       <= 0;
    diff_ABCDEFGH <= 0;
    diff_I_3      <= 0;
  end else begin
    if(min_ABCD < min_EFGH) begin
      min_ABCDEFGH  <= #1 min_ABCD;
      diff_ABCDEFGH <= #1 diff_ABCD;
    end else begin
      min_ABCDEFGH  <= #1 min_EFGH;
      diff_ABCDEFGH <= #1 diff_EFGH;
    end

    min_I_3  <= #1 min_I_2;
    diff_I_3 <= #1 diff_I_2;
  end
end

// 4th stage
always @(posedge clk or negedge rst_n) begin
  if(~rst_n) begin
    sad      <= 0;
    vec_diff <= 0;
  end else begin
    if(min_ABCDEFGH < min_I_3) begin
      sad      <= #1 min_ABCDEFGH;
      vec_diff <= #1 diff_ABCDEFGH;
    end else begin
      sad      <= #1 min_I_3;
      vec_diff <= #1 diff_I_3;
    end
  end
end

endmodule
`default_nettype wire
