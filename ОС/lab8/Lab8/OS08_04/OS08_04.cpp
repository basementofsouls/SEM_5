#include <windows.h>
#include <iostream>

void sh(HANDLE heap) {
    SetConsoleOutputCP(1251);
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

    std::cout << "ќбщий размер heap: " << totalSize << "\n";
    std::cout << "–азмер распределенной области пам€ти heap: " << allocatedSize << "\n";
    std::cout << "–азмер нераспределенной области пам€ти heap: " << unallocatedSize << "\n";
}

int main() {
    HANDLE heap = GetProcessHeap();
    sh(heap);
    /*
    ‘ункци€ sh использует функцию HeapWalk дл€ обхода всех записей в heap. 
    ќна суммирует размеры всех записей дл€ получени€ общего размера heap и 
    суммирует размеры записей, помеченных как зан€тые, дл€ получени€ размера 
    распределенной области пам€ти. –азмер нераспределенной области пам€ти вычисл€етс€ 
    как разница между общим размером и размером распределенной области.
    */
    const int ARRAYSIZE = 300000;
    int* array = new int[ARRAYSIZE];

    sh(heap);
    /*
    ‘ункци€ sh вызываетс€ дважды: до и после размещени€ массива. Ёто позвол€ет 
    увидеть, как размещение массива вли€ет на состо€ние heap.
    */

    delete[] array;
    /*
    общий размер heap и размер распределенной области пам€ти увеличились, а размер 
    нераспределенной области пам€ти уменьшилс€. Ёто происходит потому, что 
    оператор new выдел€ет пам€ть из heap дл€ хранени€ массива. ѕосле удалени€ массива 
    с помощью оператора delete[] эта пам€ть освобождаетс€, размеры heap возвращаютс€
    к исходным значени€м
    */
    return 0;
}
