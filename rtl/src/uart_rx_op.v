/*
 * @Author: Devil-SX 987249586@qq.com
 * @Date: 2023-02-26 11:25:43
 * @LastEditors: Devil-SX 987249586@qq.com
 * @LastEditTime: 2023-03-02 11:27:45
 * @Description: UART 接收模块
  1.单state和state_cur/state_next的选择：前者少一个时钟周期时延，后者代码结构可以写得更加清晰（三段式状态机）。这里选择前者简化设计思路。
  2.Moore和Mealy的选择：很显然输出和输入相关,但用if-case语句描述后，很难分清Mealy和Moore了。
 * Copyright (c) 2023 by Devil-SX, All Rights Reserved. 
 */

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

  //* clk_en_i domain
  // State Machine
  reg[2:0] state;
  reg[2:0] bit_sel;
  reg[7:0] data;
  reg check_temp;
  reg valid_flag;

  always@(posedge clk_en_i or negedge resetn_i) begin
    if(!resetn_i) begin
      state <= IDLE;
      dataout_o <= DEFALUT_OUT; 
      bit_sel <= 3'd0;
      check_temp <= 1'b0;
    end 
    else begin
      case(state)
        IDLE:	
          if(uart_rx_i!=IDLE_BIT) begin
            dataout_o <= DEFALUT_OUT;
            state <= DATA;
          end

        DATA:	begin
            data[bit_sel] <= uart_rx_i;
            if(bit_sel == 3'd7) begin
              bit_sel <= 3'd0;
              if(VERIFY_ON) 
                state <= CHECK;
              else 
                valid_flag <= VALID_SET;
                dataout_o <= data;
                state<= END_BIT;
            end else
              count <= count + 1;
          end

        CHECK: begin
            check <= ^data;
            if(check != VERIFY_EVEN) begin
              valid_flag <= VALID_SET;
              dataout_o <= data;
            end
            else valid_flag <= ~VALID_SET;
            state <= END_BIT;
          end

        END_BIT: begin
            state <= IDLE;
          end
        default:
      endcase
    end
  end


  //* clk_i domain
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

endmodule
