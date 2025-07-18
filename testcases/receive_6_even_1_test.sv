class receive_6_even_1_test extends uart_base_test;
	`uvm_component_utils(receive_6_even_1_test)
	
	uvm_status_e       status;
	uart_configuration uart_config2;
	vip_tx_sequence		 seq;

	//----------------------------------------
	// Constructor
	//----------------------------------------
	function new(string name = "receive_6_even_1_test", uvm_component parent);
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
		uart_config2.data_width  = 6;
		uart_config2.parity_mode = uart_configuration::PARITY_EVEN;
		uart_config2.stop_bits   = 1;
		`uvm_info(get_type_name(),"UART agent updating...",UVM_LOW)
		env.uart_agt.update_config(uart_config2);
		// config DUT
		regmodel.IER.write(status,32'h18); #1ns;
		if(uart_vif.interrupt === 1)
			`uvm_info(get_type_name(),"Interrupt trigger because rx fifo is empty",UVM_LOW)
		else
			`uvm_error(get_type_name(),"RX FIFO is empty, expect interrupt trigger to 1 but not")

		regmodel.MDR.write(status,32'h00); #(50*1ns);
		regmodel.DLL.write(status,32'h36); #(50*1ns);
		regmodel.LCR.write(status,32'h39); #(50*1ns);

		seq = vip_tx_sequence::type_id::create("seq");
		seq.start(env.uart_agt.uart_seqcer);
		if(uart_vif.interrupt === 0)
			`uvm_info(get_type_name(),"RX FIFO has data, interrupt is cleared",UVM_LOW)
		else
			`uvm_error(get_type_name(),"RX FIFO has data, interrupt must be cleared")
		regmodel.FSR.read(status,rdata); #1;
		if(rdata[4] !== 0)
			`uvm_error(get_type_name(),"Parity no error, expect parity_error_status not trigger")
		
		regmodel.RBR.read(status,rdata);
		env.uart_sb.update_rbr_data(rdata);
		#1ns;
		if(uart_vif.interrupt === 1)
			`uvm_info(get_type_name(),"RX FIFO is empty, interrupt is trigger to 1",UVM_LOW)
		else
			`uvm_error(get_type_name(),"RX FIFO is empty, expect interrupt trigger to 1 but not")

		#((1.0e9/uart_config2.baud_rate)*1ns);
	

		phase.drop_objection(this);
	endtask

endclass
