module transmitter(clk, reset, tx_start, data, baud_tick, busy, done, tx_serial_out);
input clk, reset, tx_start, baud_tick; // tx start is the enable signal which tells that if this is enable then operation happens
input [7:0] data; // 8 bits data
output reg busy, done; // if busy is set than transmitter is busy in op., done is set when whole thing is transferred
output reg tx_serial_out;
reg [9:0] frame; // internal register that stores the parallel data
reg [3:0] count; // to count if all 10 bits have been shifted onto tx or not
always @(posedge clk)begin
    done <=0;
    if(reset)begin
        busy <=0;
        done <=0;
        frame <=0;
        count <=0; // starts from 0
        tx_serial_out = 1; // when it is reset than idle line is high for this
    end 
    else if(~busy & tx_start)begin
        frame <= {1'b1, data, 1'b0}; // stop bit, data, start bit
        busy <= 1;
        count <=0;
    end 
    else if(busy & baud_tick)begin
        frame <= frame >> 1;
        tx_serial_out <= frame[0]; // put the lsb bit onto the tx serial out
        count <= count + 1;
        if(count==9)begin
            busy <=0; // as all bits are transferred, line is now idle
            done <= 1; // all bits transferred, op. done !
        end
    end
    end
endmodule