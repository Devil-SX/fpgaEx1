/*
 * @Author: Devil-SX 987249586@qq.com
 * @Date: 2023-03-02 16:22:44
 * @LastEditors: Devil-SX 987249586@qq.com
 * @LastEditTime: 2023-03-04 16:39:25
 * @Description: 多输出FIFO，支持一次读取多位
 内部使用循环表结构存储，用头指针fifo_head和尾的下一位指针fifo_tail_next表示存储数据
 当fifo_head=fifo_tail_next表要么满要么空，为了区分满和空，FIFO中有一位禁止储存数据
 则fifo_head=fifo_tail_next为空
 * Copyright (c) 2023 by Devil-SX, All Rights Reserved. 
 */
module fifo_mo 
#(
  parameter OUTCUT = 1,
  parameter FIFO_LENGTH = 100
)
(
  input                        clk,
  input                       resetn,
  input                       enable,

  input [7:0]                 data_i,
  input                       w_en,
  input                       r_en,
  input [5:0]                 r_count,  // Max for 63 Outputs
  output reg[OUTCUT*8-1:0]    data_o, // Low byte for the oldset data

  output                      full=1'b0,
);

localparam BYTE = 8;
localparam FIFO_COUNTER_LENGTH = $log2(FIFO_LENGTH) + 3;  // 3 to prevent overflowing
localparam FULL_SET = 1'b1;

reg[FIFO_LENGTH*BYTE-1:0] fifo;
reg[FIFO_COUNTER_LENGTH-1:0] fifo_head; // Unit by Bytes, Range [FIFO_LENGTH-1]
reg[FIFO_COUNTER_LENGTH-1:0] fifo_tail_next; // Unit by Bytes, Range [FIFO_LENGTH-1]

wire[FIFO_COUNTER_LENGTH-1:0] length;
assign length = (fifo_tail_next >= fifo_head)? 
  (fifo_tail_next - fifo_head): 
  (FIFO_LENGTH - fifo_head + fifo_tail_next);

assign full = (length == FIFO_LENGTH - 1)?FULL_SET:~FULL_SET;

// Output Logic
always @(*) begin
  // if fifo_head + OUTCUT - 1 > FIFO_LENGTH - 1
  if(fifo_head>FIFO_LENGTH - OUTCUT)
    data_o = {fifo[(OUTCUT-FIFO_LENGTH+fifo_head)*BYTE-1:0],fifo[FIFO_LENGTH*BYTE-1:fifo_head*BYTE]};
  else
    data_o = fifo[(fifo_head+OUTCUT)*BYTE-1,fifo_head*BYTE];
  if(length<OUTCUT)
    data_o = {((OUTCUT-length)*BYTE)'b0,(length*BYTE)'b1} & data_o;
end


//* Write Domain
always @(posedge clk or negedge resetn) begin
  if (!resetn) begin
    fifo <= 0;
    fifo_tail_next <= 0;
  end else if(enable && w_en) begin
    if(!full) begin
      fifo[fifo_tail_next*BYTE+7:fifo_tail_next*BYTE] <= rx_data;
      fifo_tail_next <= fifo_tail_next + 1;
      if(fifo_tail_next > FIFO_LENGTH -1)
        fifo_tail_next <= 0;
    end
  end
end


//* Read Domain
always @(posedge clk or negedge resetn) begin
  if(!resetn) begin
    fifo_head <= 0;
  end else if(enable && r_en) begin
    if(length >= r_count) begin
      fifo_head = fifo_head + length;
      if(fifo_head > FIFO_LENGTH -1)
        fifo_head = fifo_head - FIFO_LENGTH;
    end
  end
end

endmodule //fifo_mo