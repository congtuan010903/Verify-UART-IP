class default_value_test extends uart_base_test;
	`uvm_component_utils(default_value_test)
	uvm_reg_hw_reset_seq reg_reset_seq;
	uvm_status_e         status;
	
	//-----------------------------------
	// Constructor
	//-----------------------------------
	function new(string name = "default_value_test", uvm_component parent);
		super.new(name,parent);
	endfunction

	//-----------------------------------
	// run phase
	//-----------------------------------
	virtual task run_phase(uvm_phase phase);
		bit[31:0] data;
		phase.raise_objection(this);
		
		uvm_resource_db #(bit)::set(
			{"REG::", regmodel.TBR.get_full_name()},
			"NO_REG_HW_RESET_TEST",1
		);
		uvm_resource_db #(bit)::set(
			{"REG::", regmodel.RBR.get_full_name()},
			"NO_REG_HW_RESET_TEST",1
		);
		
		#100ns;	
		reg_reset_seq = uvm_reg_hw_reset_seq::type_id::create("reg_reset_seq");
		reg_reset_seq.model = regmodel;
		reg_reset_seq.start(null);

		phase.drop_objection(this);
	endtask

endclass
