/*
 * @Author: Devil-SX 987249586@qq.com
 * @Date: 2023-02-26 11:20:05
 * @LastEditors: Devil-SX 987249586@qq.com
 * @LastEditTime: 2023-02-26 11:20:11
 * @Description: 
 * 
 * Copyright (c) 2023 by ${git_name_email}, All Rights Reserved. 
 */
module clk_divider
  #(parameter DIVISOR = 6'd0)   
   (
    input      clk_i,
    input      resetn_i,
    output reg clk_en_o
    );

   reg [5:0]   clk_dividor = 0;   

   // clk divider
   always @ ( posedge clk_i or negedge resetn_i ) begin
      if(!resetn_i)begin
         /*AUTORESET*/
         // Beginning of autoreset for uninitialized flops
         clk_dividor <= 6'h0;
         clk_en_o <= 1'h0;
         // End of automatics
      end else begin
         if (clk_dividor != DIVISOR) begin
            clk_dividor <= clk_dividor + 1'b1;
            clk_en_o <= 1'b0;
         end else begin
            clk_dividor <= 6'h0;
            clk_en_o <= 1'b1;
         end
      end      
   end
endmodule

