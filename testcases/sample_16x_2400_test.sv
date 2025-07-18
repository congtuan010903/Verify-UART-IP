class sample_16x_2400_test extends uart_base_test;
	`uvm_component_utils(sample_16x_2400_test)
	
	uvm_status_e       status;
	uart_configuration new_config;
	vip_tx_sequence    seq;

	//----------------------------------------
	// Constructor
	//----------------------------------------
	function new(string name = "sample_16x_2400_test", uvm_component parent);
		super.new(name,parent);
	endfunction

	//-------------------------------------
	// run phase
	//-------------------------------------
	virtual task run_phase(uvm_phase phase);
		bit[31:0] rdata;
		phase.raise_objection(this);
	
		wait(ahb_vif.HRESETn === 1);

		// config VIP
		new_config             = uart_configuration::type_id::create("new_config");
		new_config.baud_rate   = 2400;
		new_config.data_width  = 8;
		new_config.parity_mode = uart_configuration::PARITY_NONE;
		new_config.stop_bits   = 2;
		`uvm_info(get_type_name(),"UART agent updating...",UVM_LOW)
		env.uart_agt.update_config(new_config);
		// config DUT
		regmodel.IER.write(status,32'h02); #1ns;
		if(uart_vif.interrupt === 1)
			`uvm_info(get_type_name(),"TX FIFO empty, Interupt is triggered",UVM_LOW)
		else
			`uvm_error(get_type_name(),"TX FIFO empty, Interrupt must be trigger")

		regmodel.MDR.write(status,32'h00); #50ns;
		regmodel.DLL.write(status,32'h2C); #50ns;
		regmodel.DLH.write(status,32'h0A); #50ns;
		regmodel.LCR.write(status,32'h37); #50ns;
		
		fork
			vip_send();
			dut_send();
		join
		
		// read RBR
		repeat(5) begin
			regmodel.RBR.read(status,rdata);
			env.uart_sb.update_rbr_data(rdata);
		end

		phase.drop_objection(this);
	endtask

	//------------------------------------
	// Task: DUT send
	//------------------------------------
	task dut_send();
		bit[7:0] data1,data2;
		// random data to transmit
		data1 = $urandom();
		do
			data2 = $urandom();
		while(data1 == data2);

		// Write first data to TBR
		regmodel.TBR.write(status,data1);
		@(posedge ahb_vif.HCLK); #1ns; 
		if(uart_vif.interrupt === 0)
			`uvm_info(get_type_name(),"TX FIFO has data, Interrupt is cleared",UVM_LOW)
		else
			`uvm_error(get_type_name(),"TX FIFO has data, Interrupt must be cleared")
		@(posedge ahb_vif.HCLK); #1ns;
		if(uart_vif.interrupt === 1)
			`uvm_info(get_type_name(),"TX FIFO empty, Interrupt is triggered",UVM_LOW)
		else
			`uvm_error(get_type_name(),"TX FIFO empty, Interrupt must be triggered")

		// Write second data to TBR
		regmodel.TBR.write(status,data2);
		@(posedge ahb_vif.HCLK); #1ns; 
		if(uart_vif.interrupt === 0)
			`uvm_info(get_type_name(),"TX FIFO has data, Interrupt is cleared",UVM_LOW)
		else
			`uvm_error(get_type_name(),"TX FIFO has data, Interrupt must be cleared")
		#((1.0e9/new_config.baud_rate)*12ns); // wait for DUT transmit first frame successfully
		if(uart_vif.interrupt === 1)
			`uvm_info(get_type_name(),"TX FIFO empty, Interrupt is triggered",UVM_LOW)
		else
			`uvm_error(get_type_name(),"TX FIFO empty, Interrupt must be triggered")
	endtask

	//-------------------------------
	// Task: VIP send
	//-------------------------------
	task vip_send();
		// start sequence to VIP send data
		repeat(5) begin
			seq = vip_tx_sequence::type_id::create("seq");
			seq.start(env.uart_agt.uart_seqcer);
		end
	endtask

endclass
