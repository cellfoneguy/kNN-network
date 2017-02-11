
`timescale 1ns/1ps

`include "define.vh"

`define  INIT           0
`define  DATA_START     1
`define  PIPELINE       2
`define  WAIT           3

`define  TRAIN_SIZE     75
`define  TEST_SIZE      75

module tb_knn ();

    // ------------------------------------------------------------------------
    // signal declaration
    // global
    bit           clk, rst;

    // for finite state machine
    bit [1:0]     state, next_state;
    bit           state_init, state_data_start, state_pipeline, state_wait;

    // for memory
    bit [31:0]    test_data, train_data;
    bit [1:0]     test_label, train_label;

    bit [7:0]     train_addr, test_addr, train_addr_d;
    bit [7:0]     train_addr_din, test_addr_din;

    // for knn pipeline
    bit           rst_knn;

    bit [31:0]    test_data_knn, train_data_knn;
    bit [1:0]     train_label_knn;

    bit [7:0]     train_addr_knn, test_addr_knn, train_addr_knn_din;

    bit [1:0]     res;
    bit           res_vld;

    // for debug
    integer       n_correct, n_all;



    // ------------------------------------------------------------------------
    // module instantiation
    knn knn_ins(
                .res(res),
                .res_vld(res_vld),
                .test_data(test_data_knn),
                .train_data(train_data_knn),
                .label(train_label_knn),
                .index(train_addr_knn),
                .clk(clk),
                .rst(rst_knn)
            );

    memory  mem_train(
                .clk(clk),
                .wr(1'b0),
                .addr(train_addr),
                .data_in(34'h0),
                .data_out({train_label, train_data})
            );

    memory  mem_test(
                .clk(clk),
                .wr(1'b0),
                .addr(test_addr),
                .data_in(34'h0),
                .data_out({test_label, test_data})
            );

    // initialize memory
    initial begin
        $readmemh("train.dat", mem_train.mem);
        $readmemh("test.dat", mem_test.mem);
    end



    // ------------------------------------------------------------------------
    // global control
    initial begin
        $vcdpluson;
        n_correct = 0; n_all = 0;
        rst = 1;
        #17 rst = 0;
        #150000 $finish;
    end
    always @(posedge clk) begin
        if (state_init && test_addr >= `TEST_SIZE) begin
            $display("-------------");
            $display("-------------");
            $display("Accuracy: %3d / %3d classifications are correct!", n_correct, n_all);
            $display("-------------");
            $display("-------------");
            $vcdplusoff; $finish;
        end
    end

    // generate clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end



    // ------------------------------------------------------------------------
    // finite state machine (defines control flow)
    // `INIT        - initial
    // `DATA_START  - start reading testing data and training data
    // `PIPELINE    - run pipeline
    // `WAIT        - wait for pipeline finishing
    assign  state_init = state == `INIT;
    assign  state_data_start = state == `DATA_START;
    assign  state_pipeline = state == `PIPELINE;
    assign  state_wait = state == `WAIT;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= 0;
        end
        else begin
            state <= next_state;
        end
    end
    assign  next_state = (state_init & test_addr < `TEST_SIZE)? `DATA_START:
                         state_data_start? `PIPELINE:
                         (state_pipeline && train_addr < `TRAIN_SIZE)? `PIPELINE:
                         (state_pipeline & ~res_vld)? `WAIT:
                         (state_wait && test_addr < `TEST_SIZE && ~res_vld)? `WAIT:`INIT;



    // ------------------------------------------------------------------------
    // read training data and testing data from memory
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            test_addr <= 0;
            train_addr <= 0;
            train_addr_d <= 0;
        end
        else begin
            test_addr <= test_addr_din;
            train_addr <= train_addr_din;
            train_addr_d <= train_addr;
        end
    end
    assign  test_addr_din = res_vld? test_addr+1 : test_addr;
    assign  train_addr_din = state_init? 0:
                    (state_data_start | state_pipeline)? train_addr+1 : train_addr;



    // ------------------------------------------------------------------------
    // supply data to pipeline
    assign  rst_knn = res_vld | state_init | state_data_start;

    assign  test_addr_knn = state_pipeline? test_addr : 0;
    assign  test_data_knn = state_pipeline? test_data : 0;
    assign  train_addr_knn = state_pipeline? train_addr_d : 0;
    assign  train_data_knn = state_pipeline? train_data : 0;
    assign  train_label_knn = state_pipeline? train_label : 0;
    


    // ------------------------------------------------------------------------
    // print classification results
    always @(posedge clk) begin
        if (res_vld) begin
            $display("-------------");
            $display("Testing Data #%d: Predicted Label=%d,  Actual Label=%d, [%1d]", test_addr, res, test_label, res==test_label);
            if (res == test_label)
                n_correct <= n_correct + 1;
            n_all <= n_all + 1;
            $display("          Index  Distance  Label"); 
            $display("1st NN:    %3d     %3d     %3d", knn_ins.sort_1.index_nn, knn_ins.sort_1.dist_nn, knn_ins.sort_1.label_nn);
            $display("2nd NN:    %3d     %3d     %3d", knn_ins.sort_2.index_nn, knn_ins.sort_2.dist_nn, knn_ins.sort_2.label_nn);
            $display("3rd NN:    %3d     %3d     %3d", knn_ins.sort_3.index_nn, knn_ins.sort_3.dist_nn, knn_ins.sort_3.label_nn);
            $display("4th NN:    %3d     %3d     %3d", knn_ins.sort_4.index_nn, knn_ins.sort_4.dist_nn, knn_ins.sort_4.label_nn);
            $display("5th NN:    %3d     %3d     %3d", knn_ins.sort_5.index_nn, knn_ins.sort_5.dist_nn, knn_ins.sort_5.label_nn);
        end
    end

endmodule



// 256*42 memory, single-port, synchronuous read/write
module memory(
    input bit         clk,
    input bit         wr,
    input bit  [7:0]  addr,
    input bit  [33:0] data_in,
    output bit [33:0] data_out   
);

    bit  [33:0]   mem [0:255];

    always @(posedge clk) begin
        if (wr)
            mem[addr] <= data_in;
        data_out <= mem[addr];
    end

endmodule
