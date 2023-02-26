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
    input                         reset,
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

endmodule