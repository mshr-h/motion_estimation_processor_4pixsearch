`default_nettype none
module sum (
  input  wire             rst_n,
  input  wire             clk,
  input  wire [8*8*8-1:0] ad, // 8*8*8
  output reg  [13:0]      sum
);

genvar i,j,k;

reg [7:0] preg1 [0:63];
generate
for (i = 0; i < 64; i = i + 1) begin : PIPELINE1
  always @(posedge clk or negedge rst_n) begin
    if(~rst_n)
      preg1[i] <= 0;
    else
      preg1[i] <= ad[(i+1)*8-1:i*8];
  end
end
endgenerate

reg [9:0] preg2 [0:15];
generate
for (j = 0; j < 16; j = j + 1) begin : PIPELINE2
  always @(posedge clk or negedge rst_n) begin
    if(~rst_n)
      preg2[j] <= 0;
    else
      preg2[j] <= #1 (preg1[j*4]+preg1[j*4+1])+(preg1[j*4+2]+preg1[j*4+3]);
  end
end
endgenerate

reg [11:0] preg3 [0:3];
generate
for (k = 0; k < 4; k = k + 1) begin : PIPELINE3
  always @(posedge clk or negedge rst_n) begin
    if(~rst_n)
      preg3[k] <= 0;
    else
      preg3[k] <= #1 (preg2[k*4]+preg2[k*4+1])+(preg2[k*4+2]+preg2[k*4+3]);
  end
end
endgenerate

always @(posedge clk or negedge rst_n) begin
  if(~rst_n)
    sum <= 0;
  else
    sum <= #1 (preg3[0]+preg3[1])+(preg3[2]+preg3[3]);
end

endmodule
`default_nettype wire
