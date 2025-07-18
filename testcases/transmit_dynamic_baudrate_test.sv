class transmit_dynamic_baudrate_test extends uart_base_test;
	`uvm_component_utils(transmit_dynamic_baudrate_test)
	
	uvm_status_e       status;
	uart_configuration uart_config2;
	vip_tx_sequence		 seq;

	//----------------------------------------
	// Constructor
	//----------------------------------------
	function new(string name = "transmit_dynamic_baudrate_test", uvm_component parent);
		super.new(name,parent);
	endfunction

	//-------------------------------------
	// run phase
	//-------------------------------------
	virtual task run_phase(uvm_phase phase);
		bit[7:0]  transmit_data;
		bit[31:0] rdata;
		phase.raise_objection(this);
		
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
		transmit_data = $urandom();
		regmodel.TBR.write(status,transmit_data);		
		#((1.0e9/uart_config2.baud_rate)*13ns);	

		// reconfig VIP to change baudrate 9600
		uart_config2.baud_rate = 9600;
		`uvm_info(get_type_name(),"UART agent updating...",UVM_LOW)
		env.uart_agt.update_config(uart_config2);
		// reconfig DUT to change baudrate 9600
		transmit_data = $urandom();
		regmodel.DLL.write(status,32'h8B);
		regmodel.DLH.write(status,32'h02);
		regmodel.TBR.write(status,transmit_data);
		#((1.0e9/uart_config2.baud_rate)*13ns);

		// reconfig VIP to change baudrate 2400
		uart_config2.baud_rate = 2400;
		`uvm_info(get_type_name(),"UART agent updating...",UVM_LOW)
		env.uart_agt.update_config(uart_config2);
		// reconfig DUT to change baudrate 2400
		transmit_data = $urandom();
		regmodel.DLL.write(status,32'h2C);
		regmodel.DLH.write(status,32'h0A);
		regmodel.TBR.write(status,transmit_data);
		#((1.0e9/uart_config2.baud_rate)*13ns);

		// reconfig VIP to change baudrate 19200
		uart_config2.baud_rate = 19200;
		`uvm_info(get_type_name(),"UART agent updating...",UVM_LOW)
		env.uart_agt.update_config(uart_config2);
		// reconfig DUT to change baudrate 19200
		transmit_data = $urandom();
		regmodel.DLL.write(status,32'h45);
		regmodel.DLH.write(status,32'h01);
		regmodel.TBR.write(status,transmit_data);
		#((1.0e9/uart_config2.baud_rate)*13ns);		

		phase.drop_objection(this);
	endtask

endclass
