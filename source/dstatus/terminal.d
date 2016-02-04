module dstatus.terminal;

import std.conv : to;

short getTerminalWidth() {
    version (Windows) {
        import core.sys.windows.winbase;
        import core.sys.windows.wincon;
        import core.sys.windows.windef;

        CONSOLE_SCREEN_BUFFER_INFO info;
        if (GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), &info) == TRUE) {
            return info.dwSize.X;
        }
    }
    else version (Posix) {
        import core.sys.posix.sys.ioctl;
        import core.sys.posix.unistd;

        winsize size;
        if (ioctl(STDOUT_FILENO, TIOCGWINSZ, &size) == 0) {
            return size.ws_col;
        }
    }

    // Terminal width could not be gotten - return -1
    return -1;
}
