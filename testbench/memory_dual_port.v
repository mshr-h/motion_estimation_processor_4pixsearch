`default_nettype none
module memory_dual_port
#(
  parameter DWIDTH  = 6,
  parameter AWIDTH  = 10,
  parameter CONTENT = "./memory.txt"
) (
  input  wire [AWIDTH-1:0] address_a,
  input  wire [AWIDTH-1:0] address_b,
  input  wire              clock,
  input  wire [7:0]        data_a,
  input  wire [7:0]        data_b,
  input  wire              wren_a,
  input  wire              wren_b,
  output reg  [7:0]        q_a,
  output reg  [7:0]        q_b
);

reg [DWIDTH-1:0] core [0:2**AWIDTH-1];

initial begin
  $readmemh(CONTENT, core);
end

// write port
always @(posedge clock) begin
  if(wren_a)
    core[address_a] <= data_a;
  if(wren_b)
    core[address_b] <= data_b;
end

// read port
always @(posedge clock) begin
  q_a <= core[address_a];
  q_b <= core[address_b];
end

endmodule
`default_nettype wire
