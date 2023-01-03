`timescale 1ns / 1ps

//4 entry Synchronous FIFO (when wclock and rclock are same or multiple of one another)
//each entry is 8 bits
module FIFO #(parameter width = 8, parameter depth = 4)
    (
    input rst, wclock, rclock, write, read, input [width-1:0] wdata,
    output reg [width-1:0] rdata, output wire full, wire empty
    );
    reg [width-1:0] mem_array[0:depth-1];  //FIFO (where data is saved)
    
    parameter addr_msb = $clog2(depth) -1;   //log2(4) - 1 == 1
    //waddr and raddr have one more bit to indicate FIFO is full
    reg [addr_msb+1:0] waddr, raddr;
    
    initial begin
    waddr = 0;
    raddr = 0;
    end
    
    //if all 4 bits are same, indicates that FIFO is empty (cannt read)
    //if only msb bit is different and rest are same, FIFO is full (cannot write)
    assign empty = (raddr == waddr) ? 1'b1 : 1'b0;
    assign full = (waddr[addr_msb:0] == raddr[addr_msb:0] &&
                   waddr[addr_msb+1] != raddr[addr_msb+1])
                   ? 1'b1 : 1'b0;
      

    //write to FIFO (when write clock is at posedge)
    always @(posedge wclock or posedge rst) begin
    if (rst)
    waddr <= 0;
    else begin
    if (write && !full) begin
    mem_array[waddr] <= wdata;
    waddr <= waddr + write;   //here, write == 1
    end
    end
    end
    
    //read from FIFO (when read clock is at posedge)
    //need to have raddr and waddr separately because what we read
    //may not be what we are writing
    always @(posedge rclock or posedge rst) begin
    if (rst)
    raddr <= 0;
    else begin
    if (read && !empty) begin
    rdata <= mem_array[raddr];
    raddr <= raddr + write;     //here, write == 1
    end
    end
    end
    
    
endmodule
