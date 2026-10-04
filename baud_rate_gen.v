module baud_rate_gen(clk, rst, baud_tick);
parameter divisor = 4; // sample value - slows down system clock by 4x
input clk, rst;
reg[$clog2(divisor)-1:0] count;
output reg baud_tick;
always@(posedge clk)begin
    if(rst)begin // if rst is set then make count , baud tick = 0
        count <= 0;
        baud_tick <= 0;
    end
    // or if count has not reached till divisor-1 value, keep counting / incrementing
    else if(count != divisor-1)begin 
        count <= count + 1;
        baud_tick <=0;
    end
    // when count is done then reset value of count to start again, and fire baud tick
    else begin
        count <=0;
        baud_tick<=1;
    end
end
endmodule