module dstatus.status;

import std.conv : text, to;
import std.format : format;
import std.range : repeat, take;
import std.stdio : File, stdout, stderr;
import std.string : leftJustify, rightJustify;

import dstatus.terminal;

class Status {
    private {
        size_t _writeLength = 0;
        size_t _prevReportLength = 0;
        TerminalPosition _originalPosition;
        TerminalPosition _currentPosition;
    }

    File output;

    this() {
        output = stderr;

        _currentPosition = _originalPosition = getPosition();
    }

    private TerminalPosition getPosition() {
        return new TerminalPosition(output);
    }

    private void _write(string txt) {
        /* Reset the cursor to the current reporting position */
        _currentPosition.restore();

        // Write the new text
        output.write(txt);

        /* If text is shorter than the previous length,
           overwrite the remainder with spaces. */
        if (txt.length < _prevReportLength) {
            auto endPosition = getPosition();
            scope(exit) endPosition.restore();

            auto remainderLength = _prevReportLength - txt.length;
            output.write(' '.repeat(remainderLength));
        }
    }

    final void clear() {
        /* Reset the cursor to its original starting position. */
        _originalPosition.restore();

        /* Clear all text written by us */
        auto clearLength = _writeLength + _prevReportLength;
        output.write(' '.repeat(clearLength));

        /* Reset the cursor to its original starting position. */
        _originalPosition.restore();

        _writeLength = 0;
        _prevReportLength = 0;
    }

    final void write(T...)(T args) {
        auto txt = text(args);

        _write(txt);
        _currentPosition = getPosition();

        _writeLength += txt.length;
        _prevReportLength = 0;
    }

    final void report(T...)(T args) {
        auto txt = text(args);

        _write(txt);

        // Store the length of the new text
        _prevReportLength = txt.length;
    }
}

auto status() {
    return new Status();
}


@safe:

pure string makeFixedWidth(string truncatedSuffix = "...", alias justify = leftJustify, T...)(in size_t width, in T args) {
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
