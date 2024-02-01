#include <Windows.h>
#include <iostream>


int main() {
    const int PAGESIZE = 4096; // ������ �������� � ������
    const int PAGES = 256; // ���������� �������
    const int ARRAYSIZE = PAGES * PAGESIZE / sizeof(int); // ������ �������

    int* memory;
    
    memory = (int*)VirtualAlloc(NULL, PAGES * PAGESIZE, MEM_COMMIT, PAGE_READWRITE);

    for (int i = 0; i < ARRAYSIZE; ++i) {
        memory[i] = i;
    }

    memory[0] = 0xd1;//�
    //memory[1] = 0xE0;//�
    //memory[2] = 0xEC;//�

    //�������� - 209(d1)
    //�������� - 3598(e0e) - 3596 - e0c
    //����� - 0x0000000000000EDD

    VirtualFree(memory, 0, MEM_RELEASE);

    return 0;
}