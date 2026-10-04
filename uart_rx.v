module receiver(clk, reset, rx, baud_tick, data_out, busy, done);
parameter data_bits = 8;
input clk, reset, rx, baud_tick; // here rx is single bit which comes on the receiver line (fake transmitter)
output reg busy, done;
output reg [7:0]data_out; // final data
reg [$clog2(data_bits)-1:0] bit_count; // counts how many bits are filled
reg[data_bits-1:0] shift_reg; // internal register storing the incoming serial bits
reg [3:0] tick_count;
reg [1:0] state; // 4 states -> 2 bits

localparam idle = 0;
localparam start = 1;
localparam data = 2;
localparam stop = 3;
localparam half_tick = 7; // middle bit of the period
localparam full_tick = 15; // last bit of the period
always@(posedge clk)begin
    done <=0;
    if(reset)begin
        state <= idle;
        tick_count <=0;
        bit_count <=0;
        busy <=0;
        done <=0;
        shift_reg <=0;
        data_out <=0;
    end
   else if(baud_tick)begin
        case(state)
            idle : begin
                if(~busy & ~rx)begin
                state <= start; // start bit may come
                busy <=1;
                tick_count <=0;
            end
            end
            start : begin 
                if(tick_count == half_tick)begin
                    tick_count <=0; // as middle bit matched so reset tick count
                if(~rx)begin // if tick count is 7 (middle bit) and rx is 0 -> start arrive
                    state <= data; // start bit has arrived so move to fetching actual data
                end
                else begin
                    state <= idle;
                    busy <=0;
                end
            end
            else begin
                tick_count <= tick_count + 1;
            end
            end
            data : begin
                if(tick_count == full_tick)begin // now in data state, so comparing with full ticks
                    shift_reg <= (shift_reg >> 1) | (rx << 7); // here right shifting shift reg by 1 bit and left shifitng rx (8 bits) to msb bit and or-ing both to get accurate data incoming
                     tick_count <=0;
                if(bit_count == 7)begin
                    state <= stop; // all data loaded in shift reg
                    bit_count <=0;
                end
                else begin
                     bit_count <= bit_count + 1;
                end
                end
                else begin
                    tick_count <= tick_count +1;
                end
            end

            stop : begin
                if(tick_count == full_tick)begin
                    tick_count <=0;
                    state <= idle;
                    busy <=0;
                 if(rx)begin // rx = 1 -> stop bit
                    data_out <= shift_reg; // stop bit has arrived
                    done <=1; // full data on receiver line
                end
                end
                else begin
                    tick_count <= tick_count + 1;
                end
            end
            default :  state <= idle;
        endcase
    end
end
endmodule