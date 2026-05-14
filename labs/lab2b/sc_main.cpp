#include "systemc.h"
#include "functions.h"
#include "fdct.h"
#include "idct.h"
//#include inverse module

#define NS *1e-9 // use this constant to make sure that the clock signal is in nanoseconds

int sc_main(int argc, char *argv[]) {
	char choice;

	sc_signal<FILE *> sc_input; 	// input file pointer signal
	sc_signal<FILE *> sc_output;	// output file pointer signal

	sc_signal<double> dct_data[8][8]; // signal to the dc transformed data
	sc_signal<double> cosine_tbl[8][8]; // signal for the cosine table values

	// These are decompression signals
	sc_signal<double> idct_in[8][8];
	sc_signal<unsigned char> idct_out[8][8];

	sc_signal<bool> clk1, clk2; 		// clock signal for FDCT (also need a 2nd clock for IDCT)

	FILE *input, *output; // input and output file pointers
	double cosine[8][8]; // the cosine table
	double data[8][8]; // the data read from the signals, which will be zigzagged
	


	if (argc == 4) {
		if (!(input = fopen(argv[1], "rb"))) // error occurred while trying to open file
			printf("\nSystemC JPEG LAB:\ncannot open file '%s'\n", argv[1]), exit(1);

		if (!(output = fopen(argv[2], "wb"))) // rror occurred while trying to create file
			printf("\nSystemC JPEG LAB:\ncannot create file '%s'\n", argv[2]), exit(1);

		// copy the input and output file pointer onto the respective ports
		sc_input.write(input);
		sc_output.write(output);

		choice = *argv[3];
	} else
		fprintf(stderr, "\nSystemC JPEG LAB: insufficient command line arguments\n"
			"usage:  ./sc_jpeg.x [input file] [output file] [(C)ompress or (D)ecompress]\n")
				, exit(1);

	// write BMP header from input to output
	write_read_header(input, output);

	// cosine table and drive onto signals
	make_cosine_tbl(cosine);
	for (unsigned char i = 0; i < 8; i++)
		for (unsigned char j = 0; j < 8; j++)
			cosine_tbl[i][j].write(cosine[i][j]);

	// hardware modules (MUST be in sc_main scope, not inside if/while)
	fdct FDCT("FDCT");
	idct IDCT("IDCT");

    	// bind ports - FDCT
    	FDCT.sc_input(sc_input);
    	FDCT.clk(clk1);
    	for (unsigned char i = 0; i < 8; i++)
        	for (unsigned char j = 0; j < 8; j++) {
            	FDCT.out64[i][j](dct_data[i][j]);
            	FDCT.fcosine[i][j](cosine_tbl[i][j]);
        	}

    	// bind ports - IDCT
    	IDCT.clk(clk2);
    	for (unsigned char i = 0; i < 8; i++)
        	for (unsigned char j = 0; j < 8; j++) {
            	IDCT.in64[i][j](idct_in[i][j]);
            	IDCT.icosine[i][j](cosine_tbl[i][j]);
            	IDCT.out64[i][j](idct_out[i][j]);
        	}
	// because compression and decompression are two different processes, we must use
	// two different clocks, to make sure that when we want to compress, we only compress
	// and dont decompress by mistake

	sc_start(SC_ZERO_TIME); 	// initialize the clock

	if ((choice == 'c') || (choice == 'C')) { // for compression
		// cycle the clock for as long as there is something to be read from the input file
		while (!(feof(input))) { 
			// create the FDCT clock signal
			clk1.write(1);		// convert the clock to high
			sc_start(10, SC_NS);	// cycle the high for 10 nanoseconds
			clk1.write(0);		// start the clock as low
			sc_start(10, SC_NS);	// cycle the low for 10 nanoseconds

			// read back signals from module (DCT coefficients)
			for (unsigned char i = 0; i < 8; i++)
                		for (unsigned char j = 0; j < 8; j++)
                    			data[i][j] = dct_data[i][j].read();

			// zigzag and quantize the outputted data
			// will write out to file (see functions.h)
			zigzag_quant(data, output);


		}
	} else if ((choice == 'd') || (choice == 'D')) { // for decompression
		while (!(feof(input))) {
			// unzigzag and inverse quatize input file and result will be placed in data
			// (reading compressed block)
			unzigzag_iquant(data, input);
			
			//write unzigzag data to ports
			// (Drive IDCT inputs)
			for (unsigned char i = 0; i < 8; i++)
                		for (unsigned char j = 0; j < 8; j++)
                    			idct_in[i][j].write(data[i][j]);
		
			clk2.write(1);		// convert the clock to high
			sc_start(10, SC_NS);	// cycle the high for 10 nanoseconds
			clk2.write(0);		// start the clock as low
			sc_start(10, SC_NS);	// cycle the low for 10 nanoseconds
			
			//read idct data (pixels) from ports & write to output file (BMP)
			unsigned char out_block[8][8];
            		for (unsigned char i = 0; i < 8; i++){
                		for (unsigned char j = 0; j < 8; j++){
                    			out_block[i][j] = idct_out[i][j].read();
				}
			}
            		fwrite(out_block, 1, 64, output);
		}
		
	}	
	fclose(sc_input.read());
	fclose(sc_output.read());

	return 0;
}
