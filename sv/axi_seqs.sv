//------------------------------------------------------------------------------
//
// SEQUENCE: base axi sequence - base sequence with objections from which 
// all sequences can be derived
//
//------------------------------------------------------------------------------
class axi_base_seq extends uvm_sequence #(axi_packet_input); // {{{
  
  // Required macro for sequences automation
  `uvm_object_utils(axi_base_seq)

  // Constructor
  function new(string name="axi_base_seq");
    super.new(name);
  endfunction

  task pre_body();
    starting_phase.raise_objection(this, get_type_name());
    `uvm_info(get_type_name(), "raise objection", UVM_MEDIUM)
  endtask : pre_body

  task post_body();
    starting_phase.drop_objection(this, get_type_name());
    `uvm_info(get_type_name(), "drop objection", UVM_MEDIUM)
  endtask : post_body

endclass : axi_base_seq // }}}

class axi_1_seq extends axi_base_seq; // {{{
  
  // Required macro for sequences automation
  `uvm_object_utils(axi_1_seq)

  // Constructor
  function new(string name="axi_1_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "Executing axi_1_seq sequence", UVM_LOW)
    `uvm_do_with(req, {addr == 1;})    
  endtask : body

endclass : axi_1_seq // }}}

class axi_exhaustive_seq extends axi_base_seq; // {{{
  
  axi_1_seq y_1_seq;
  // Required macro for sequences automation
  `uvm_object_utils(axi_exhaustive_seq)

  // Constructor
  function new(string name="axi_exhaustive_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "Executing axi_exhaustive_seq sequence", UVM_LOW)
    `uvm_do(y_1_seq)
  endtask : body

endclass : axi_exhaustive_seq // }}}

