class axi_monitor extends uvm_monitor; // {{{
  
  `uvm_component_utils(axi_monitor)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new 

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info(get_type_name(), $sformatf("Info from monitor"), UVM_LOW)
  endtask : run_phase

  virtual function void start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Info from monitor"), UVM_LOW)
  endfunction : start_of_simulation_phase

endclass : axi_monitor // }}}
