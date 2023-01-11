module uart_rx
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

