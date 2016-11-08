`include "./memory_dual_port.v"
`include "../rtl/addr_gen.v"
`include "../rtl/control_double.v"
`include "../rtl/memory_sw.v"
`include "../rtl/memory_tb.v"
`include "../rtl/pe.v"
`include "../rtl/pe_line.v"
`include "../rtl/shift_register.v"
`include "../rtl/sum.v"
`include "../rtl/pe_array.v"
`include "../rtl/pa_array.v"
`include "../rtl/me_double.v"

`default_nettype none

module tb_me_double;

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
wire [15:0] min_sad;
wire [4:0]  min_mvec_h;
wire [4:0]  min_mvec_w;
wire        ack;
wire [31:0] pel_sw;
wire [31:0] pel_tb;
wire [9:0]  addr_sw;
wire [5:0]  addr_tb;

me_double _me_double
(
  .rst_n    ( rst_n                    ) ,
  .clk      ( clk                      ) ,
  .req      ( req                      ) ,
  .min_sad  ( min_sad                  ) ,
  .min_mvec ( {min_mvec_w, min_mvec_h} ) ,
  .ack      ( ack                      ) ,

  // memory access ports
  .pel_sw   ( pel_sw   ) ,
  .pel_tb   ( pel_tb   ) ,
  .addr_sw  ( addr_sw  ) ,
  .addr_tb  ( addr_tb  )
);

memory_sw
_memory_sw
(
  .rst_n  ( rst_n   ) ,
  .clk    ( clk     ) ,
  .addr_a ( addr_sw ) ,
  .addr_b ( 12'd0   ) ,
  .data_a ( pel_sw  ) ,
  .data_b (         )
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
  .addr_a ( addr_tb ) ,
  .addr_b ( 8'd0    ) ,
  .data_a ( pel_tb  ) ,
  .data_b (         )
);
defparam _memory_tb.MEM_TB_A = MEM_TB_A;
defparam _memory_tb.MEM_TB_B = MEM_TB_B;
defparam _memory_tb.MEM_TB_C = MEM_TB_C;
defparam _memory_tb.MEM_TB_D = MEM_TB_D;


localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) clk = ~clk;

initial begin
  $dumpfile("tb_me_double.vcd");
  $dumpvars(0, tb_me_double);
end

initial begin
  #1 rst_n<=1'bx;clk<=1'bx;req<=1'bx;
  #(CLK_PERIOD) rst_n<=1;
  #(CLK_PERIOD*3) rst_n<=0;clk<=0;req<=0;
  repeat(5) @(posedge clk);
  rst_n<=1;
  repeat(3) @(posedge clk);
  req<=1;
  while(~ack) @(posedge clk);
  $display("motion vector");
  $display("  h  : %d", min_mvec_h);
  $display("  w  : %d", min_mvec_w);
  $display("  sad: %d", min_sad);
  repeat(10) @(posedge clk);
  req<=0;
  repeat(10) @(posedge clk);
  $finish(2);
end


endmodule

`default_nettype wire
