#include <iostream>
#include <Windows.h>


int main() {
    for (long long i = 0; i < 1e9; ++i) {

        Sleep(100);
    }
    std::cout << "Finish\n";
    return 0;
}
