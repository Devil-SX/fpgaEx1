module uart_tx_op
  #(
    parameter VERIFY_ON = 1'b0,
    parameter VERIFY_EVEN = 1'b0
    )
   (
    input       clk_i,
    input       resetn_i,
    input       clk_en_i, 
    input [7:0] datain_i,
    input       shoot_i,
    output reg  uart_tx_o = 1'b1,
    output reg  uart_busy_o
    );

  // Defines
  localparam IDLE_BIT = 1'b1;
  localparam SHOOT_SET = 1'b1;
  localparam BUSY_SET = 1'b1;
  // States
  localparam IDLE = 3'd0;
  localparam START = 3'd1;
  localparam DATA = 3'd2;
  localparam CHECK = 3'd3;
  localparam END_BIT = 3'd4;

  
  //* clk_i domain
  reg shoot_flag;
  reg[7:0] datain;

  always@(posedge clk_i or negedge resetn_i) begin
    if(!resetn_i) begin
      shoot_flag <= ~SHOOT_SET;
      uart_busy_o <= ~BUSY_SET;
      datain <= 8'b0;
    end
    else begin
      if(uart_busy_o != BUSY_SET && shoot_i == SHOOT_SET) begin // Sampling
        shoot_flag <= shoot_i;
        uart_busy_o <= BUSY_SET;
        datain <= datain_i; // Sampling
      end
    end
  end


  //* clk_en_i domain
  // 三段式状态机
  reg[2:0] state;
  reg[2:0] next_state;
  reg[2:0] bit_sel;

  always@(posedge clk_en_i or negedge resetn_i) begin
    if(!resetn_i) begin
      state <= IDLE;
      next_state <= IDLE;
    end
    else begin
      state <= next_state;
    end
  end


  always@(*) begin
    case (state)
      IDLE: begin
        if(shoot_flag == SHOOT_SET) begin
          next_state = START;
          shoot_flag = ~SHOOT_SET;
        end
      end

      START: begin
        next_state = DATA;
      end

      DATA: begin
        if(bit_sel == 3'd7) begin
          if(VERIFY_ON) begin
            next_state = CHECK;
          end else begin
            next_state = END_BIT;
          end
        end else begin
          next_state = DATA;
        end
      end

      CHECK: begin
        next_state = END_BIT;
      end

      END_BIT: begin
        next_state = IDLE;
      end

      default: begin
        next_state = IDLE;
      end
    endcase
  end


  always@(posedge clk_en_i or negedge resetn_i) begin
    if(!resetn_i) begin
      bit_sel <= 3'b0;    
      uart_tx_o <= IDLE_BIT;
      uart_busy_o <= ~BUSY_SET;
    end
    else begin
      case (state)
        IDLE: begin
          bit_sel <= 3'b0;
          uart_tx_o <= IDLE_BIT;
          // uart_busy_o <= ~BUSY_SET; // 这个在clk_i域里面
        end

        START: begin
          uart_tx_o <= ~IDLE_BIT;
        end

        DATA: begin
          uart_tx_o <= datain[bit_sel];
          bit_sel <= bit_sel + 1;
        end

        CHECK: begin
          if(VERIFY_EVEN)
            uart_tx_o <= ^datain;
          else
            uart_tx_o <= ~^datain;
        end

        END_BIT: begin
          uart_tx_o <= ~IDLE_BIT;
          uart_busy_o <= ~BUSY_SET;
        end

        default: begin
          uart_tx_o <= IDLE_BIT;
        end
      endcase
    end
  end
endmodule
