module control_double
(
  input  wire        rst_n,
  input  wire        clk,
  input  wire        req,
  input  wire [15:0] sad,
  output wire        clr,
  output wire        en_addr_sw,
  output wire        en_addr_tb,
  output wire        en_paarray_sw,
  output reg         en_paarray_tb,
  output reg  [15:0] min_sad,
  output reg  [9:0]  min_mvec, // {w, h}
  output wire        ack
);

localparam TB_LENGTH = 8;
localparam SW_LENGTH = 32;

localparam INIT             = 4'b0000;
localparam WAIT_REQ         = 4'b0001;
localparam RUNNING          = 4'b0010;
localparam WAIT_REQ_FALL    = 4'b0011;
localparam WAIT_RUN         = 4'b0100;
localparam ACTIVE           = 4'b0101;
localparam DONE             = 4'b0110;
localparam WAIT_DUMMY_CYCLE = 4'b0111;
localparam WAIT_SRCH_END    = 4'b1000;
localparam DONE_CNT         = 4'b1001;
localparam DONE_ACTIVE      = 4'b1010;

localparam CNT_ADDR_SW_END    = SW_LENGTH**2-2;
localparam CNT_ADDR_TB_END    = TB_LENGTH**2-1;
localparam CNT_PEARRAY_SW_END = SW_LENGTH**2+(SW_LENGTH-TB_LENGTH-1);
localparam CNT_DUMMY_CYCLE    = SW_LENGTH-TB_LENGTH+7;
localparam VEC_WIDTH          = $clog2(SW_LENGTH+1);

localparam MAX_SAD = 16'hFFFF;

reg [3:0]  state_main;
reg [3:0]  state_addr_sw;
reg [12:0] cnt_addr_sw;
reg [3:0]  state_addr_tb;
reg [8:0]  cnt_addr_tb;
reg [3:0]  state_pearray_sw;
reg [12:0] cnt_pearray_sw;
reg [3:0]  state_valid;
reg [10:0] cnt_dummy;
reg [5:0]  cnt_x;
reg [5:0]  cnt_y;
reg [3:0]  state_done;
reg        cnt_done;

assign ack           = (state_main == WAIT_REQ_FALL);
assign clr           = (state_main == WAIT_REQ);
assign en_addr_sw    = (cnt_addr_sw != 0);
assign en_addr_tb    = (cnt_addr_tb != 0);
assign en_paarray_sw = (cnt_pearray_sw != 0);
wire   valid         = (cnt_x > (TB_LENGTH-2)) && (cnt_y > (TB_LENGTH-2));
wire   done          = (state_done == DONE_ACTIVE);

// FSM main
always @(posedge clk or negedge rst_n) begin
  if(~rst_n) begin
    state_main <= INIT;
  end else begin
    case(state_main)
      INIT          :          state_main <= #1 WAIT_REQ;
      WAIT_REQ      : if( req) state_main <= #1 RUNNING;
      RUNNING       : if(done) state_main <= #1 WAIT_REQ_FALL;
      WAIT_REQ_FALL : if(~req) state_main <= #1 WAIT_REQ;
      default       :          state_main <= 'dx;
    endcase
  end
end

// addr_sw
always @(posedge clk or negedge rst_n) begin
  if (~rst_n) begin
    state_addr_sw <= INIT;
    cnt_addr_sw   <= 0;
  end else begin
    case(state_addr_sw)
      INIT: begin
        state_addr_sw <= #1 WAIT_RUN;
        cnt_addr_sw   <= #1 0;
      end
      WAIT_RUN: begin
        if(state_main==RUNNING)
          state_addr_sw <= #1 ACTIVE;
        cnt_addr_sw <= #1 0;
      end
      ACTIVE: begin
        if(cnt_addr_sw==CNT_ADDR_SW_END)
          state_addr_sw <= #1 DONE;
        cnt_addr_sw <= #1 cnt_addr_sw + 1;
      end
      DONE: begin
        if(state_main==WAIT_REQ_FALL)
          state_addr_sw <= #1 WAIT_RUN;
        cnt_addr_sw <= #1 0;
      end
      default: begin
        state_addr_sw <= 'dx;
        cnt_addr_sw   <= 'dx;
      end
    endcase
  end
end

// addr_tb
always @(posedge clk or negedge rst_n) begin
  if (~rst_n) begin
    state_addr_tb <= INIT;
    cnt_addr_tb   <= 0;
  end else begin
    case(state_addr_tb)
      INIT: begin
        state_addr_tb <= #1 WAIT_RUN;
        cnt_addr_tb   <= #1 0;
      end
      WAIT_RUN: begin
        if(state_main==RUNNING)
          state_addr_tb <= #1 ACTIVE;
        cnt_addr_tb <= #1 0;
      end
      ACTIVE: begin
        if(cnt_addr_tb==CNT_ADDR_TB_END)
          state_addr_tb <= #1 DONE;
        cnt_addr_tb <= #1 cnt_addr_tb + 1;
      end
      DONE: begin
        if(state_main==WAIT_REQ_FALL)
          state_addr_tb <= #1 WAIT_RUN;
        cnt_addr_tb <= #1 0;
      end
      default: begin
        state_addr_tb <= 'dx;
        cnt_addr_tb   <= 'dx;
      end
    endcase
  end
end

// pearray_sw
always @(posedge clk or negedge rst_n) begin
  if (~rst_n) begin
    state_pearray_sw <= INIT;
    cnt_pearray_sw   <= 0;
  end else begin
    case(state_pearray_sw)
      INIT: begin
        state_pearray_sw <= #1 WAIT_RUN;
        cnt_pearray_sw   <= #1 0;
      end
      WAIT_RUN: begin
        if(state_addr_sw==ACTIVE)
          state_pearray_sw <= #1 ACTIVE;
        cnt_pearray_sw <= #1 0;
      end
      ACTIVE: begin
        if(cnt_pearray_sw==CNT_PEARRAY_SW_END)
          state_pearray_sw <= #1 DONE;
        cnt_pearray_sw <= #1 cnt_pearray_sw + 1;
      end
      DONE: begin
        if(state_main==WAIT_REQ_FALL)
          state_pearray_sw <= #1 WAIT_RUN;
        cnt_pearray_sw <= #1 0;
      end
      default: begin
        state_pearray_sw <= 'dx;
        cnt_pearray_sw   <= 'dx;
      end
    endcase
  end
end

// pearray_tb
always @(posedge clk)
  en_paarray_tb <= en_addr_tb;

// valid
always @(posedge clk or negedge rst_n) begin
  if (~rst_n) begin
    state_valid <= INIT;
    cnt_dummy   <= 0;
    cnt_x       <= 0;
    cnt_y       <= 0;
  end else begin
    case(state_valid)
      INIT: begin
        state_valid <= #1 WAIT_RUN;
        cnt_dummy   <= #1 0;
      end
      WAIT_RUN: begin
        if(state_main==RUNNING)
          state_valid <= #1 WAIT_DUMMY_CYCLE;
        cnt_dummy <= #1 0;
      end
      WAIT_DUMMY_CYCLE: begin
        if(cnt_dummy==CNT_DUMMY_CYCLE)
          state_valid <= #1 ACTIVE;
        cnt_dummy <= #1 cnt_dummy + 1;
      end
      ACTIVE: begin
        if((cnt_x==(SW_LENGTH-1))&&(cnt_y==(SW_LENGTH-1)))
          state_valid <= #1 DONE;
        cnt_dummy <= #1 0;
        if(cnt_y < (SW_LENGTH-1))
          cnt_y <= #1 cnt_y + 1;
        else begin
          cnt_y <= #1 0;
          cnt_x <= #1 cnt_x + 1;
        end
      end
      DONE: begin
        if(state_main==WAIT_REQ_FALL)
          state_valid <= #1 WAIT_RUN;
        cnt_dummy <= #1 0;
        cnt_x     <= #1 0;
        cnt_y     <= #1 0;
      end
      default: begin
        state_valid <= 'dx;
        cnt_dummy   <= 'dx;
        cnt_x       <= 'dx;
        cnt_y       <= 'dx;
      end
    endcase
  end
end

// done
always @(posedge clk or negedge rst_n) begin
  if (~rst_n)begin
    state_done <= INIT;
    cnt_done   <= 0;
  end else begin
    case (state_done)
      INIT: begin
        state_done <= #1 WAIT_SRCH_END;
        cnt_done   <= #1 0;
      end
      WAIT_SRCH_END: begin
        if(cnt_x==SW_LENGTH)
          state_done <= #1 DONE_CNT;
        cnt_done <= #1 0;
      end
      DONE_CNT: begin
        if(cnt_done==1'b1)
          state_done <= #1 DONE_ACTIVE;
        cnt_done <= #1 cnt_done + 1;
      end
      DONE_ACTIVE: begin
        state_done <= #1 WAIT_SRCH_END;
        cnt_done   <= #1 0;
      end
      default: begin
        state_done <= 'dx;
        cnt_done   <= 'dx;
      end
    endcase
  end
end

// min
always @(posedge clk or negedge rst_n) begin
  if(~rst_n) begin
    min_sad  <= MAX_SAD;
    min_mvec <= 0;
  end else begin
    case(state_main)
      INIT: begin
        min_sad  <= #1 MAX_SAD;
        min_mvec <= #1 0;
      end
      WAIT_REQ: begin
        min_sad  <= #1 MAX_SAD;
        min_mvec <= #1 0;
      end
      RUNNING: begin
        if(valid && (min_sad > sad)) begin
          min_sad  <= #1 sad;
          min_mvec <= #1 {cnt_y[4:0], cnt_x[4:0]};
        end
      end
      WAIT_REQ_FALL: ;
      default:begin
        min_sad  <= 'dx;
        min_mvec <= 'dx;
      end
    endcase
  end
end

endmodule
