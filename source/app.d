import std.conv : to;
import std.format;
import std.stdio;
import core.thread;

import dstatus.status;
import dstatus.progress;
import dstatus.terminal;

void main()
{
    auto operation = operationProgressIndicator(getTerminalWidth(), 10);
    for(short s = 1; s <= 10; ++s) {
        operation.step(text("Step ", s));

        for(short i = 0; i <= 100; ++i) {
            operation.progress(i);
            stdout.flush();
            Thread.getThis().sleep(dur!("msecs")(50));
        }
    }

    auto status = status();

    status.write("Doing something... ");

    for(short i = 0; i <= 100; ++i) {
        status.report("%d%%".format(i));
        stdout.flush();
        Thread.getThis().sleep(dur!("msecs")(50));
    }

    for(short i = 100; i >= 0; --i) {
        status.report("%d%%".format(i));
        stdout.flush();
        Thread.getThis().sleep(dur!("msecs")(50));
    }

    status.end();

    auto progress = progressBar(40);
    //progress.write("Doing something else... ");

    for(short i = 0; i <= 100; ++i) {
        progress.progress(i);
        stdout.flush();
        Thread.getThis().sleep(dur!("msecs")(50));
    }

    for(short i = 100; i >= 0; --i) {
        progress.progress(i);
        stdout.flush();
        Thread.getThis().sleep(dur!("msecs")(50));
    }

    progress.end();
}
