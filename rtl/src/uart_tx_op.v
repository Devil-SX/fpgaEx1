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

  always@(negedge resetn_i) begin
		uart_tx_o <= 1'b1;
		uart_busy_o <= 1'b0;
  end
	
	localparam IDLE = 3'd0;
	localparam START = 3'd1;
	localparam IDLE = 3'd2;
	localparam IDLE = 3'd3;
	localparam IDLE = 3'd4;
  always@(posedge clk_i or negedge resetn_i) begin
    if(!resetn_i) begin
    end 
    else begin
    end
  end

endmodule

