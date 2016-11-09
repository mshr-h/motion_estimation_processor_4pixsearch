`default_nettype none
module SAD
(
  input  wire        rst_n,
  input  wire        clk,
  input  wire        clr,
  input  wire        en_sw,
  input  wire        en_tb,
  input  wire [7:0]  pel_sw,
  input  wire [7:0]  pel_tb,
  output reg  [7:0]  nxt_sw,
  output reg  [7:0]  nxt_tb,
  output reg  [15:0] sad
);

wire [7:0] ad = (nxt_tb < nxt_sw) ? nxt_sw - nxt_tb
                                  : nxt_tb - nxt_sw;

always @(posedge clk or negedge rst_n) begin
  if(~rst_n) begin
    nxt_sw <= 0;
    nxt_tb <= 0;
    sad    <= 0;
  end else begin
    if(clr) begin
      nxt_sw <= 0;
      nxt_tb <= 0;
      sad    <= 0;
    end else begin
      if(en_sw)
        nxt_sw <= #1 pel_sw;
      if(en_tb) begin
        nxt_tb <= #1 pel_tb;
        sad    <= #1 sad + {8'd0, ad};
      end
    end
  end
end

endmodule
`default_nettype wire
