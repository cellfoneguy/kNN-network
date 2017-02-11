
`timescale 1ns/1ps

`include "define.vh"

module knn(
    // output
    output bit [1:0]        res,
    output bit              res_vld,

    // input
    input  bit [31:0]       train_data,
    input  bit [31:0]       test_data,

    input  bit [1:0]        label,
    input  bit [7:0]        index,

    input  bit              clk,
    input  bit              rst
);

    
    // declare signals
    bit [`NUM_BIT-1:0]   dist_in_1, dist_out_1;
    bit [`NUM_BIT-1:0]   dist_in_2, dist_out_2;
    bit [`NUM_BIT-1:0]   dist_in_3, dist_out_3;
    bit [`NUM_BIT-1:0]   dist_in_4, dist_out_4;
    
    bit [1:0]   label_in_1, label_out_1;
    bit [1:0]   label_in_2, label_out_2;
    bit [1:0]   label_in_3, label_out_3;
    bit [1:0]   label_in_4, label_out_4;

    bit [7:0]   index_in_1, index_out_1;
    bit [7:0]   index_in_2, index_out_2;
    bit [7:0]   index_in_3, index_out_3;
    bit [7:0]   index_in_4, index_out_4;

    bit [`NUM_BIT-1:0]   nn_dist_in_1, nn_dist_out_1;
    bit [`NUM_BIT-1:0]   nn_dist_in_2, nn_dist_out_2;
    bit [`NUM_BIT-1:0]   nn_dist_in_3, nn_dist_out_3;
    bit [`NUM_BIT-1:0]   nn_dist_in_4, nn_dist_out_4; // new
    bit [`NUM_BIT-1:0]   nn_dist_in_5, nn_dist_out_5; // new
    
    bit [1:0]   nn_label_in_1, nn_label_out_1, nn_label_1;
    bit [1:0]   nn_label_in_2, nn_label_out_2, nn_label_2;
    bit [1:0]   nn_label_in_3, nn_label_out_3, nn_label_3;
    bit [1:0]   nn_label_in_4, nn_label_out_4, nn_label_4; // new
    bit [1:0]   nn_label_in_5, nn_label_out_5, nn_label_5; // new

    bit [7:0]   nn_index_in_1, nn_index_out_1;
    bit [7:0]   nn_index_in_2, nn_index_out_2;
    bit [7:0]   nn_index_in_3, nn_index_out_3;
    bit [7:0]   nn_index_in_4, nn_index_out_4; // new
    bit [7:0]   nn_index_in_5, nn_index_out_5; // new

    // wires for passing training sample through pipeline
    bit [23:0]  train_data_pass_24;
    bit [15:0]  train_data_pass_16;
    bit [7:0]   train_data_pass_8;



    // instantiate distance
    distance  distance_1(
        // output
        .dist_out(dist_in_1),
        .label_out(label_in_1),
        .index_out(index_in_1),

        // input 
        .dist_in({(`NUM_BIT){1'b0}}),
        .label_in(label),
        .index_in(index),

        .x(train_data[31:24]),  // one attribute of training sample
        .y(test_data[31:24])   // one attribute of testing sample
    );

    pipeline_reg_for_dist #(24)  distance_reg_1(
        // output
        .dist_out(dist_out_1),
        .label_out(label_out_1),
        .index_out(index_out_1),
        .train_data_out(train_data_pass_24),

        // input 
        .dist_in(dist_in_1),
        .label_in(label_in_1),
        .index_in(index_in_1),
        .train_data_in(train_data[23:0]),

        .clk(clk),
        .rst(rst)
    );

    distance  distance_2(
        // output
        .dist_out(dist_in_2),
        .label_out(label_in_2),
        .index_out(index_in_2),

        // input 
        .dist_in(dist_out_1),
        .label_in(label_out_1),
        .index_in(index_out_1),

        .x(train_data_pass_24[23:16]),  // one attribute of training sample
        .y(test_data[23:16])   // one attribute of testing sample
    );

    pipeline_reg_for_dist #(16)  distance_reg_2(
        // output
        .dist_out(dist_out_2),
        .label_out(label_out_2),
        .index_out(index_out_2),
        .train_data_out(train_data_pass_16),

        // input 
        .dist_in(dist_in_2),
        .label_in(label_in_2),
        .index_in(index_in_2),
        .train_data_in(train_data_pass_24[15:0]),

        .clk(clk),
        .rst(rst)
    );

    distance  distance_3(
        // output
        .dist_out(dist_in_3),
        .label_out(label_in_3),
        .index_out(index_in_3),

        // input 
        .dist_in(dist_out_2),
        .label_in(label_out_2),
        .index_in(index_out_2),

        .x(train_data_pass_16[15:8]),  // one attribute of training sample
        .y(test_data[15:8])   // one attribute of testing sample
    );

    pipeline_reg_for_dist #(8)  distance_reg_3(
        // output
        .dist_out(dist_out_3),
        .label_out(label_out_3),
        .index_out(index_out_3),
        .train_data_out(train_data_pass_8),

        // input 
        .dist_in(dist_in_3),
        .label_in(label_in_3),
        .index_in(index_in_3),
        .train_data_in(train_data_pass_16[7:0]),

        .clk(clk),
        .rst(rst)
    );

    distance  distance_4(
        // output
        .dist_out(dist_in_4),
        .label_out(label_in_4),
        .index_out(index_in_4),

        // input 
        .dist_in(dist_out_3),
        .label_in(label_out_3),
        .index_in(index_out_3),

        .x(train_data_pass_8[7:0]),  // one attribute of training sample
        .y(test_data[7:0])   // one attribute of testing sample
    );

    pipeline_reg_for_sort  distance_reg_4(
        // output
        .dist_out(dist_out_4),
        .label_out(label_out_4),
        .index_out(index_out_4),

        // input 
        .dist_in(dist_in_4),
        .label_in(label_in_4),
        .index_in(index_in_4),

        .clk(clk),
        .rst(rst)
    );



    // instantiate SORT
    sort  sort_1(
        // output
        .dist_out(nn_dist_in_1),
        .label_out(nn_label_in_1),
        .index_out(nn_index_in_1),

        .label_nn(nn_label_1),

        // input 
        .dist_in(dist_out_4),
        .label_in(label_out_4),
        .index_in(index_out_4),

        .clk(clk),
        .rst(rst)
    );

    pipeline_reg_for_sort  sort_reg_1(
        // output
        .dist_out(nn_dist_out_1),
        .label_out(nn_label_out_1),
        .index_out(nn_index_out_1),

        // input 
        .dist_in(nn_dist_in_1),
        .label_in(nn_label_in_1),
        .index_in(nn_index_in_1),

        .clk(clk),
        .rst(rst)
    );

    sort  sort_2(
        // output
        .dist_out(nn_dist_in_2),
        .label_out(nn_label_in_2),
        .index_out(nn_index_in_2),

        .label_nn(nn_label_2),

        // input 
        .dist_in(nn_dist_out_1),
        .label_in(nn_label_out_1),
        .index_in(nn_index_out_1),

        .clk(clk),
        .rst(rst)
    );

    pipeline_reg_for_sort  sort_reg_2(
        // output
        .dist_out(nn_dist_out_2),
        .label_out(nn_label_out_2),
        .index_out(nn_index_out_2),

        // input 
        .dist_in(nn_dist_in_2),
        .label_in(nn_label_in_2),
        .index_in(nn_index_in_2),

        .clk(clk),
        .rst(rst)
    );

    sort  sort_3(
        // output
        .dist_out(nn_dist_in_3),
        .label_out(nn_label_in_3),
        .index_out(nn_index_in_3),

        .label_nn(nn_label_3),

        // input 
        .dist_in(nn_dist_out_2),
        .label_in(nn_label_out_2),
        .index_in(nn_index_out_2),

        .clk(clk),
        .rst(rst)
    );

    pipeline_reg_for_sort  sort_reg_3(
        // output
        .dist_out(nn_dist_out_3),
        .label_out(nn_label_out_3),
        .index_out(nn_index_out_3),

        // input 
        .dist_in(nn_dist_in_3),
        .label_in(nn_label_in_3),
        .index_in(nn_index_in_3),

        .clk(clk),
        .rst(rst)
    );

    // new
    sort  sort_4(
        // output
        .dist_out(nn_dist_in_4),
        .label_out(nn_label_in_4),
        .index_out(nn_index_in_4),

        .label_nn(nn_label_4),

        // input 
        .dist_in(nn_dist_out_3),
        .label_in(nn_label_out_3),
        .index_in(nn_index_out_3),

        .clk(clk),
        .rst(rst)
    );

    // new
    pipeline_reg_for_sort  sort_reg_4(
        // output
        .dist_out(nn_dist_out_4),
        .label_out(nn_label_out_4),
        .index_out(nn_index_out_4),

        // input 
        .dist_in(nn_dist_in_4),
        .label_in(nn_label_in_4),
        .index_in(nn_index_in_4),

        .clk(clk),
        .rst(rst)
    );

    // new
    sort  sort_5(
        // output
        .dist_out(nn_dist_in_5),
        .label_out(nn_label_in_5),
        .index_out(nn_index_in_5),

        .label_nn(nn_label_5),

        // input 
        .dist_in(nn_dist_out_4),
        .label_in(nn_label_out_4),
        .index_in(nn_index_out_4),

        .clk(clk),
        .rst(rst)
    );

    // new
    pipeline_reg_for_sort  sort_reg_5(
        // output
        .dist_out(nn_dist_out_5),
        .label_out(nn_label_out_5),
        .index_out(nn_index_out_5),

        // input 
        .dist_in(nn_dist_in_5),
        .label_in(nn_label_in_5),
        .index_in(nn_index_in_5),

        .clk(clk),
        .rst(rst)
    );


    
    // instantiate VOTE
    vote  vote_i(
        // output 
        .res(res),

        // input
        .label_nn1(nn_label_1),
        .label_nn2(nn_label_2),
        .label_nn3(nn_label_3),
        .label_nn4(nn_label_4),  // new
        .label_nn5(nn_label_5)   // new
    );


    // "res_vld" indicates "res" is valid
    // need to consider further if number of training sample is less than 3
    assign  res_vld = (nn_label_5 != 0) & (nn_label_out_4 == 0);  // new

endmodule





module pipeline_reg_for_dist(
        // output
        dist_out,
        label_out,
        index_out,
        train_data_out,

        // input 
        dist_in,
        label_in,
        index_in,
        train_data_in,

        clk,
        rst
);

    parameter   width_train_data_pass = 32;

    // output
    output bit [`NUM_BIT-1:0]    dist_out;
    output bit [1:0]    label_out;
    output bit [7:0]    index_out;
    output bit [width_train_data_pass-1:0]  train_data_out;

    // input 
    input  bit [`NUM_BIT-1:0]    dist_in;
    input  bit [1:0]    label_in;
    input  bit [7:0]    index_in;
    input  bit [width_train_data_pass-1:0]  train_data_in;

    input  bit          clk;
    input  bit          rst;


    bit [`NUM_BIT-1:0]   dist_dout;
    bit [1:0]   label_dout;
    bit [7:0]   index_dout;
    bit [width_train_data_pass-1:0] train_data_dout;

    always_ff @(posedge clk) begin
        if (rst)    dist_dout <= 0;
        else    dist_dout <= dist_in;
    end
    assign dist_out = dist_dout;


    always_ff @(posedge clk) begin
        if (rst)    label_dout <= 0;
        else    label_dout <= label_in;
    end
    assign label_out = label_dout;


    always_ff @(posedge clk) begin
        if (rst)    index_dout <= 0;
        else    index_dout <= index_in;
    end
    assign index_out = index_dout;

    always_ff @(posedge clk) begin
        if (rst)    train_data_dout <= 0;
        else    train_data_dout <= train_data_in;
    end
    assign train_data_out = train_data_dout;

endmodule



module pipeline_reg_for_sort(
    // output
    output bit [`NUM_BIT-1:0]    dist_out,
    output bit [1:0]    label_out,
    output bit [7:0]    index_out,

    // input 
    input  bit [`NUM_BIT-1:0]    dist_in,
    input  bit [1:0]    label_in,
    input  bit [7:0]    index_in,

    input  bit          clk,
    input  bit          rst
);

    bit [`NUM_BIT-1:0]   dist_dout;
    bit [1:0]   label_dout;
    bit [7:0]   index_dout;

    always_ff @(posedge clk) begin
        if (rst)    dist_dout <= 0;
        else    dist_dout <= dist_in;
    end
    assign dist_out = dist_dout;


    always_ff @(posedge clk) begin
        if (rst)    label_dout <= 0;
        else    label_dout <= label_in;
    end
    assign label_out = label_dout;


    always_ff @(posedge clk) begin
        if (rst)    index_dout <= 0;
        else    index_dout <= index_in;
    end
    assign index_out = index_dout;

endmodule


