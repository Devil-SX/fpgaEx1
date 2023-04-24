module uart_rx_op
  #(
    parameter VERIFY_ON = 1'b0,
    parameter VERIFY_EVEN = 1'b0
    )
   (
    input            clk_i,
    input            clk_en_i,
    input            resetn_i,
    input            uart_rx_i,
    output reg       dataout_valid_o,
    output reg [7:0] dataout_o 
    );
  
  // Defines
  localparam IDLE_BIT = 1'b1;
  localparam VALID_SET = 1'b1;
  localparam DEFALUT_OUT = 8'b0;
  // State
  localparam IDLE = 3'd0;
  localparam DATA = 3'd1;
  localparam CHECK = 3'd2;
  localparam END_BIT = 3'd3;


  // clk_en_i domain
  // 三段式状态机, 每增加一级时序逻辑, 需要增加一个时钟周期
  reg[2:0] state;
  reg[2:0] next_state;
  reg[2:0] bit_sel;
  reg[7:0] data;
  reg check_temp;
  reg valid_flag;


  always @(posedge clk_en_i or negedge resetn_i) begin
    if(!resetn_i) begin
      state <= IDLE;
      next_state <= IDLE;
    else begin
      state <= next_state;
    end
  end

  always @(*) begin
    case (state)
      IDLE: begin
        if(uart_rx_i != IDLE_BIT) begin
          next_state = DATA;
        end
      end

      DATA: begin
        if(bit_sel == 3'd7) begin
          if(VERIFY_ON) begin
            next_state = CHECK;
          end else begin
            next_state = END_BIT;
          end
        end
      end

      CHECK: begin
        next_state = END_BIT;
      end

      END_BIT: begin
        next_state = IDLE;
      end
      default: begin
      end
    endcase
  end


  // 使用时序逻辑输出，减少毛刺
  always @(posedge clk_en_i or negedge resetn_i) begin
    if(!resetn_i) begin
      bit_sel <= 3'b0;
      data <= DEFALUT_OUT;
      check_temp <= ~VERIFY_EVEN;
      valid_flag <= ~VALID_SET;
    end else begin
      case (state)
        IDLE: begin
          bit_sel <= 3'b0;
          data <= DEFALUT_OUT;
          check_temp <= ~VERIFY_EVEN;
          valid_flag <= ~VALID_SET;
        end

        DATA: begin
          data[bit_sel] <= uart_rx_i;
          bit_sel <= bit_sel + 1;
        end

        CHECK: begin
          check_temp <= (^data) ^ uart_rx_i;
        end

        END_BIT: begin
          if((VERIFY_EVEN && check_temp == 1'b0) ||
              (!VERIFY_EVEN && check_temp == 1'b1)
          ) begin
            valid_flag <= VALID_SET;
          end
        end
        default: begin
        end
      endcase
    end
  end


  // clk_i domain
  // 发出一个时钟周期的有效信号
  always @(posedge clk or negedge resetn_i) begin
    if(!resetn_i) begin
      dataout_valid_o <= ~VALID_SET;
      valid_flag <= ~VALID_SET;
    end else begin
      if(valid_flag == VALID_SET) begin
        dataout_valid_o <= VALID_SET;
        valid_flag <= ~VALID_SET;
      end else
        dataout_valid_o <= ~VALID_SET;
    end
  end

endmodule
