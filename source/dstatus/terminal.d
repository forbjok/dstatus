module dstatus.terminal;

import std.conv : text, to;

short getTerminalWidth() {
    version (Windows) {
        import core.sys.windows.winbase : GetStdHandle, STD_OUTPUT_HANDLE;
        import core.sys.windows.wincon : CONSOLE_SCREEN_BUFFER_INFO, GetConsoleScreenBufferInfo;
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

version (Posix) {
    import core.sys.posix.termios : ECHO, ICANON, tcflush, tcgetattr, TCIFLUSH, tcsetattr, TCSANOW, termios;
    import unistd = core.sys.posix.unistd;
    import std.stdio : File;

    class TerminalPosition {
        private {
            string setCursorPosition;
            int _tty;
        }

        this(File output) {
            _tty = output.fileno();

            if (!unistd.isatty(_tty)) {
                return;
            }

            // Retrieve current terminal settings
            termios oldtermios;
            tcgetattr(_tty, &oldtermios);

            // Disable echoing and waiting for ENTER
            auto newtermios = oldtermios;
            newtermios.c_lflag &= ~(ECHO | ICANON);
            tcsetattr(_tty, TCSANOW, &newtermios);

            /* Ensure that original terminal settings are restored upon leaving the scope,
               lest we mess up the user's terminal. */
            scope(exit) tcsetattr(_tty, TCSANOW, &oldtermios);

            // Flush input to prevent user interfering with cursor position acquisition
            tcflush(_tty, TCIFLUSH);

            // Send ANSI sequence for getting cursor position to STDOUT
            auto getPosition = "\033[6n";
            unistd.write(_tty, cast(void*)getPosition, getPosition.length);

            // Read the response from STDIN
            char[16] response;
            auto readlen = unistd.read(_tty, cast(void*)response, 16);

            /* Store ANSI sequence for settings cursor position from response
               by taking the response, chopping off the R and appending an H instead. */
            setCursorPosition = text(response[0..readlen-1], "H");
        }

        void restore() {
            // Send ANSI sequence for setting cursor position
            unistd.write(_tty, cast(void*)setCursorPosition, setCursorPosition.length);
        }
    }
}
else version (Windows) {
    import core.sys.windows.wincon : CONSOLE_CURSOR_INFO, CONSOLE_SCREEN_BUFFER_INFO, COORD, GetConsoleCursorInfo, GetConsoleScreenBufferInfo, SetConsoleCursorPosition;
    import core.sys.windows.windef;
    import std.stdio : File;

    class TerminalPosition {
        private {
            COORD _cursorPosition;
            File _output;
        }

        this(File output) {
            _output = output;

            CONSOLE_SCREEN_BUFFER_INFO info;
            if (GetConsoleScreenBufferInfo(_output.windowsHandle, &info) != TRUE) {
                throw new Exception("Error getting cursor position.");
            }

            _cursorPosition = info.dwCursorPosition;
        }

        void restore() {
            SetConsoleCursorPosition(_output.windowsHandle, _cursorPosition);
        }
    }
}
