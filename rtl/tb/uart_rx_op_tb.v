`timescale 1ns/1ps
module uart_rx_op_tb (
  
);

// reg类型（一般）是本级模块控制的信号
reg clk;
reg resetn;
wire clk_en;
reg uart_rx;
wire [7:0] dataout;
wire dataout_valid;


uart_rx_op #(
  .VERIFY_ON(1'b1),
  .VERIFY_EVEN(1'b1)
) uart_rx_op_1(
  .clk_i(clk),
  .resetn_i(resetn),
  .clk_en_i(clk_en),
  .uart_rx_i(uart_rx),
  .dataout_o(dataout),
  .dataout_valid_o(dataout_valid)
);

clk_divider #(
  .DIVISOR(7) // 8 分频
) clk_divider_1(
  .clk_i(clk),
  .resetn_i(resetn),
  .clk_en_o(clk_en)
);

initial begin
  resetn = 1'b0;
  #10 resetn = 1'b1;
end

initial begin
  clk = 1'b0;
  forever begin
    #5 clk = ~clk;
  end
end

// 8 分频后, clk_en 半周期 = #5*8 = #40
initial begin
  uart_rx = 1'b1;
  #10 uart_rx = 1'b1;
  #80 uart_rx = 1'b0;
  // 传一个00001111+00（正确偶校验）
  #80 uart_rx = 1'b0;
  #80 uart_rx = 1'b0;
  #80 uart_rx = 1'b0;
  #80 uart_rx = 1'b0;
  #80 uart_rx = 1'b1;
  #80 uart_rx = 1'b1;
  #80 uart_rx = 1'b1;
  #80 uart_rx = 1'b1;
  #80 uart_rx = 1'b0;
  #80 uart_rx = 1'b0;
  // 传一个00001111+10（错误偶校验）
  #80 uart_rx = 1'b0;
  #80 uart_rx = 1'b0;
  #80 uart_rx = 1'b0;
  #80 uart_rx = 1'b0;
  #80 uart_rx = 1'b1;
  #80 uart_rx = 1'b1;
  #80 uart_rx = 1'b1;
  #80 uart_rx = 1'b1;
  #80 uart_rx = 1'b1;
  #80 uart_rx = 1'b0;

  #80 uart_rx = 1'b1;
end

initial begin
  #2200 $finish;
end

endmodule