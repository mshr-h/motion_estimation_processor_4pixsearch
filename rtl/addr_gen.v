`default_nettype none

module addr_gen
(
  input  wire       rst_n,
  input  wire       clk,
  input  wire       clr,
  input  wire       en_sw,
  input  wire       en_tb,
  output reg  [9:0] addr_sw,
  output reg  [5:0] addr_tb
);

wire [9:0] nxt_sw = (clr) ? 0
                          : (en_sw) ? addr_sw+1
                                    : addr_sw;
wire [5:0] nxt_tb = (clr) ? 0
                          : (en_tb) ? addr_tb+1
                                    : addr_tb;

always @(posedge clk or negedge rst_n) begin
  if(~rst_n) begin
    addr_sw <= 0;
    addr_tb <= 0;
  end else begin
    addr_sw <= #1 nxt_sw;
    addr_tb <= #1 nxt_tb;
  end
end

endmodule

`default_nettype wire
