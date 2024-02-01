﻿#include <iostream>
#include <Windows.h>
using namespace std;

int main() {
    setlocale(LC_ALL, "ru_RU.CP1251");
    SetConsoleCP(1251);
    SetConsoleOutputCP(1251);
    // Получаем идентификатор процесса OS03_02_1
    DWORD processId = GetCurrentProcessId();
    

    // Выполняем цикл 50 итераций с задержкой в 1 секунду
    for (int i = 0; i < 50; i++) {
        cout << "Идентификатор процесса OS03_02_1: " << processId << endl;
        Sleep(1000); 
    }

    return 0;
}
