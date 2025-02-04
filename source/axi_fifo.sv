module axi_fifo #(
    parameter int unsigned Depth       = 32'd1,
    parameter bit          FallThrough = 1'b0,
    parameter type         aw_chan_t   = logic,
    parameter type         w_chan_t    = logic,
    parameter type         b_chan_t    = logic,
    parameter type         ar_chan_t   = logic,
    parameter type         r_chan_t    = logic,
    parameter type         axi_req_t   = logic,
    parameter type         axi_resp_t  = logic
) (
    input  logic      clk_i,  // Clock
    input  logic      rst_ni,  // Asynchronous reset active low
    input  logic      test_i,
    // slave port
    input  axi_req_t  slv_req_i,
    output axi_resp_t slv_resp_o,
    // master port
    output axi_req_t  mst_req_o,
    input  axi_resp_t mst_resp_i
);

  if (Depth == '0) begin : gen_no_fifo
    // degenerate case, connect input to output
    assign mst_req_o  = slv_req_i;
    assign slv_resp_o = mst_resp_i;
  end else begin : gen_axi_fifo
    logic aw_fifo_empty, ar_fifo_empty, w_fifo_empty, r_fifo_empty, b_fifo_empty;
    logic aw_fifo_full, ar_fifo_full, w_fifo_full, r_fifo_full, b_fifo_full;

    assign mst_req_o.aw_valid  = ~aw_fifo_empty;
    assign mst_req_o.ar_valid  = ~ar_fifo_empty;
    assign mst_req_o.w_valid   = ~w_fifo_empty;
    assign slv_resp_o.r_valid  = ~r_fifo_empty;
    assign slv_resp_o.b_valid  = ~b_fifo_empty;

    assign slv_resp_o.aw_ready = ~aw_fifo_full;
    assign slv_resp_o.ar_ready = ~ar_fifo_full;
    assign slv_resp_o.w_ready  = ~w_fifo_full;
    assign mst_req_o.r_ready   = ~r_fifo_full;
    assign mst_req_o.b_ready   = ~b_fifo_full;

    // A FiFo for each channel
    fifo_v3 #(
        .dtype(aw_chan_t),
        .DEPTH(Depth),
        .FALL_THROUGH(FallThrough)
    ) i_aw_fifo (
        .clk_i,
        .rst_ni,
        .flush_i   (1'b0),
        .testmode_i(test_i),
        .full_o    (aw_fifo_full),
        .empty_o   (aw_fifo_empty),
        .usage_o   (),
        .data_i    (slv_req_i.aw),
        .push_i    (slv_req_i.aw_valid && slv_resp_o.aw_ready),
        .data_o    (mst_req_o.aw),
        .pop_i     (mst_req_o.aw_valid && mst_resp_i.aw_ready)
    );
    fifo_v3 #(
        .dtype(ar_chan_t),
        .DEPTH(Depth),
        .FALL_THROUGH(FallThrough)
    ) i_ar_fifo (
        .clk_i,
        .rst_ni,
        .flush_i   (1'b0),
        .testmode_i(test_i),
        .full_o    (ar_fifo_full),
        .empty_o   (ar_fifo_empty),
        .usage_o   (),
        .data_i    (slv_req_i.ar),
        .push_i    (slv_req_i.ar_valid && slv_resp_o.ar_ready),
        .data_o    (mst_req_o.ar),
        .pop_i     (mst_req_o.ar_valid && mst_resp_i.ar_ready)
    );
    fifo_v3 #(
        .dtype(w_chan_t),
        .DEPTH(Depth),
        .FALL_THROUGH(FallThrough)
    ) i_w_fifo (
        .clk_i,
        .rst_ni,
        .flush_i   (1'b0),
        .testmode_i(test_i),
        .full_o    (w_fifo_full),
        .empty_o   (w_fifo_empty),
        .usage_o   (),
        .data_i    (slv_req_i.w),
        .push_i    (slv_req_i.w_valid && slv_resp_o.w_ready),
        .data_o    (mst_req_o.w),
        .pop_i     (mst_req_o.w_valid && mst_resp_i.w_ready)
    );
    fifo_v3 #(
        .dtype(r_chan_t),
        .DEPTH(Depth),
        .FALL_THROUGH(FallThrough)
    ) i_r_fifo (
        .clk_i,
        .rst_ni,
        .flush_i   (1'b0),
        .testmode_i(test_i),
        .full_o    (r_fifo_full),
        .empty_o   (r_fifo_empty),
        .usage_o   (),
        .data_i    (mst_resp_i.r),
        .push_i    (mst_resp_i.r_valid && mst_req_o.r_ready),
        .data_o    (slv_resp_o.r),
        .pop_i     (slv_resp_o.r_valid && slv_req_i.r_ready)
    );
    fifo_v3 #(
        .dtype(b_chan_t),
        .DEPTH(Depth),
        .FALL_THROUGH(FallThrough)
    ) i_b_fifo (
        .clk_i,
        .rst_ni,
        .flush_i   (1'b0),
        .testmode_i(test_i),
        .full_o    (b_fifo_full),
        .empty_o   (b_fifo_empty),
        .usage_o   (),
        .data_i    (mst_resp_i.b),
        .push_i    (mst_resp_i.b_valid && mst_req_o.b_ready),
        .data_o    (slv_resp_o.b),
        .pop_i     (slv_resp_o.b_valid && slv_req_i.b_ready)
    );
  end

endmodule
