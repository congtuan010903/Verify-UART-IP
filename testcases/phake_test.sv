class phake_test extends uart_base_test;
	`uvm_component_utils(phake_test)
	uvm_reg_bit_bash_seq reg_bit_bash_seq;
	uvm_status_e         status;
	vip_tx_sequence      seq;
	
	//-----------------------------------
	// Constructor
	//-----------------------------------
	function new(string name = "phake_test", uvm_component parent);
		super.new(name,parent);
	endfunction

	//-----------------------------------
	// run phase
	//-----------------------------------
	virtual task run_phase(uvm_phase phase);
		seq = vip_tx_sequence::type_id::create("seq");
		seq.start(env.uart_agt.uart_seqcer);
		`uvm_info(get_type_name(),$sformatf("aaaaaaaaaaaaaaaaaaaaaa %0b",seq.tx.data),UVM_LOW)
		phase.drop_objection(this);
	endtask

endclass
