/*
 * @Author: Devil-SX 987249586@qq.com
 * @Date: 2023-03-02 11:01:22
 * @LastEditors: Devil-SX 987249586@qq.com
 * @LastEditTime: 2023-03-04 16:43:46
 * @Description: 
 内置一个循环FIFO
 EOFDETECTION 和 FRAMELENGTHFIXED 不能兼容，EOFDECTION优先级更高
 * Copyright (c) 2023 by Devil-SX, All Rights Reserved. 
 */
module rx_package
  #(
    parameter TOGGLE = 1'b1, //use pingpong buffer    
    parameter SOFLENGTH = 2, //sof length
    parameter SOFPATTERN = 16'hEB90,//sof pattern
    parameter EOFDETECTION = 1'b1,//eof detect or not
    parameter EOFLENGTH = 2,//eof length
    parameter EOFPATTERN = 16'h90EB,//eof pattern
    parameter FRAMELENGTHFIXED = 1'b1, //if 1,frame is fixed length
    parameter FRAMECNT = 64,//framecnt
    parameter SUB = 1'b1,//substitution
    parameter SUBPOS = 2,
    parameter SUBLENGTH = 8,//substitution length,
// if not used, leave unconnected, will gen a warning   
    parameter PICKPOS = 8,
    parameter PICKLENGTH = 3 //pick some bytes output
    )
   (
    input                         clk,
    input                         resetn,
    input                         enable,

    input                         rx_data_valid,
    input [7:0]                   rx_data, 

    input                         sub_data_valid, 
    input [SUBLENGTH*8-1:0]       sub_data,
   
    output [PICKLENGTH*4-1:0]     pick_data,
    output reg                    pick_data_valid,  
    output                        FIFO_clear,
   
    output reg [TOGGLE:0]         frame_datavld = 0, 
    output reg [7:0]              frame_data = 0,
    output reg [10:0]             frame_count = 0, 
    output reg [TOGGLE:0]         frame_interrupt = 0
    );

localparam BYTE = 8;
localparam FIFO_OUT_CUT = 8;
localparam IDLE = 2'd0;
localparam DATA = 2'd1;


// FIFO
reg[5:0] read_bytes;
reg r_en;
reg[OUTCUT*BYTE-1:0] data_o;
fifo_mo #(/*autoinstparam_value*/
        .OUTCUT                 (FIFO_OUT_CUT                              ),
        .FIFO_LENGTH            (100                            ) 
    )
  fifo(/*AutoInst*/
        .clk                    (clk                            ), //input
        .resetn                 (resetn                         ), //input
        .enable                 (enable                         ), //input
        .data_i                 (rx_data[7:0]                    ), //input
        .w_en                   (rx_data_valid                           ), //input
        .r_en                   (r_en                           ), //input
        .r_count                (read_bytes[5:0]                        ), //input
        .data_o                 (data_o[OUTCUT*BYTE-1:0]           ), //output
        .full                   (FIFO_clear                           )  //output
    );

// State Machine
// IDLE --> DATA : SOF Detection
// DATA --> ILDE : EOF Detection or FrameLength
reg state;
always @(posedge clk or negedge resetn) begin
  if(!resetn) begin
    state <= 1'b0;
    read_bytes <= 0;
  end else begin
    case (state)
      IDLE: begin
        


      default: 
    endcase

end


// SOF
reg[]

endmodule
