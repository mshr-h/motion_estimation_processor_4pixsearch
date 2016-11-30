module fpga_top
(
  input  wire       RSTN,
  input  wire       clk_sys,
  input  wire       clk,
  input  wire       SW4N,
  input  wire       SW5N,
  output wire [7:0] SEG_A,
  output wire [7:0] SEG_B,
  output wire [7:0] SEG_C,
  output wire [7:0] SEG_D,
  output wire [7:0] SEG_E,
  output wire [7:0] SEG_F,
  output wire [7:0] SEG_G,
  output wire [7:0] SEG_H,
  output wire [8:0] SEG_SEL_IK
);

localparam MEM_SW_A = "../memory_sw_A.mif";
localparam MEM_SW_B = "../memory_sw_B.mif";
localparam MEM_SW_C = "../memory_sw_C.mif";
localparam MEM_SW_D = "../memory_sw_D.mif";
localparam MEM_TB_A = "../memory_tb_A.mif";
localparam MEM_TB_B = "../memory_tb_B.mif";
localparam MEM_TB_C = "../memory_tb_C.mif";
localparam MEM_TB_D = "../memory_tb_D.mif";

reg         req;
wire [15:0] min_sad;
wire [11:0] min_mvec;
wire        ack;

wire [31:0] pel_sw_d;
wire [31:0] pel_tb_d;
wire [7:0]  pel_sw_i;
wire [7:0]  pel_tb_i;
wire [9:0]  addr_sw_d;
wire [5:0]  addr_tb_d;
wire [11:0] addr_sw_i;
wire [7:0]  addr_tb_i;

// detect falling edge
reg [1:0] ff_sw4 = 0;
reg [1:0] ff_sw5 = 0;
always @(posedge clk) begin
  ff_sw4 <= {ff_sw4[0], SW4N};
  ff_sw5 <= {ff_sw5[0], SW5N};
end
wire tri_sw4 = (ff_sw4 == 2'b10);
wire tri_sw5 = (ff_sw5 == 2'b10);

always @(posedge clk or negedge RSTN) begin
  if(~RSTN)
    req <= 0;
  else if(tri_sw4)
    req <= 1;
  else if(tri_sw5)
    req <= 0;
end

me_top _me_top
(
  .rst_n    ( RSTN     ) ,
  .clk      ( clk      ) ,
  .req      ( req      ) ,
  .min_sad  ( min_sad  ) ,
  .min_mvec ( min_mvec ) ,
  .ack      ( ack      ) ,

  // memory access ports
  .pel_sw_d  ( pel_sw_d  ) ,
  .pel_tb_d  ( pel_tb_d  ) ,
  .addr_sw_d ( addr_sw_d ) ,
  .addr_tb_d ( addr_tb_d ) ,
  .pel_sw_i  ( pel_sw_i  ) ,
  .pel_tb_i  ( pel_tb_i  ) ,
  .addr_sw_i ( addr_sw_i ) ,
  .addr_tb_i ( addr_tb_i )
);

memory_sw
_memory_sw
(
  .rst_n  ( RSTN      ) ,
  .clk    ( clk       ) ,
  .addr_a ( addr_sw_d ) ,
  .addr_b ( addr_sw_i ) ,
  .data_a ( pel_sw_d  ) ,
  .data_b ( pel_sw_i  )
);
defparam _memory_sw.MEM_SW_A = MEM_SW_A;
defparam _memory_sw.MEM_SW_B = MEM_SW_B;
defparam _memory_sw.MEM_SW_C = MEM_SW_C;
defparam _memory_sw.MEM_SW_D = MEM_SW_D;

memory_tb
_memory_tb
(
  .rst_n  ( RSTN      ) ,
  .clk    ( clk       ) ,
  .addr_a ( addr_tb_d ) ,
  .addr_b ( addr_tb_i ) ,
  .data_a ( pel_tb_d  ) ,
  .data_b ( pel_tb_i  )
);
defparam _memory_tb.MEM_TB_A = MEM_TB_A;
defparam _memory_tb.MEM_TB_B = MEM_TB_B;
defparam _memory_tb.MEM_TB_C = MEM_TB_C;
defparam _memory_tb.MEM_TB_D = MEM_TB_D;

/* 7SEG LED
+--------+--------+--------+--------+
| data0  | data1  | data2  | data3  |
+--------+--------+--------+--------+
| data4  | data5  | data6  | data7  |
+--------+--------+--------+--------+
| data8  | data9  | data10 | data11 |
+--------+--------+--------+--------+
| data12 | data13 | data14 | data15 |
+--------+--------+--------+--------+
*/

displayIK_7seg_16
_displayIK_7seg_16
(
  .RSTN    ( RSTN       ),
  .CLK     ( clk_sys    ),
  .data0   ( {3'h0,  clk, 3'h0, RSTN, 8'h00} ),
  .data1   ( {3'h0, SW4N, 3'h0, SW5N, 3'h0, req, 3'h0, ack} ),
  .data2   ( 0          ),
  .data3   ( 0          ),
  .data4   ( min_sad    ),
  .data5   ( min_mvec   ),
  .data6   ( 0          ),
  .data7   ( 0          ),
  .data8   ( 0          ),
  .data9   ( 0          ),
  .data10  ( 0          ),
  .data11  ( 0          ),
  .data12  ( 0          ),
  .data13  ( 0          ),
  .data14  ( 0          ),
  .data15  ( 0          ),
  .SEG_A   ( SEG_A      ),
  .SEG_B   ( SEG_B      ),
  .SEG_C   ( SEG_C      ),
  .SEG_D   ( SEG_D      ),
  .SEG_E   ( SEG_E      ),
  .SEG_F   ( SEG_F      ),
  .SEG_G   ( SEG_G      ),
  .SEG_H   ( SEG_H      ),
  .SEG_SEL ( SEG_SEL_IK )
);

endmodule
