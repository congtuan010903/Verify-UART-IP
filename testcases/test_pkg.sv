package test_pkg;
	import uvm_pkg::*;
	import ahb_pkg::*;
	import uart_pkg::*;
	import env_pkg::*;
	import seq_pkg::*;
	import uart_regmodel_pkg::*;

	`include"uart_base_test.sv";
	// register test
	`include"default_value_test.sv";
	`include"read_write_test.sv";
	`include"reserved_region_test.sv";
	`include"read_w1c_test.sv";

	// 13x
	`include"sample_13x_2400_test.sv";
	`include"sample_13x_4800_test.sv";
	`include"sample_13x_9600_test.sv";
	`include"sample_13x_19200_test.sv";
	`include"sample_13x_38400_test.sv";
	`include"sample_13x_76800_test.sv";
	`include"sample_13x_115200_test.sv";
	`include"sample_13x_custom_test.sv";

	// 16x
	`include"sample_16x_2400_test.sv";
	`include"sample_16x_4800_test.sv";	
	`include"sample_16x_9600_test.sv";
	`include"sample_16x_19200_test.sv";
	`include"sample_16x_38400_test.sv";
	`include"sample_16x_76800_test.sv";
	`include"sample_16x_115200_test.sv";
	`include"sample_16x_custom_test.sv";

	// receive only
	`include"receive_5_none_1_test.sv";
	`include"receive_5_none_2_test.sv";
	`include"receive_5_odd_1_test.sv";
	`include"receive_5_odd_2_test.sv";
	`include"receive_5_even_1_test.sv";
	`include"receive_5_even_2_test.sv";
	`include"receive_6_none_1_test.sv";
	`include"receive_6_none_2_test.sv";
	`include"receive_6_odd_1_test.sv";
	`include"receive_6_odd_2_test.sv";
	`include"receive_6_even_1_test.sv";
	`include"receive_6_even_2_test.sv";
	`include"receive_7_none_1_test.sv";
	`include"receive_7_none_2_test.sv";
	`include"receive_7_odd_1_test.sv";
	`include"receive_7_odd_2_test.sv";
	`include"receive_7_even_1_test.sv";
	`include"receive_7_even_2_test.sv";
	`include"receive_8_none_1_test.sv";
	`include"receive_8_none_2_test.sv";
	`include"receive_8_odd_1_test.sv";
	`include"receive_8_odd_2_test.sv";
	`include"receive_8_even_1_test.sv";
	`include"receive_8_even_2_test.sv";
	`include"receive_dynamic_frame_test.sv";
	`include"receive_dynamic_baudrate_test.sv";
	// transmit only
	`include"transmit_5_none_1_test.sv";
	`include"transmit_5_none_2_test.sv";
	`include"transmit_5_odd_1_test.sv";
	`include"transmit_5_odd_2_test.sv";
	`include"transmit_5_even_1_test.sv";
	`include"transmit_5_even_2_test.sv";
	`include"transmit_6_none_1_test.sv";
	`include"transmit_6_none_2_test.sv";
	`include"transmit_6_odd_1_test.sv";
	`include"transmit_6_odd_2_test.sv";
	`include"transmit_6_even_1_test.sv";
	`include"transmit_6_even_2_test.sv";
	`include"transmit_7_none_1_test.sv";
	`include"transmit_7_none_2_test.sv";
	`include"transmit_7_odd_1_test.sv";
	`include"transmit_7_odd_2_test.sv";
	`include"transmit_7_even_1_test.sv";
	`include"transmit_7_even_2_test.sv";
	`include"transmit_8_none_1_test.sv";
	`include"transmit_8_none_2_test.sv";
	`include"transmit_8_odd_1_test.sv";
	`include"transmit_8_odd_2_test.sv";
	`include"transmit_8_even_1_test.sv";
	`include"transmit_8_even_2_test.sv";
	`include"transmit_dynamic_baudrate_test.sv";
	`include"transmit_dynamic_frame_test.sv";
	// full duplex
	`include"full_5_none_1_test.sv";
	`include"full_5_none_2_test.sv";
	`include"full_5_odd_1_test.sv";
	`include"full_5_odd_2_test.sv";
	`include"full_5_even_1_test.sv";
	`include"full_5_even_2_test.sv";
	`include"full_6_none_1_test.sv";
	`include"full_6_none_2_test.sv";
	`include"full_6_odd_1_test.sv";
	`include"full_6_odd_2_test.sv";
	`include"full_6_even_1_test.sv";
	`include"full_6_even_2_test.sv";	
	`include"full_7_none_1_test.sv";
	`include"full_7_none_2_test.sv";
	`include"full_7_odd_1_test.sv";
	`include"full_7_odd_2_test.sv";
	`include"full_7_even_1_test.sv";
	`include"full_7_even_2_test.sv";
	`include"full_8_none_1_test.sv";
	`include"full_8_none_2_test.sv";
	`include"full_8_odd_1_test.sv";
	`include"full_8_odd_2_test.sv";
	`include"full_8_even_1_test.sv";
	`include"full_8_even_2_test.sv";
	`include"full_dynamic_frame_test.sv";
	`include"full_dynamic_baudrate_test.sv";	

	// interrupt test
	`include"parity_interrupt_test.sv";
	`include"dis_parity_interrupt_test.sv";
	`include"rx_fifo_empty_interrupt_test.sv";
	`include"dis_rx_fifo_empty_interrupt_test.sv";
	`include"rx_fifo_full_interrupt_test.sv";
	`include"dis_rx_fifo_full_interrupt_test.sv";
	`include"tx_fifo_empty_interrupt_test.sv";
	`include"dis_tx_fifo_empty_interrupt_test.sv";
	`include"tx_fifo_full_interrupt_test.sv";
	`include"dis_tx_fifo_full_interrupt_test.sv";	
	
	// inject error test
	`include"parity_missmatch_test.sv";
	`include"data_width_missmatch_test.sv";
	`include"baudrate_missmatch_test.sv";
	`include"stopbit_missmatch_test.sv";

	// error handle test
	`include"write_when_tx_fifo_full_test.sv";

endpackage
