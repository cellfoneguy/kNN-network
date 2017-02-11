
`timescale 1ns/1ps

`include "define.vh"

module sort(
    // output
    output bit [`NUM_BIT-1:0]    dist_out,
    output bit [1:0]    label_out,
    output bit [7:0]    index_out,

    output bit [1:0]    label_nn,

    // input 
    input  bit [`NUM_BIT-1:0]    dist_in,
    input  bit [1:0]    label_in,
    input  bit [7:0]    index_in,

    input  bit          clk,
    input  bit          rst
);  

    bit  replace;

    bit [`NUM_BIT-1:0]  dist_nn, dist_nn_din;
    bit [1:0]    label_nn_din;
    bit [7:0]    index_nn, index_nn_din;


    // (dist_nn, label_nn, index_nn) is a nearest neighbor, staying in current stage
    assign  {dist_nn_din,label_nn_din,index_nn_din} = replace? {dist_in,label_in,
                            index_in} : {dist_nn,label_nn,index_nn};

    always_ff @(posedge clk) begin
        if (rst)    dist_nn <= 0;
        else    dist_nn <= dist_nn_din;
    end

    always_ff @(posedge clk) begin
        if (rst)    label_nn <= 0;
        else    label_nn <= label_nn_din;
    end

    always_ff @(posedge clk) begin
        if (rst)    index_nn <= 0;
        else    index_nn <= index_nn_din;
    end


    // --------------------------------------------------------------
    // Implement your design from here






    


endmodule
