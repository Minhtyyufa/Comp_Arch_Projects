# Project 2: Read and Write to a File and Sort 

Minh-Thai Nguyen and Sophie Jaro
This program sorts an array of up to 100 elements from a given input file and outputs the result to an output file.

To run the program first make the executable by typing:

    make

into the terminal. Then run the program by typing:

    ./project_2

The user will then be prompted for the input file:

    What is the input file name?: 

The user should then input their input file. If the input file cannot be found in the directory the error message of

    ERROR: Could not find the input file
    
will display. If the file contains too many elements than the error message of

    ERROR: File is too big
 
will display. Otherwise, the data from the input file will be stored and sorted. The program will then prompt the user for an output file:

    What is the output file name?:
    
If there is no output file with that name, a new one will be created and the program will output the sorted array into the file. 

The input file should be formatted such that each integer is separated by a new line character. There should also be no empty lines between integers. The output file will be formatted in the same way the input file should be formatted. 
Sample input and output files have been provided at https://github.com/Minhtyyufa/Comp_Arch_Projects/edit/master/project2.


