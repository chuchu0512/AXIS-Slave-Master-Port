`timescale 1ns / 1ps
module slave#(
parameter data_width = 32,
parameter trans_width = 4,
parameter trans_lenth = 2**trans_width
)
(
input clk,
input rst,
//===== axis slave =====//
input [data_width - 1:0] s_data,
input s_valid,
output reg s_ready,
//===== control =====//
input en
    );
    //===== memory =====//
    integer i ;
    reg [data_width - 1:0] s_reg [trans_lenth - 1:0] ;
    //===== state =====//
    localparam IDLE = 1'b0 ;
    localparam IN   = 1'b1 ;
    reg cs, ns ;
    reg [trans_width - 1:0] cnt ;
    
    always@(posedge clk)begin
        if(!rst) cs <= IDLE ;
        else cs <= ns ;
    end
    
    always@(*)begin
        case(cs)
            IDLE:begin
                if(en == 1) ns = IN ;
                else ns = IDLE ;
            end
            IN:begin
                if(cnt == trans_lenth - 1) ns = IDLE ;
                else ns = IN ;
            end
            default:ns = IDLE ;
        endcase
    end
    
    //===== cnt =====//
    always@(posedge clk)begin
        if(!rst) cnt <= 0 ;
        else begin
            case(cs)
                IN:begin
                    if(s_ready == 1 && s_valid == 1) cnt <= cnt + 1 ;
                    else cnt <= cnt ;
                end
                default: cnt <= 0 ;
            endcase
        end
    end
    
    //===== s_ready =====//
    always@(posedge clk)begin
        if(!rst) s_ready <= 0 ;
        else begin
            case(cs)
                IN:begin
                    if(cnt == trans_lenth - 1) s_ready <= 0 ;
                    else s_ready <= 1 ;
                end
                default: s_ready <= 0 ;
            endcase
        end
    end
    
    //===== s_data =====//
    always@(posedge clk)begin
        if(!rst)begin
            for(i=0; i<trans_lenth; i=i+1)begin
                s_reg[i] <= 0 ;
            end
        end
        else begin
            case(cs)
                IN:begin
                    if(s_ready == 1 && s_valid == 1) s_reg[cnt] <= s_data ;
                    else s_reg[cnt] <= s_reg[cnt] ;
                end
                default:begin
                    for(i=0; i<trans_lenth; i=i+1)begin
                        s_reg[i] <= 0 ;
                    end
                end
            endcase
        end
    end
    
endmodule
