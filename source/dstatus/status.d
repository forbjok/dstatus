module dstatus.status;

import std.conv : text, to;
import std.format : format;
import std.range : repeat, take;
import std.stdio : File, stdout, stderr;
import std.string : leftJustify, rightJustify;

class Status {
    private {
        int _prevReportLength = 0;
    }

    File output;

    this() {
        output = stderr;
    }

    private void _write(string txt) {
        /* Write a backspace for each character in the previous reported text
           to reset the cursor to its original starting location. */
        output.write('\b'.repeat(_prevReportLength));

        // Write the new text
        output.write(txt);

        /* If text is shorter than the previous length,
           overwrite the remainder with spaces. */
        if (txt.length < _prevReportLength) {
            auto remainderLength = _prevReportLength - txt.length;
            output.write(' '.repeat(remainderLength), '\b'.repeat(remainderLength));
        }
    }

    final void clear() {
        /* Clear last report */
        output.write('\b'.repeat(_prevReportLength), ' '.repeat(_prevReportLength), '\b'.repeat(_prevReportLength));
        _prevReportLength = 0;
    }

    final void write(T...)(T args) {
        _write(text(args));
        _prevReportLength = 0;
    }

    final void report(T...)(T args) {
        auto txt = text(args);

        _write(txt);

        // Store the length of the new text
        _prevReportLength = txt.length;
    }

    final void end() {
        // Write a blank line to move to a new line
        output.writeln();

        // Reset this status
        _prevReportLength = 0;
    }
}

auto status() {
    return new Status();
}


@safe:

pure string makeFixedWidth(string truncatedSuffix = "...", alias justify = leftJustify, T...)(in int width, in T args) {
    auto str = text(args);

    if (str.length > width) {
        return "%s%s".format(str.take(width - truncatedSuffix.length), truncatedSuffix);
    }

    return justify(str, width);
}

unittest {
    enum testString = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

    assert(makeFixedWidth(testString.length, testString) == testString);
    assert(makeFixedWidth(10, testString) == "ABCDEFG...");
    assert(makeFixedWidth(27, testString) == "ABCDEFGHIJKLMNOPQRSTUVWXYZ ");
    assert(makeFixedWidth!("")(10, testString) == "ABCDEFGHIJ");
}
