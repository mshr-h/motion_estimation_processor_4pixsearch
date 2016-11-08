`default_nettype none
module memory_dual_port
(
  input  wire [AWIDTH-1:0] address_a,
  input  wire [AWIDTH-1:0] address_b,
  input  wire              clock,
  input  wire [DWIDTH-1:0] data_a,
  input  wire [DWIDTH-1:0] data_b,
  input  wire              wren_a,
  input  wire              wren_b,
  output reg  [DWIDTH-1:0] q_a,
  output reg  [DWIDTH-1:0] q_b
);

parameter DWIDTH  = 0;
parameter AWIDTH  = 0;
parameter CONTENT = "";

reg [DWIDTH-1:0] core [0:2**AWIDTH-1];

initial begin
  $readmemh(CONTENT, core);
end

// write port
always @(posedge clock) begin
  if(wren_a)
    core[address_a] <= #1 data_a;
  if(wren_b)
    core[address_b] <= #1 data_b;
end

// read port
always @(posedge clock) begin
  q_a <= #1 core[address_a];
  q_b <= #1 core[address_b];
end

endmodule
`default_nettype wire
