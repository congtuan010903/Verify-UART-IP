class transmit_7_odd_2_test extends uart_base_test;
	`uvm_component_utils(transmit_7_odd_2_test)
	
	uvm_status_e       status;
	uart_configuration uart_config2;
	vip_tx_sequence		 seq;

	//----------------------------------------
	// Constructor
	//----------------------------------------
	function new(string name = "transmit_7_odd_2_test", uvm_component parent);
		super.new(name,parent);
	endfunction

	//-------------------------------------
	// run phase
	//-------------------------------------
	virtual task run_phase(uvm_phase phase);
		bit[6:0]  transmit_data;
		bit[31:0] rdata;
		phase.raise_objection(this);
		
		// config VIP
		uart_config2 = uart_configuration::type_id::create("uart_config2");
		uart_config2.baud_rate   = 115200;
		uart_config2.data_width  = 7;
		uart_config2.parity_mode = uart_configuration::PARITY_ODD;
		uart_config2.stop_bits   = 2;
		`uvm_info(get_type_name(),"UART agent updating...",UVM_LOW)
		env.uart_agt.update_config(uart_config2);
		// config DUT
		regmodel.IER.write(status,32'h02); #1ns;
		if(uart_vif.interrupt === 1)
			`uvm_info(get_type_name(),"TX FIFO empty, interrupt trigger to 1",UVM_LOW)
		else
			`uvm_error(get_type_name(),"TX FIFO empty, interrupt must be trigger")

		regmodel.MDR.write(status,32'h00); #50ns;
		regmodel.DLL.write(status,32'h36); #50ns;
		regmodel.LCR.write(status,32'h2E); #50ns;

		// FIRST FRAME
		transmit_data = $urandom();
		regmodel.TBR.write(status,transmit_data);
		@(posedge ahb_vif.HCLK); #1ns;
		if(uart_vif.interrupt === 0)
			`uvm_info(get_type_name(),"TX FIFO has data, interrupt is cleared",UVM_LOW)
		else
			`uvm_error(get_type_name(),"TX FIFO has data, interrupt must be cleared")
		@(posedge ahb_vif.HCLK); #1ns;
		if(uart_vif.interrupt === 1)
			`uvm_info(get_type_name(),"TX FIFO empty, interrupt is triggered",UVM_LOW)
		else
			`uvm_error(get_type_name(),"TX FIFO empty, interrupt must be triggered")
		regmodel.FSR.read(status,rdata);
		if(rdata[1] === 1)
			`uvm_info(get_type_name(),"TX FIFO empty, tx fifo empty status triggered",UVM_LOW)
		else
			`uvm_error(get_type_name(),"TX FIFO empty, tx fifo empty status must be triggered")

		// SECOND FRAME
		transmit_data = $urandom();
		regmodel.TBR.write(status,transmit_data);
		// check tx fifo has data
		@(posedge ahb_vif.HCLK); #1ns;
		if(uart_vif.interrupt === 0)
			`uvm_info(get_type_name(),"TX FIFO has data, interrupt is cleared",UVM_LOW)
		else
			`uvm_error(get_type_name(),"TX FIFO has data, interrupt must be cleared")
		regmodel.FSR.read(status,rdata);
		if(rdata[1] === 0)
			`uvm_info(get_type_name(),"TX FIFO has data, tx fifo empty status is cleared",UVM_LOW)
		else
			`uvm_error(get_type_name(),"TX FIFO has data, tx fifo empty status must be cleared")
			
		#((1.0e9/uart_config2.baud_rate)*26ns);

		phase.drop_objection(this);
	endtask

endclass
