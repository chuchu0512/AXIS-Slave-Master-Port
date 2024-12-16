`timescale 1ns / 1ps

module tb_master#(
parameter data_width = 4,
parameter trans_width = 8,
parameter trans_lenth = 2**trans_width
)(
output reg clk,
output reg rst,
input [data_width - 1:0] m_data,
input m_valid,
input m_tlast,
output reg m_ready,
output reg en
    );
    // module connection
    master #(.data_width(data_width), .trans_width(trans_width), .trans_lenth(trans_lenth))
    m1(.clk(clk), .rst(rst), .m_data(m_data), .m_valid(m_valid), .m_tlast(m_tlast), .m_ready(m_ready), .en(en)) ;
    
    //clk
    localparam cycle = 20 ;
    always #(cycle/2) clk = ~clk ;
    
    integer i ;
    initial clk = 0 ;
    initial rst = 0 ;
    initial m_ready = 0 ;
    initial i = 0 ;
    
    initial begin
        #(5*cycle) ;
        rst = 1 ;
        #(5*cycle) ;
        en = 1 ;
        #(5*cycle) ;
        en = 0 ;
        m_ready = 1 ;
        #(trans_lenth*cycle) ;
        #(5*cycle) ;
        rst = 0 ;
        #(5*cycle) ;
        $finish ;
    end
endmodule
