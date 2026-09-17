

int main(void){

	unsigned int result;
	
	__asm volatile("SVC #0x0A\n");				// scatena l'eccezione SVC
	
	while(1);
}


