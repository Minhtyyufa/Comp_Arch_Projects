# Final Project for ECE-251
Minh-Thai Nguyen and Sophie Jaro

This program uses PMDAS to evaluate an expression, supporting floating point numbers as well.

To run the program first make the executable by typing:

    make

If the executable already exists, you might have to remove it first by typing:

    make clean
    
Once the executable is made, run the program by typing:

    ./final_proj "<expression>"
    
It should be noted that the quotes are needed to recognize all expressions (especially those that start with parentheses).

Example:
    
    ./final_proj "(32+43)*3/(4-2)"
    
The program should then output the result. In this case it would be:

    The result is: 112.500000
    
If an invalid expression is entered [ex. (32)( ], the program should output the error message:

    ERROR: Bad equation format
    
If an invalid character is detected [ex. 47$32], the program should output the error message:
    
    ERROR: Character not recognized
    
If an invalid number format is entered [ex. 32.3232.322], the program should output the error message:

    ERROR: Bad number format
    

    
