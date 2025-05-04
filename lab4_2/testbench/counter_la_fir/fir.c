#include <defs.h>
#include "fir.h"


void __attribute__ ( ( section ( ".mprjram" ) ) ) initfir() {
	//initial your fir

	reg_fir_data_length = data_length;
	reg_fir_tap_num = N;	
	
	reg_fir_coeff_0 = taps[0];
	reg_fir_coeff_1 = taps[1]; 
	reg_fir_coeff_2 = taps[2];   
	reg_fir_coeff_3 = taps[3];  
	reg_fir_coeff_4 = taps[4]; 
	reg_fir_coeff_5 = taps[5]; 
	reg_fir_coeff_6 = taps[6];  
	reg_fir_coeff_7 = taps[7];   
	reg_fir_coeff_8 = taps[8];  
	reg_fir_coeff_9 = taps[9];   
	reg_fir_coeff_10 = taps[10];   
	
}

int* __attribute__ ( ( section ( ".mprjram" ) ) ) fir(){

	initfir();
	int i = 0;		
	reg_fir_control = 0x00000001; // setting ap start;
	
	reg_mprj_datal  = 0x00A50000;
	
	for (i=0; i<data_length;){
		reg_fir_x = i+1;	
		i++;	
		outputsignal[i] = reg_fir_y;
	}
	
	
	//write down your fir
	return outputsignal;
	
	
}
		
