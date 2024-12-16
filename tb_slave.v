`timescale 1ns / 1ps
module tb_slave#(
parameter data_width = 32,
parameter trans_width = 4,
parameter trans_lenth = 2**trans_width
)(
output reg clk,
output reg rst,
output reg [data_width - 1:0] s_data,
output reg s_valid,
input s_ready,
output reg en
    );
    // module connection
    slave #(.data_width(data_width), .trans_width(trans_width), .trans_lenth(trans_lenth))
    m0(.clk(clk), .rst(rst), .s_data(s_data), .s_valid(s_valid), .s_ready(s_ready), .en(en)) ;
    
    // clk
    localparam cycle = 20 ;
    always #(cycle/2) clk = ~clk ;
    
    integer i ;
    initial clk = 0 ;
    initial rst = 0 ;
    initial s_valid = 0 ;
    initial s_data = 0 ;
    initial i = 0 ;
    
    initial begin
        #(5*cycle) ;
        rst = 1 ;
        #(5*cycle) ;
        en = 1 ;
        #(5*cycle) ;
        en = 0 ;
        s_valid = 1 ;
        repeat(trans_lenth)begin
            @(negedge clk) s_data = i ;
            @(posedge clk) i=i+1 ;
        end
        @(negedge clk) s_data = 0 ;
        #(5*cycle) ;
        rst = 0 ;
        #(5*cycle) ;
        $finish ;
    end
endmodule
