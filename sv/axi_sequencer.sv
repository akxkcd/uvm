
class axi_sequencer extends uvm_sequencer #(axi_packet_input); // {{{
	`uvm_sequencer_utils(axi_sequencer)
	function new (string name, uvm_component parent);
		super.new(name, parent);
		`uvm_update_sequence_lib_and_item(axi_packet_input)
	endfunction : new
endclass : axi_sequencer // }}}

