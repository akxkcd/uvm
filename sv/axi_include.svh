`ifndef AXI_INCLUDE_SVH
`define AXI_INCLUDE_SVH

typedef uvm_config_db#(virtual axi_if) axi_vif_config;

import uvm_pkg::*;

`include "uvm_macros.svh"
`include "axi_packet_input.svh"
`include "axi_monitor.sv"
`include "axi_sequencer.sv"
`include "axi_seqs.sv"
`include "axi_driver.sv"
`include "axi_agent.sv"
`include "axi_env.sv"

`endif // AXI_INCLUDE_SVH

