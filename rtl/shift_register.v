`default_nettype none
module shift_register
(
  input  wire              rst_n,
  input  wire              clk,
  input  wire              en,
  input  wire [DWIDTH-1:0] d,
  output wire [DWIDTH-1:0] q
);

parameter DEPTH  = 0;
parameter DWIDTH = 0;

reg [DWIDTH-1:0] core [0:DEPTH-1];
assign q = core[DEPTH-1];

always @(posedge clk or negedge rst_n) begin
  if(~rst_n)
    core[0] <= 0;
  else if(en)
    core[0] <= #1 d;
end

genvar i;
generate
for (i = 1; i < DEPTH; i = i + 1) begin :SHIFT_REG
  always @(posedge clk or negedge rst_n) begin
    if(~rst_n)
      core[i] <= 0;
    else if (en)
      core[i] <= #1 core[i-1];
  end
end
endgenerate

endmodule
`default_nettype wire
