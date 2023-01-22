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

  always@(negedge resetn_i) begin
		dataout_valid_o <= 1'b0;
		dataout_o <= 8'b0;
  end

	// state machine
	localparam IDLE = 3'd0;
	localparam DATA = 3'd1;
	localparam CHECK = 3'd2;
	localparam END = 3'd3;

  reg[2:0] state;
	reg[2:0] count;
	reg check_flag;

  always@(posedge clk_en_i or negedge resetn_i) begin
    if(!resetn_i) begin
			state <= 3'd0;
			count <= 3'd0;
			check_flag <= 1'b0;
    end 
    else begin
			case(state)
				IDLE:	if(!uart_rx_i) state <= DATA;
				DATA:	
					begin
						dataout_o[count] <= uart_rx_i;
						if(count == 3'd7) begin
							if(VERIFY_ON) state <= CHECK;
							else begin
								state<= END;
								dataout_valid_o <= 1'b1;
							end
						end else
							count <= count + 1;
					end
				CHECK:	
					begin
						check_flag <= ^dataout_o;
						if(check_flag != VERIFY_EVEN) dataout_valid_o <= 1'b1;
						else dataout_valid_o <= 1'b0;
						state <= END;
					end
				END:
					begin
						dataout_valid_o <= 1'b0;
						state <= IDLE;
					end
				default:
			endcase
		end
  end


	
	endmodule
