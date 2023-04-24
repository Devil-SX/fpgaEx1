`timescale 1ns/1ps
module uart_tx_op_tb (
  
);

// reg类型（一般）是本级模块控制的信号
reg clk;
reg resetn;
wire clk_en;
reg[7:0] datain;
reg shoot;
wire uart_tx;
wire uart_busy;


uart_tx_op #(
  .VERIFY_ON(1'b1),
  .VERIFY_EVEN(1'b1)
) uart_tx_op_1(
  .clk_i(clk),
  .resetn_i(resetn),
  .clk_en_i(clk_en),
  .datain_i(datain),
  .shoot_i(shoot),
  .uart_tx_o(uart_tx),
  .uart_busy_o(uart_busy)
);


clk_divider #(
  .DIVISOR(7)
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
  shoot = 1'b0;
  datain = 8'b00000000;
  #20 shoot = 1'b1;
  datain = 8'b01001111;
  #10 shoot = 1'b0;
end

initial begin
  $dumpfile("./wave/uart_tx_op_tb.vcd");
  $dumpvars(1, uart_tx_op_tb);
  #2000 $finish;
end

endmodule