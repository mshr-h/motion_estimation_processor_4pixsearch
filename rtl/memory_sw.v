`default_nettype none
module memory_sw
(
  input  wire        rst_n,
  input  wire        clk,
  input  wire [9:0]  addr_a,
  input  wire [11:0] addr_b,
  output wire [31:0] data_a, // {A, B, C, D}
  output reg  [7:0]  data_b
);

parameter MEM_SW_A = "";
parameter MEM_SW_B = "";
parameter MEM_SW_C = "";
parameter MEM_SW_D = "";

wire [7:0] data_b_A;
wire [7:0] data_b_B;
wire [7:0] data_b_C;
wire [7:0] data_b_D;

memory_dual_port memory_dual_port_A
(
  .address_a ( addr_a                      ) ,
  .address_b ( {addr_b[11:7], addr_b[5:1]} ) ,
  .clock     ( clk                         ) ,
  .data_a    ( 8'd0                        ) ,
  .data_b    ( 8'd0                        ) ,
  .wren_a    ( 1'b0                        ) ,
  .wren_b    ( 1'b0                        ) ,
  .q_a       ( data_a[31:24]               ) ,
  .q_b       ( data_b_A                    )
);
defparam memory_dual_port_A.DWIDTH = 8;
defparam memory_dual_port_A.AWIDTH = 10;
defparam memory_dual_port_A.CONTENT = MEM_SW_A;

memory_dual_port memory_dual_port_B
(
  .address_a ( addr_a                      ) ,
  .address_b ( {addr_b[11:7], addr_b[5:1]} ) ,
  .clock     ( clk                         ) ,
  .data_a    ( 8'd0                        ) ,
  .data_b    ( 8'd0                        ) ,
  .wren_a    ( 1'b0                        ) ,
  .wren_b    ( 1'b0                        ) ,
  .q_a       ( data_a[23:16]               ) ,
  .q_b       ( data_b_B                    )
);
defparam memory_dual_port_B.DWIDTH = 8;
defparam memory_dual_port_B.AWIDTH = 10;
defparam memory_dual_port_B.CONTENT = MEM_SW_B;

memory_dual_port memory_dual_port_C
(
  .address_a ( addr_a                      ) ,
  .address_b ( {addr_b[11:7], addr_b[5:1]} ) ,
  .clock     ( clk                         ) ,
  .data_a    ( 8'd0                        ) ,
  .data_b    ( 8'd0                        ) ,
  .wren_a    ( 1'b0                        ) ,
  .wren_b    ( 1'b0                        ) ,
  .q_a       ( data_a[15:8]                ) ,
  .q_b       ( data_b_C                    )
);
defparam memory_dual_port_C.DWIDTH = 8;
defparam memory_dual_port_C.AWIDTH = 10;
defparam memory_dual_port_C.CONTENT = MEM_SW_C;

memory_dual_port memory_dual_port_D
(
  .address_a ( addr_a                      ) ,
  .address_b ( {addr_b[11:7], addr_b[5:1]} ) ,
  .clock     ( clk                         ) ,
  .data_a    ( 8'd0                        ) ,
  .data_b    ( 8'd0                        ) ,
  .wren_a    ( 1'b0                        ) ,
  .wren_b    ( 1'b0                        ) ,
  .q_a       ( data_a[7:0]                 ) ,
  .q_b       ( data_b_D                    )
);
defparam memory_dual_port_D.DWIDTH = 8;
defparam memory_dual_port_D.AWIDTH = 10;
defparam memory_dual_port_D.CONTENT = MEM_SW_D;

always @(*) begin
  case ({addr_b[6], addr_b[0]})
    2'b00:   data_b <= data_b_A;
    2'b01:   data_b <= data_b_B;
    2'b10:   data_b <= data_b_C;
    2'b11:   data_b <= data_b_D;
    default: data_b <= 8'dx;
  endcase
end

endmodule
`default_nettype wire
