class reserved_region_test extends uart_base_test;
	`uvm_component_utils(reserved_region_test)
	uvm_status_e         status;
	
	//-----------------------------------
	// Constructor
	//-----------------------------------
	function new(string name = "reserved_region_test", uvm_component parent);
		super.new(name,parent);
	endfunction

	//-----------------------------------
	// run phase
	//-----------------------------------
	virtual task run_phase(uvm_phase phase);
		bit[31:0] data;
		phase.raise_objection(this);
		
		// write	
		for(int i = 0; i < 248; i++) begin
			data = $urandom();
			regmodel.reserved_reg[i].write(status,data);
			@(posedge ahb_vif.HCLK);	
			if(ahb_vif.HRESP !== 1) 
				`uvm_error(get_type_name(),"HRESP must trigger to 1")
		end
		
		// read	
		for(int i = 0; i < 248; i++) begin
			regmodel.reserved_reg[i].read(status,data);
			if(data == 32'hFFFFFFFF)
				`uvm_info(get_type_name(),"Default value of reserved register correct",UVM_LOW)
			else
				`uvm_error(get_type_name(),"Incorrect default value of reserved register")
			if(ahb_vif.HRESP !== 1) 
				`uvm_error(get_type_name(),"HRESP must trigger to 1")
		end

		phase.drop_objection(this);
	endtask

endclass
