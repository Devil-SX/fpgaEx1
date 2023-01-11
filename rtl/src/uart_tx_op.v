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
