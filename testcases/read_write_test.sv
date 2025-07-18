class read_write_test extends uart_base_test;
	`uvm_component_utils(read_write_test)
	uvm_reg_bit_bash_seq reg_bit_bash_seq;
	uvm_status_e         status;
	
	//-----------------------------------
	// Constructor
	//-----------------------------------
	function new(string name = "read_write_test", uvm_component parent);
		super.new(name,parent);
	endfunction

	//-----------------------------------
	// run phase
	//-----------------------------------
	virtual task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		
		uvm_resource_db #(bit)::set(
			{"REG::", regmodel.TBR.get_full_name()},
			"NO_REG_BIT_BASH_TEST",1
		);
		uvm_resource_db #(bit)::set(
			{"REG::", regmodel.RBR.get_full_name()},
			"NO_REG_BIT_BASH_TEST",1
		);
		uvm_resource_db #(bit)::set(
			{"REG::", regmodel.FSR.get_full_name()},
			"NO_REG_BIT_BASH_TEST",1
		);
		for(int i = 0; i < 248; i++) begin
			uvm_resource_db #(bit)::set(
			{"REG::", regmodel.reserved_reg[i].get_full_name()},
			"NO_REG_BIT_BASH_TEST",1
			);
		end
		#100ns;
		reg_bit_bash_seq = uvm_reg_bit_bash_seq::type_id::create("reg_bit_bash_seq");
		reg_bit_bash_seq.model = regmodel;
		reg_bit_bash_seq.start(null);
		phase.drop_objection(this);
	endtask

endclass
