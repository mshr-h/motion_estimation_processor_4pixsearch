`default_nettype none

module addr_gen_integer
(
  input  wire        rst_n,
  input  wire        clk,
  input  wire        clr,
  input  wire        en_sw,
  input  wire        en_tb,
  input  wire [11:0] init_mvec, // {w, h}
  output reg  [11:0] addr_sw,
  output reg  [7:0]  addr_tb
);

reg       en_sw_pre;
reg [4:0] cnt_h;
reg [4:0] cnt_w;

always @(posedge clk or negedge rst_n) begin
  if(~rst_n) begin
    addr_sw <= 0;
    cnt_h   <= 0;
    cnt_w   <= 0;
  end else begin
    if(clr) begin
      addr_sw <= #1 0;
      cnt_h   <= #1 0;
      cnt_w   <= #1 0;
    end else if(en_sw && ~en_sw_pre) begin
      addr_sw <= #1 init_mvec;
      cnt_h   <= #1 0;
      cnt_w   <= #1 0;
    end else if(en_sw) begin
      if(cnt_h < 17) begin
        addr_sw <= #1 {addr_sw[11:6]     , addr_sw[5:0]+6'd1 };
        cnt_h   <= #1 cnt_h + 1;
      end else begin
        addr_sw <= #1 {addr_sw[11:6]+6'd1, addr_sw[5:0]-6'd17};
        cnt_h   <= #1 0;
        cnt_w   <= #1 cnt_w + 1;
      end
    end
  end
end

always @(posedge clk or negedge rst_n) begin
  if(~rst_n)
    addr_tb <= 0;
  else if(clr)
    addr_tb <= #1 0;
  else if(en_tb)
    addr_tb <= #1 addr_tb + 1;
end

always @(posedge clk or negedge rst_n) begin
  if(~rst_n)
    en_sw_pre <= 0;
  else
    en_sw_pre <= #1 en_sw;
end

endmodule

`default_nettype wire
