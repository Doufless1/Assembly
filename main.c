#include <stdio.h>
#include <string.h>

int main() {
    int i = 6;                   // Last valid index of "batman" (0-based)
    char* batman = "batman";     // Pointer to the string "batman"

    while (i >= 0) {             // Loop through the string backwards
        if (batman[i] == 'b') {  // Compare to a single character
            printf("This is batman \n");
            break;               // Exit the loop when condition is met
        }
        --i;                     // Decrement the index
    }

    return 0;                    // End the program
}

