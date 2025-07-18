class full_dynamic_baudrate_test extends uart_base_test;
	`uvm_component_utils(full_dynamic_baudrate_test)
	
	uvm_status_e       status;
	uart_configuration uart_config2;
	vip_tx_sequence		 seq,seq2;

	//----------------------------------------
	// Constructor
	//----------------------------------------
	function new(string name = "full_dynamic_baudrate_test", uvm_component parent);
		super.new(name,parent);
	endfunction

	//-------------------------------------
	// run phase
	//-------------------------------------
	virtual task run_phase(uvm_phase phase);
		bit[7:0]  transmit_data;
		bit[5:0]  transmit_data2;
		bit[31:0] rdata;
		phase.raise_objection(this);

		transmit_data = $urandom();
		do
			transmit_data2 = $urandom();
		while(transmit_data == transmit_data2);

		wait(ahb_vif.HRESETn === 1);

		// config VIP
		uart_config2 = uart_configuration::type_id::create("uart_config2");
		uart_config2.baud_rate   = 115200;
		uart_config2.data_width  = 8;
		uart_config2.parity_mode = uart_configuration::PARITY_NONE;
		uart_config2.stop_bits   = 1;
		`uvm_info(get_type_name(),"UART agent updating...",UVM_LOW)
		env.uart_agt.update_config(uart_config2);
		// config DUT
		regmodel.MDR.write(status,32'h00); #50ns;
		regmodel.DLL.write(status,32'h36); #50ns;
		regmodel.LCR.write(status,32'h33); #50ns;

		regmodel.TBR.write(status,transmit_data);

		seq = vip_tx_sequence::type_id::create("seq");
		seq.start(env.uart_agt.uart_seqcer);
		
		regmodel.RBR.read(status,rdata);
		env.uart_sb.update_rbr_data(rdata);
	
		// reconfig VIP to change baudrate
		uart_config2.baud_rate = 9600;
		`uvm_info(get_type_name(),"UART agent updating...",UVM_LOW)
		env.uart_agt.update_config(uart_config2);
		// config DUT to change baudrate
		regmodel.DLL.write(status,32'h8B); #50ns;
		regmodel.DLH.write(status,32'h02); #50ns;
		regmodel.TBR.write(status,transmit_data2);

		seq2 = vip_tx_sequence::type_id::create("seq2");
		seq2.start(env.uart_agt.uart_seqcer);
		
		regmodel.RBR.read(status,rdata);
		env.uart_sb.update_rbr_data(rdata);
	
		phase.drop_objection(this);
	endtask

endclass
