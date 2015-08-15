class axi_tb extends uvm_component; // {{{

  `uvm_component_utils(axi_tb)

  function new(string name, uvm_component parent); // {{{
    super.new(name, parent);
  endfunction : new // }}}

  virtual function void build_phase(uvm_phase phase); // {{{
    set_config_int("*", "recording_detail", 1);
    super.build_phase(phase);
  endfunction : build_phase // }}}

endclass : axi_tb // }}}

