import std.format;
import std.stdio;
import core.thread;

import dstatus.status;
import dstatus.progress;

void main()
{
    write("Doing something... ");

    auto status = new Status();
    //auto status = new FixedWidthStatus(10);

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

    write("Doing something else... ");
    stdout.flush();

    auto progress = new ProgressBar(50);

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
