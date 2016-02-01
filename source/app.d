import std.conv : to;
import std.format;
import std.stdio;
import core.thread;

import dstatus.status;
import dstatus.progress;

int getTerminalWidth() {
    version (Windows) {
        import core.sys.windows.winbase;
        import core.sys.windows.wincon;
        import core.sys.windows.windef;

        CONSOLE_SCREEN_BUFFER_INFO info;
        if (GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), &info) == TRUE) {
            return info.dwSize.X.to!int;
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

void main()
{
    auto terminalWidth = getTerminalWidth();
    writeln("Terminal width is ", terminalWidth);
    auto status = new Status();

    status.write("Doing something... ");

    for(int i = 0; i <= 100; ++i) {
        status.report("%d%%".format(i));
        stdout.flush();
        Thread.getThis().sleep(dur!("msecs")(100));
    }

    for(int i = 100; i >= 0; --i) {
        status.report("%d%%".format(i));
        stdout.flush();
        Thread.getThis().sleep(dur!("msecs")(100));
    }

    status.end();

    auto progress = new ProgressBar(terminalWidth);
    //progress.write("Doing something else... ");

    for(int i = 0; i <= 100; ++i) {
        progress.progress(i);
        stdout.flush();
        Thread.getThis().sleep(dur!("msecs")(100));
    }

    for(int i = 100; i >= 0; --i) {
        progress.progress(i);
        stdout.flush();
        Thread.getThis().sleep(dur!("msecs")(100));
    }

    progress.end();
}
