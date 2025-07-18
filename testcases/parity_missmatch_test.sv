class parity_missmatch_test extends uart_base_test;
	`uvm_component_utils(parity_missmatch_test)
	
	uvm_status_e       status;
	uart_configuration uart_config2;
	vip_tx_sequence		 seq;

	//----------------------------------------
	// Constructor
	//----------------------------------------
	function new(string name = "parity_missmatch_test", uvm_component parent);
		super.new(name,parent);
	endfunction

	//-------------------------------------
	// run phase
	//-------------------------------------
	virtual task run_phase(uvm_phase phase);
		bit[4:0]  transmit_data;
		bit[31:0] fsr_rdata, rbr_rdata;
		phase.raise_objection(this);

		err_catcher.add_error_catcher_msg("Detect error on parity");

		wait(ahb_vif.HRESETn === 1);

		// config VIP
		uart_config2 = uart_configuration::type_id::create("uart_config2");
		uart_config2.baud_rate   = 115200;
		uart_config2.data_width  = 5;
		uart_config2.parity_mode = uart_configuration::PARITY_ODD;
		uart_config2.stop_bits   = 1;
		`uvm_info(get_type_name(),"UART agent updating...",UVM_LOW)
		env.uart_agt.update_config(uart_config2);
		// config DUT
		regmodel.MDR.write(status,32'h00); #(50*1ns);
		regmodel.DLL.write(status,32'h36); #(50*1ns);
		regmodel.LCR.write(status,32'h38); #(50*1ns);

		transmit_data = $urandom();
		regmodel.TBR.write(status,transmit_data);
		
		seq = vip_tx_sequence::type_id::create("seq");
		seq.start(env.uart_agt.uart_seqcer);
		
		regmodel.RBR.read(status,rbr_rdata);
		env.uart_sb.update_rbr_data(rbr_rdata);

		regmodel.FSR.read(status,fsr_rdata);
		if(fsr_rdata[4] === 1)
			`uvm_info(get_type_name(),"parity error, parity error status trigger", UVM_LOW)
		else
			`uvm_error(get_type_name(),"parity error, parity error status must be trigger")
		
		phase.drop_objection(this);
	endtask

endclass
