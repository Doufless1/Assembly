


/// @brief Converts num to string, returns number of digits
/// @param num the number to Convert
/// @param buf the array to store the result in
/// @return the number of digits
int toascii(int num, char buf[]) {
  while (num > 0) {
    int digit = num % 10;
    char c = digit + '0';
    num = num / 10;
  }
}
