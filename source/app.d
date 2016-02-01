import std.conv : to;
import std.format;
import std.stdio;
import core.thread;

import dstatus.status;
import dstatus.progress;

void main()
{
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

    auto progress = new ProgressBar(40);
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
