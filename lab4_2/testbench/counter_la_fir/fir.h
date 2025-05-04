#ifndef __FIR_H__
#define __FIR_H__

#define N 11
#define data_length 64

#define reg_fir_control       (*(volatile uint32_t*)0x30000000)
#define reg_fir_data_length   (*(volatile uint32_t*)0x30000010)
#define reg_fir_tap_num       (*(volatile uint32_t*)0x30000014)

#define reg_fir_coeff_0   (*(volatile uint32_t*)0x30000080)
#define reg_fir_coeff_1   (*(volatile uint32_t*)0x30000084)
#define reg_fir_coeff_2   (*(volatile uint32_t*)0x30000088)
#define reg_fir_coeff_3   (*(volatile uint32_t*)0x3000008c)
#define reg_fir_coeff_4   (*(volatile uint32_t*)0x30000090)
#define reg_fir_coeff_5   (*(volatile uint32_t*)0x30000094)
#define reg_fir_coeff_6   (*(volatile uint32_t*)0x30000098)
#define reg_fir_coeff_7   (*(volatile uint32_t*)0x3000009c)
#define reg_fir_coeff_8   (*(volatile uint32_t*)0x300000a0)
#define reg_fir_coeff_9   (*(volatile uint32_t*)0x300000a4)
#define reg_fir_coeff_10  (*(volatile uint32_t*)0x300000a8)

#define reg_fir_x       (*(volatile uint32_t*)0x30000040)
#define reg_fir_y       (*(volatile uint32_t*)0x30000044)

int taps[N] = {0,-10,-9,23,56,63,56,23,-9,-10,0};
int outputsignal[data_length];

#endif
