#include <Windows.h>
#include <iostream>


int main() {
    const int PAGESIZE = 4096; // Размер страницы в байтах
    const int PAGES = 256; // Количество страниц
    const int ARRAYSIZE = PAGES * PAGESIZE / sizeof(int); // Размер массива

    int* memory;
    
    memory = (int*)VirtualAlloc(NULL, PAGES * PAGESIZE, MEM_COMMIT, PAGE_READWRITE);

    for (int i = 0; i < ARRAYSIZE; ++i) {
        memory[i] = i;
    }

    memory[0] = 0xd1;//С
    //memory[1] = 0xE0;//а
    //memory[2] = 0xEC;//м

    //Страница - 209(d1)
    //Смещение - 3598(e0e) - 3596 - e0c
    //Адрес - 0x0000000000000EDD

    VirtualFree(memory, 0, MEM_RELEASE);

    return 0;
}