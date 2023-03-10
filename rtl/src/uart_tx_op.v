/*
 * @Author: Devil-SX 987249586@qq.com
 * @Date: 2023-02-22 15:22:09
 * @LastEditors: Devil-SX 987249586@qq.com
 * @LastEditTime: 2023-02-26 21:13:40
 * @Description: UART 发射模块
  1.单state和state_cur/state_next的选择：前者少一个时钟周期时延，后者代码结构可以写得更加清晰（三段式状态机）。这里选择前者简化设计思路。
  2.Moore和Mealy的选择：很显然输出和输入相关,但用if-case语句描述后，很难分清Mealy和Moore了。
 * Copyright (c) 2023 by Devil-SX, All Rights Reserved. 
 */
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
        datain <= datain_i;
      end
    end
  end


  //* clk_en_i domain
  // State Machine
  reg[2:0] state;
  reg[2:0] bit_sel;

  always@(posedge clk_en_i or negedge resetn_i) begin
    if(!resetn_i) begin
      state <= IDLE;
      bit_sel <= 3'b0;    
      uart_tx_o <= IDLE_BIT;
    end
    else begin
      case (state)
        IDLE: begin
          uart_tx_o <= IDLE_BIT;
          if(shoot_flag == SHOOT_SET) begin
            shoot_flag <= ~SHOOT_SET;
            state <= START;
          end else
            uart_busy_o <= ~BUSY_SET;
        end

        START:  begin
          uart_tx_o <= ~IDLE_BIT;
          state <= DATA;
        end

        DATA: begin
          uart_tx_o <= datain[bit_sel];
          if(bit_sel == 3'd7) begin
            bit_sel <= 3'd0;
            if(VERIFY_ON)
              state <= CHECK;
            else
              state <= END_BIT;
          end else
            bit_sel <= bit_sel + 1;
        end

        CHECK: begin
          if(VERIFY_EVEN)
            uart_tx_o <= ^datain;
          else
            uart_tx_o <= ~^datain;
          state <= END_BIT;
        end

        END_BIT: begin
          uart_tx_o <= ~IDLE_BIT;
          state <= IDLE;
        end
      endcase
    end
  end
endmodule
