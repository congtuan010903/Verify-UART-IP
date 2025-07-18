class dis_tx_fifo_full_interrupt_test extends uart_base_test;
	`uvm_component_utils(dis_tx_fifo_full_interrupt_test)
	
	uvm_status_e       status;
	uart_configuration uart_config2;
	vip_tx_sequence		 seq;

	//----------------------------------------
	// Constructor
	//----------------------------------------
	function new(string name = "dis_tx_fifo_full_interrupt_test", uvm_component parent);
		super.new(name,parent);
	endfunction

	//-------------------------------------
	// run phase
	//-------------------------------------
	virtual task run_phase(uvm_phase phase);
		bit[7:0]  transmit_data;
		bit[31:0] rdata;
		phase.raise_objection(this);

		transmit_data = $urandom();
		
		// config VIP
		uart_config2 = uart_configuration::type_id::create("uart_config2");
		uart_config2.baud_rate   = 115200;
		uart_config2.data_width  = 8;
		uart_config2.parity_mode = uart_configuration::PARITY_NONE;
		uart_config2.stop_bits   = 1;
		`uvm_info(get_type_name(),"UART agent updating...",UVM_LOW)
		env.uart_agt.update_config(uart_config2);
		// config DUT
		regmodel.IER.write(status,32'h00); #1ns;
		if(uart_vif.interrupt === 0)
			`uvm_info(get_type_name(),"Interrupt is disable, interrupt = 0",UVM_LOW)
		else
			`uvm_error(get_type_name(),"Interrupt is disable, interrupt must not trigger")
		regmodel.FSR.read(status,rdata);
		if(rdata[0] === 0)
			`uvm_info(get_type_name(),"TX FIFO not full, tx fifo full status = 0",UVM_LOW)
		else
			`uvm_error(get_type_name(),"TX FIFO not full, tx fifo full status must equal 0")

		regmodel.MDR.write(status,32'h00); #(50*1ns);
		regmodel.DLL.write(status,32'h36); #(50*1ns);
		regmodel.LCR.write(status,32'h23); #(50*1ns);

		// FIRST FRAME
		regmodel.TBR.write(status,transmit_data);
		if(uart_vif.interrupt === 0)
			`uvm_info(get_type_name(),"Interrupt is disable, interrupt = 0",UVM_LOW)
		else
			`uvm_error(get_type_name(),"Interrupt is disable, interrupt must not trigger")
		regmodel.FSR.read(status,rdata);
		if(rdata[0] === 0)
			`uvm_info(get_type_name(),"TX FIFO not full, tx fifo full status = 0",UVM_LOW)
		else
			`uvm_error(get_type_name(),"TX FIFO not full, tx fifo full status must equal 0")
		
		// 16 FRAME
		repeat(16) regmodel.TBR.write(status,transmit_data);
		// check tx fifo has data
		@(posedge ahb_vif.HCLK); #1ns;
		if(uart_vif.interrupt === 1)
			`uvm_error(get_type_name(),"TX FIFO full but interrupt disable, interrupt cannot trigger")
		regmodel.FSR.read(status,rdata);
		if(rdata[0] === 1)
			`uvm_info(get_type_name(),"TX FIFO full, tx fifo full status is trigger",UVM_LOW)
		else
			`uvm_error(get_type_name(),"TX FIFO full, tx fifo full status must be trigger")
			
		#((1.0e9/uart_config2.baud_rate)*13*17ns);
		phase.drop_objection(this);
	endtask

endclass
