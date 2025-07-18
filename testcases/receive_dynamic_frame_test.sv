class receive_dynamic_frame_test extends uart_base_test;
	`uvm_component_utils(receive_dynamic_frame_test)
	
	uvm_status_e       status;
	uart_configuration uart_config2;
	vip_tx_sequence		 seq,seq2;

	//----------------------------------------
	// Constructor
	//----------------------------------------
	function new(string name = "receive_dynamic_frame_test", uvm_component parent);
		super.new(name,parent);
	endfunction

	//-------------------------------------
	// run phase
	//-------------------------------------
	virtual task run_phase(uvm_phase phase);
		bit[7:0] rdata;
		phase.raise_objection(this);

		wait(ahb_vif.HRESETn === 1);

		// config VIP
		uart_config2 = uart_configuration::type_id::create("uart_config2");
		uart_config2.baud_rate   = 115200;
		uart_config2.data_width  = 8;
		uart_config2.parity_mode = uart_configuration::PARITY_EVEN;
		uart_config2.stop_bits   = 1;
		`uvm_info(get_type_name(),"UART agent updating...",UVM_LOW)
		env.uart_agt.update_config(uart_config2);
		// config DUT
		regmodel.IER.write(status,32'h08); #1ns;
		if(uart_vif.interrupt === 1)
			`uvm_info(get_type_name(),"Interrupt trigger because rx fifo is empty",UVM_LOW)
		else
			`uvm_error(get_type_name(),"RX FIFO is empty, expect interrupt trigger to 1 but not")

		regmodel.MDR.write(status,32'h00); #50ns;
		regmodel.DLL.write(status,32'h36); #50ns;
		regmodel.LCR.write(status,32'h3B); #50ns;

		// FIRST SEQUENCE
		seq = vip_tx_sequence::type_id::create("seq");
		seq.start(env.uart_agt.uart_seqcer);
		if(uart_vif.interrupt === 0) // check rx fifo empty interrupt
			`uvm_info(get_type_name(),"RX FIFO has data, interrupt is cleared",UVM_LOW)
		else
			`uvm_error(get_type_name(),"RX FIFO has data, interrupt must be cleared")
		regmodel.FSR.read(status,rdata); #1;
		if(rdata[3] === 0) // check rx fifo empty status
			`uvm_info(get_type_name(),"RX FIFO has empty, rx_fifo_empty_status is cleared",UVM_LOW)
		else
			`uvm_error(get_type_name(),"RX FIFO has empty, rx_fifo_empty_status must be cleared")
		if(rdata[4] === 0) // check parity error status
			`uvm_info(get_type_name(),"RX FIFO has empty, rx_fifo_empty_status is cleared",UVM_LOW)
		else
			`uvm_error(get_type_name(),"RX FIFO has empty, rx_fifo_empty_status must be cleared")
		
		regmodel.RBR.read(status,rdata);
		env.uart_sb.update_rbr_data(rdata);
		#1ns;
		if(uart_vif.interrupt === 1)
			`uvm_info(get_type_name(),"RX FIFO is empty, interrupt is trigger to 1",UVM_LOW)
		else
			`uvm_error(get_type_name(),"RX FIFO is empty, expect interrupt trigger to 1 but not")
		regmodel.FSR.read(status,rdata); #1;
		if(rdata[3] === 1)
			`uvm_info(get_type_name(),"RX FIFO is empty, rx_fifo_empty_status is triggered",UVM_LOW)
		else
			`uvm_error(get_type_name(),"RX FIFO is empty, rx_fifo_empty_status must be triggered")

		// reconfig VIP to change frame
		uart_config2.data_width  = 5;
		uart_config2.parity_mode = uart_configuration::PARITY_ODD;
		uart_config2.stop_bits   = 2;
		`uvm_info(get_type_name(),"UART agent updating...",UVM_LOW)
		env.uart_agt.update_config(uart_config2);
		// reconfig DUT to change frame
		regmodel.LCR.write(status,32'h2C); #50ns;

		// SEOCOND SEQUENCE
		seq2 = vip_tx_sequence::type_id::create("seq2");
		seq2.start(env.uart_agt.uart_seqcer);
		if(uart_vif.interrupt === 0) // check rx fifo empty interrupt
			`uvm_info(get_type_name(),"RX FIFO has data, interrupt is cleared",UVM_LOW)
		else
			`uvm_error(get_type_name(),"RX FIFO has data, interrupt must be cleared")
		regmodel.FSR.read(status,rdata); #1;
		if(rdata[3] === 0) // check rx fifo empty status
			`uvm_info(get_type_name(),"RX FIFO has empty, rx_fifo_empty_status is cleared",UVM_LOW)
		else
			`uvm_error(get_type_name(),"RX FIFO has empty, rx_fifo_empty_status must be cleared")
		if(rdata[4] === 0) // check parity error status
			`uvm_info(get_type_name(),"RX FIFO has empty, rx_fifo_empty_status is cleared",UVM_LOW)
		else
			`uvm_error(get_type_name(),"RX FIFO has empty, rx_fifo_empty_status must be cleared")
		
		regmodel.RBR.read(status,rdata);
		env.uart_sb.update_rbr_data(rdata);
		#1ns;
		if(uart_vif.interrupt === 1) // check rx fifo empty interrupt after read RBR
			`uvm_info(get_type_name(),"RX FIFO is empty, interrupt is trigger to 1",UVM_LOW)
		else
			`uvm_error(get_type_name(),"RX FIFO is empty, expect interrupt trigger to 1 but not")
		regmodel.FSR.read(status,rdata); #1;
		if(rdata[3] === 1) // check rx fifo empty status after read RBR
			`uvm_info(get_type_name(),"RX FIFO is empty, rx_fifo_empty_status is triggered",UVM_LOW)
		else
			`uvm_error(get_type_name(),"RX FIFO is empty, rx_fifo_empty_status must be triggered")
		
		#((1.0e9/uart_config2.baud_rate)*1ns);

		phase.drop_objection(this);
	endtask

endclass
