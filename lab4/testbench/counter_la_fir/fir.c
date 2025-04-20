#include "fir.h"

void __attribute__ ( ( section ( ".mprjram" ) ) ) initfir() {
	//initial your fir
}

int* __attribute__ ( ( section ( ".mprjram" ) ) ) fir(){
	initfir();
	
	int counter = 0;
	int input_number = 0;
	int test_number = 11; 
	int cal_result = 0;
	int loop = 0;
	
	for (input_number=0; input_number<test_number;input_number++) {
		cal_result = 0;
		counter = 0;
		loop = 0;
		if (input_number < N) {
			loop = input_number+1;
		}
		else {
			loop = N;
		}
		for (counter=0; counter < loop; counter++){			
			cal_result = inputsignal[input_number-counter]*taps[counter] + cal_result;
		} 
		outputsignal[input_number] = cal_result; 
	}
	
	//int i = 0;
	//for (i=0; i<test_number;i++) {
        //printf("result: %d\n",  outputsignal[i]);
	//}
	
	return outputsignal;
}
		
