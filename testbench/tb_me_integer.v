`include "./memory_dual_port.v"
`include "../rtl/addr_gen_integer.v"
`include "../rtl/control_integer.v"
`include "../rtl/memory_sw.v"
`include "../rtl/memory_tb.v"
`include "../rtl/shift_register.v"
`include "../rtl/SAD.v"
`include "../rtl/SAD_array.v"
`include "../rtl/me_integer.v"

`default_nettype none

module tb_me_integer;

localparam MEM_SW_A = "../memory/memory_sw_A.txt";
localparam MEM_SW_B = "../memory/memory_sw_B.txt";
localparam MEM_SW_C = "../memory/memory_sw_C.txt";
localparam MEM_SW_D = "../memory/memory_sw_D.txt";
localparam MEM_TB_A = "../memory/memory_tb_A.txt";
localparam MEM_TB_B = "../memory/memory_tb_B.txt";
localparam MEM_TB_C = "../memory/memory_tb_C.txt";
localparam MEM_TB_D = "../memory/memory_tb_D.txt";

reg         rst_n;
reg         clk;
reg         req;
reg  [5:0]  init_pos_h;
reg  [5:0]  init_pos_w;
wire [15:0] min_sad;
wire [1:0]  min_diff_h;
wire [1:0]  min_diff_w;
wire        ack;
wire [7:0]  pel_sw;
wire [7:0]  pel_tb;
wire [11:0] addr_sw;
wire [5:0]  addr_sw_h;
wire [5:0]  addr_sw_w;
wire [7:0]  addr_tb;

me_integer _me_integer
(
  .rst_n    ( rst_n                    ) ,
  .clk      ( clk                      ) ,
  .req      ( req                      ) ,
  .init_pos ( {init_pos_w, init_pos_h} ) ,
  .min_sad  ( min_sad                  ) ,
  .min_diff ( {min_diff_w, min_diff_h} ) ,
  .ack      ( ack                      ) ,

  // memory access ports
  .pel_sw  ( pel_sw                 ) ,
  .pel_tb  ( pel_tb                 ) ,
  .addr_sw ( {addr_sw_w, addr_sw_h} ) ,
  .addr_tb ( addr_tb                )
);

memory_sw
_memory_sw
(
  .rst_n  ( rst_n                  ) ,
  .clk    ( clk                    ) ,
  .addr_a ( 10'd0                  ) ,
  .addr_b ( {addr_sw_w, addr_sw_h} ) ,
  .data_a (                        ) ,
  .data_b ( pel_sw                 )
);
defparam _memory_sw.MEM_SW_A = MEM_SW_A;
defparam _memory_sw.MEM_SW_B = MEM_SW_B;
defparam _memory_sw.MEM_SW_C = MEM_SW_C;
defparam _memory_sw.MEM_SW_D = MEM_SW_D;

memory_tb
_memory_tb
(
  .rst_n  ( rst_n   ) ,
  .clk    ( clk     ) ,
  .addr_a ( 6'd0    ) ,
  .addr_b ( addr_tb ) ,
  .data_a (         ) ,
  .data_b ( pel_tb  )
);
defparam _memory_tb.MEM_TB_A = MEM_TB_A;
defparam _memory_tb.MEM_TB_B = MEM_TB_B;
defparam _memory_tb.MEM_TB_C = MEM_TB_C;
defparam _memory_tb.MEM_TB_D = MEM_TB_D;


localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) clk = ~clk;

initial begin
  $dumpfile("tb_me_integer.vcd");
  $dumpvars(0, tb_me_integer);
end

initial begin
  #1 rst_n<=1'bx;clk<=1'bx;req<=1'bx;init_pos_h<=6'dx;init_pos_w<=6'dx;
  #(CLK_PERIOD) rst_n<=1;
  #(CLK_PERIOD*3) rst_n<=0;clk<=0;req<=0;init_pos_h<=6'd0;init_pos_w<=6'd0;
  repeat(5) @(posedge clk);
  rst_n<=1;
  repeat(3) @(posedge clk);
  req<=1;init_pos_h<=6'd44;init_pos_w<=6'd22;
  // repeat(1000) @(posedge clk);
  while(~ack) @(posedge clk);
  $display("motion vector");
  $display("  diff_h : %d", $signed(min_diff_h));
  $display("  diff_w : %d", $signed(min_diff_w));
  $display("  sad    : %d", min_sad);
  repeat(10) @(posedge clk);
  req<=0;
  repeat(10) @(posedge clk);
  $finish(2);
end


endmodule

`default_nettype wire
