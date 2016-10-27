`default_nettype none
module memory_tb
(
  input  wire        rst_n,
  input  wire        clk,
  input  wire [5:0]  addr_a,
  input  wire [7:0]  addr_b,
  output wire [31:0] data_a, // {A, B, C, D}
  output reg  [7:0]  data_b
);

parameter MEM_TB_A = "";
parameter MEM_TB_B = "";
parameter MEM_TB_C = "";
parameter MEM_TB_D = "";

wire [7:0] data_b_A;
wire [7:0] data_b_B;
wire [7:0] data_b_C;
wire [7:0] data_b_D;

memory_dual_port memory_dual_port_A
(
  .address_a ( addr_a                     ) ,
  .address_b ( {addr_b[7:5], addr_b[3:1]} ) ,
  .clock     ( clk                        ) ,
  .data_a    ( 8'd0                       ) ,
  .data_b    ( 8'd0                       ) ,
  .wren_a    ( 1'b0                       ) ,
  .wren_b    ( 1'b0                       ) ,
  .q_a       ( data_a[31:24]              ) ,
  .q_b       ( data_b_A                   )
);
defparam memory_dual_port_A.DWIDTH = 8;
defparam memory_dual_port_A.AWIDTH = 6;
defparam memory_dual_port_A.CONTENT = MEM_TB_A;

memory_dual_port memory_dual_port_B
(
  .address_a ( addr_a                     ) ,
  .address_b ( {addr_b[7:5], addr_b[3:1]} ) ,
  .clock     ( clk                        ) ,
  .data_a    ( 8'd0                       ) ,
  .data_b    ( 8'd0                       ) ,
  .wren_a    ( 1'b0                       ) ,
  .wren_b    ( 1'b0                       ) ,
  .q_a       ( data_a[23:16]              ) ,
  .q_b       ( data_b_B                   )
);
defparam memory_dual_port_B.DWIDTH = 8;
defparam memory_dual_port_B.AWIDTH = 6;
defparam memory_dual_port_B.CONTENT = MEM_TB_B;

memory_dual_port memory_dual_port_C
(
  .address_a ( addr_a                     ) ,
  .address_b ( {addr_b[7:5], addr_b[3:1]} ) ,
  .clock     ( clk                        ) ,
  .data_a    ( 8'd0                       ) ,
  .data_b    ( 8'd0                       ) ,
  .wren_a    ( 1'b0                       ) ,
  .wren_b    ( 1'b0                       ) ,
  .q_a       ( data_a[15:8]               ) ,
  .q_b       ( data_b_C                   )
);
defparam memory_dual_port_C.DWIDTH = 8;
defparam memory_dual_port_C.AWIDTH = 6;
defparam memory_dual_port_C.CONTENT = MEM_TB_C;

memory_dual_port memory_dual_port_D
(
  .address_a ( addr_a                     ) ,
  .address_b ( {addr_b[7:5], addr_b[3:1]} ) ,
  .clock     ( clk                        ) ,
  .data_a    ( 8'd0                       ) ,
  .data_b    ( 8'd0                       ) ,
  .wren_a    ( 1'b0                       ) ,
  .wren_b    ( 1'b0                       ) ,
  .q_a       ( data_a[7:0]                ) ,
  .q_b       ( data_b_D                   )
);
defparam memory_dual_port_D.DWIDTH = 8;
defparam memory_dual_port_D.AWIDTH = 6;
defparam memory_dual_port_D.CONTENT = MEM_TB_D;

always @(*) begin
  case ({addr_b[4], addr_b[0]})
    2'b00:   data_b <= data_b_A;
    2'b01:   data_b <= data_b_B;
    2'b10:   data_b <= data_b_C;
    2'b11:   data_b <= data_b_D;
    default: data_b <= 8'dx;
  endcase
end

endmodule
`default_nettype wire

