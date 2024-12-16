`timescale 1ns / 1ps

module master#(
parameter data_width = 32,
parameter trans_width = 4,
parameter trans_lenth = 2**trans_width
)(
input clk,
input rst,
//===== axis master =====//
output reg [data_width - 1:0] m_data,
output reg m_valid,
output reg m_tlast,
input m_ready,
//===== control =====//
input en
    );
    //===== memory =====//
    integer i ;
    reg [data_width - 1:0] m_reg [trans_lenth - 1:0] ;
    
    always@(posedge clk)begin
        if(!rst) begin
            for(i=0; i<trans_lenth; i=i+1)begin
                m_reg[i] <= i;
            end
        end
        else begin
            for(i=0; i<trans_lenth; i=i+1)begin
                m_reg[i] <= m_reg[i] ; 
            end
        end
    end
    //===== state =====//
    localparam IDLE = 1'b0 ;
    localparam OUT  = 1'b1 ;
    reg cs, ns ;
    reg [trans_width - 1:0] cnt ;
    
    always@(posedge clk)begin
        if(!rst) cs <= IDLE ;
        else cs <= ns ;
    end
    
    always@(*)begin
        case(cs)
            IDLE:begin
                if(en == 1) ns = OUT ;
                else ns = IDLE ;
            end
            OUT:begin
                if(cnt == trans_lenth - 1) ns = IDLE ;
                else ns = OUT ;
            end
            default: ns = IDLE ;
        endcase
    end
    //===== cnt =====//
    always@(posedge clk)begin
        if(!rst) cnt <= 0 ;
        else begin
            case(cs)
                OUT:begin
                    if(m_ready == 1 && m_valid == 1) cnt <= cnt + 1 ;
                    else cnt <= cnt ;
                end
                default: cnt <= 0 ;
            endcase
        end
    end
    //===== m_valid =====//
    always@(posedge clk)begin
        if(!rst) m_valid <= 0 ;
        else begin
            case(cs)
                OUT:begin
                    if(cnt == trans_lenth - 1) m_valid <= 0 ;
                    else begin
                        if(m_ready == 1) m_valid <= 1 ;
                        else m_valid <= 0 ;
                    end
                end
                default: m_valid <= 0 ;
            endcase
        end
    end
    
    //===== m_tlast =====//
    always@(posedge clk)begin
        if(!rst) m_tlast <= 0 ;
        else begin
            case(cs)
                OUT:begin
                    if(cnt == trans_lenth - 2) m_tlast <= 1 ;
                    else m_tlast <= 0 ;
                end
                default: m_tlast <= 0 ;
            endcase
        end
    end
    
    //===== m_data =====//
    always@(posedge clk) begin
        if(!rst) m_data <= 0 ;
        else begin
            case(cs)
                OUT:begin
                    if(m_ready == 0 || m_valid == 0)begin
                        if(cnt == 0) m_data <= m_reg[cnt] ;
                        else m_data <= m_data ;
                    end
                    else begin
                        if(m_tlast == 1) m_data <= 0 ;
                        else m_data <= m_reg[cnt+1] ;
                    end
                end
            endcase
        end
    end
    
endmodule
