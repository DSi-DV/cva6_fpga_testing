module ariane_tb;

  logic clk_i;
  logic rst_ni;

  logic [63:0] boot_addr_i;  // reset boot address
  logic [63:0] hart_id_i;  // hart id in a multicore environment (reflected in a CSR)

  logic [1:0] irq_i;  // level sensitive IR lines, mip & sip (async)
  logic ipi_i;  // inter-processor interrupts (async)

  logic time_irq_i;  // timer interrupt in (async)
  logic debug_req_i;  // debug request (async)

  // memory side, AXI Master
  ariane_axi_pkg::m_req_t axi_req_o;
  ariane_axi_pkg::m_resp_t axi_resp_i;

  ariane #(
      .DmBaseAddress(soc_pkg::DM_BASE_ADDR),
      .CachedAddrBeg(soc_pkg::CACHEABLE_ADDR_START)
  ) u_core (
      .clk_i(clk_i),
      .rst_ni(rst_ni),
      .boot_addr_i(boot_addr_i),
      .hart_id_i(hart_id_i),
      .irq_i(irq_i),
      .ipi_i(ipi_i),
      .time_irq_i(time_irq_i),
      .debug_req_i(debug_req_i),
      .axi_req_o(axi_req_o),
      .axi_resp_i(axi_resp_i)
  );

  axi_ram #(
      .MEM_BASE(soc_pkg::RAM_BASE),
      .MEM_SIZE(soc_pkg::RAM_SIZE),
      .req_t   (ariane_axi_pkg::m_req_t),
      .resp_t  (ariane_axi_pkg::m_resp_t)
  ) u_axi_ram (
      .clk_i  (clk_i),
      .arst_ni(rst_ni),
      .req_i  (axi_req_o),
      .resp_o (axi_resp_i)
  );

  initial begin

  end

endmodule
