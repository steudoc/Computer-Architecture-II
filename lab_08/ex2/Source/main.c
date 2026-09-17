#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

extern unsigned int _Input_Values;
extern unsigned char _NUM_VALUES;

// prototype asm function (magic step)
int fast_magic_calc(int input_float_as_int);

// helper: bit-safe
static float bits_to_float(uint32_t u) {
	float f;
	memcpy(&f, &u, sizeof(f));
	return f;
}

int main(void){
	// pointer to input asm table
	volatile uint32_t *vector = (volatile uint32_t *)&_Input_Values;
	const uint8_t N = *(volatile uint8_t*)&_NUM_VALUES;
	int i;
	
	// errors vector
	float ERRORS[8];
	/*if (N > sizeof(ERRORS)/sizeof(ERRORS[0])) {
		while(1);
	}*/
	
	for (i = 0; i< N; ++i) {
		// loads bits
		uint32_t x_bits = vector[i];
		float x = bits_to_float(x_bits);
		
		// magic step in asm
		int y0_bits = fast_magic_calc((int)x_bits);
		float y = bits_to_float((uint32_t)y0_bits);
		
		// Newton-Raphson: y = y * (1.5 - 0.5*x * y*y)
		float x2 = 0.5f * x;
		y = y * (1.5f - (x2 * y * y));
		
		// standard: 1/sqrt(x)
		float standard = 1.0f / sqrtf(x);
		
		// error: fast - standard
		ERRORS[i] = y - standard;
	}
	
	for (i = 0; i < N; ++i) {
		printf("ERR[%d] = %.8f\n", i, ERRORS[i]);
	}
		
	while(1);
}
