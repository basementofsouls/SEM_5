#include <windows.h>
#include <iostream>

void sh(HANDLE heap) {
   /* while (true) {
        SendMessage(HWND_BROADCAST, WM_SYSCOMMAND, SC_MONITORPOWER, (LPARAM)2);
        Sleep(4000);
    }*/
    PROCESS_HEAP_ENTRY entry;
    entry.lpData = NULL;
    SIZE_T totalSize = 0, allocatedSize = 0, unallocatedSize = 0;

    while (HeapWalk(heap, &entry) != FALSE) {
        totalSize += entry.cbData;
        if (entry.wFlags & PROCESS_HEAP_ENTRY_BUSY) {
            allocatedSize += entry.cbData;
        }
        else {
            unallocatedSize += entry.cbData;
        }
    }

    std::cout << "����� ������ heap: " << totalSize << "\n";
    std::cout << "������ �������������� ������� ������ heap: " << allocatedSize << "\n";
    std::cout << "������ ���������������� ������� ������ heap: " << unallocatedSize << "\n";
}

int main() {
    SetConsoleOutputCP(1251);
    const SIZE_T HEAPSIZE = 4 * 1024 * 1024; // 4MB
    HANDLE heap = HeapCreate(0, HEAPSIZE, 0);
    sh(heap);

    const int ARRAYSIZE = 300000;
    int* array = (int*)HeapAlloc(heap, 0, ARRAYSIZE * sizeof(int));

    sh(heap);

    HeapFree(heap, 0, array);
    HeapDestroy(heap);

    return 0;
}
/*
����� �������� ���������������� heap � �������������� �������� 4MB �� �������, 
��� ����� ������ heap ����� 4MB, � ������ �������������� ������� ������ ����� 0, 
��������� ��� �� ���� ��������� ������� ��������� ������. ����� ���������� ������� 
� heap � ������� ������� HeapAlloc ������ �������������� ������� ������ ����������
� ������ ���������������� ������� ������ ����������. ����� ������������ ������ � 
������� ������� HeapFree ������� heap �������� � �������� ���������.
*/