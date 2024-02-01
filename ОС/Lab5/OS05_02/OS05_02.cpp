#include <iostream>
#include <Windows.h>
#include <string>

#include <iostream>
#include <Windows.h>

DWORD PriorityStrToDWORD(int priority) {
    switch (priority) {
    case 64:
        return IDLE_PRIORITY_CLASS;
    case 16384:
        return BELOW_NORMAL_PRIORITY_CLASS;
    case 32:
        return NORMAL_PRIORITY_CLASS;
    case 32768:
        return ABOVE_NORMAL_PRIORITY_CLASS;
    case 128:
        return HIGH_PRIORITY_CLASS;
    case 256:
        return REALTIME_PRIORITY_CLASS;
    default:
        return Unknown;
    }
}

// ������� ��� ������� ��������� ��������
bool LaunchChildProcess(const wchar_t* applicationName, DWORD_PTR affinityMask, DWORD priority) {
    
    STARTUPINFO startupInfo;
    ZeroMemory(&startupInfo, sizeof(startupInfo));
    startupInfo.cb = sizeof(startupInfo);

    // ��������� �������.
    startupInfo.dwFlags = STARTF_USESHOWWINDOW | STARTF_USESTDHANDLES;
    startupInfo.wShowWindow = SW_SHOW; // ����� ��� ������ ������ ����.

    // �������� ��������� PROCESS_INFORMATION, ������� ����� ��������� ���������� � ��������� ��������.
    PROCESS_INFORMATION processInfo;
    ZeroMemory(&processInfo, sizeof(processInfo));

    if (CreateProcess(applicationName, nullptr, nullptr, nullptr, TRUE, CREATE_NEW_CONSOLE, nullptr, nullptr, &startupInfo, &processInfo)) {
        if (SetProcessAffinityMask(processInfo.hProcess, affinityMask)) {
            std::wcout << L"����� ����������� ����������� ������� �����������." << std::endl;
        }
        else {
            std::cerr << "������ ��� ��������� ����� ����������� �����������. ��� ������: " << GetLastError() << std::endl;
        }

        if (SetPriorityClass(processInfo.hProcess, priority)) {
            std::wcout << L"��������� �������� ������� ����������." << std::endl;
        }
        else {
            std::cerr << "������ ��� ��������� ���������� ��������. ��� ������: " << GetLastError() << std::endl;
        }

        // �������� ����������� �������� � ������, ����� �������� ������ ��������.
        CloseHandle(processInfo.hThread);
        CloseHandle(processInfo.hProcess);

        std::wcout << L"�������� ������� ������� � ����� ���������� ����." << std::endl;
        return true;
    }
    else {
        // ��������� ������, ���� ������ �� ������.
        DWORD error = GetLastError();
        std::cerr << "������ ��� ������� ��������� ��������. ��� ������: " << error << std::endl;
        return false;
    }
}

int main(int argc, char* argv[]) {
    // ������������� ��������� ��� ����� � ������ � ������� (Windows-1251)
    SetConsoleCP(1251);
    SetConsoleOutputCP(1251);

    if (argc != 4) {
        std::cout << "�������������: OS05_02 P1 P2 P3" << std::endl;
        return 1;
    }

    // ����� ����������� �����������
    // ��� ������ ������ � ��� ���� 4 ������� ���������. �� ����� ������������ 1 � 3 ����, ������ ����� 10, ������� �������� ����� 10 -> 0101
    // 65535 - 16 ������� | 16383 - 14 | 4095 - 12 | 1023 - 10 | 255 - 8 | 63 - 6 | 15 - 4 | 3 - 2 
    DWORD_PTR affinityMask = static_cast<DWORD_PTR>(std::stoull(argv[1])); 
    
    // ���������� ��� ������������ �����, ������� �� ������ ��������� � ����� ���������� ����.
    const wchar_t* applicationName = L"OS05_02x.exe";

    // ��������� ��� �������� ��������
    if (
        LaunchChildProcess(applicationName, affinityMask, PriorityStrToDWORD(std::stoi(argv[2])))
        && 
        LaunchChildProcess(applicationName, affinityMask, PriorityStrToDWORD(std::stoi(argv[3])))
       ) 
    {
        std::wcout << L"��� �������� �������� ������� ��������." << std::endl;
    }

    return 0;
}

/*

BOOL CreateProcess(
  LPCTSTR lpApplicationName,        // ��� ������������ ����� ��� NULL
  LPTSTR lpCommandLine,             // ��������� ������ ��� �������
  LPSECURITY_ATTRIBUTES lpProcessAttributes, // �������������� �������� ������������ ��� ��������
  LPSECURITY_ATTRIBUTES lpThreadAttributes,  // �������������� �������� ������������ ��� ������
  BOOL bInheritHandles,             // ���������, ����� �� �������� �������� ����������� ����������� �������� ��������
  DWORD dwCreationFlags,            // ����� �������� ��������
  LPVOID lpEnvironment,             // ��������� �� ��������� (�������������)
  LPCTSTR lpCurrentDirectory,       // ������� ������� ������� ��� �������� (�������������)
  LPSTARTUPINFO lpStartupInfo,      // ��������� STARTUPINFO, ��������� ��������� �������� ��������
  LPPROCESS_INFORMATION lpProcessInformation // ��������� PROCESS_INFORMATION, � ������� ����� ��������� ���������� � ��������
);

*/