module dstatus.status;

import std.conv : text, to;
import std.format : format;
import std.range : repeat, take;
import std.stdio : File, stdout, stderr;
import std.string : leftJustify;

class Status {
    private {
        size_t _prevReportLength = 0;
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

    void begin() {
        _prevReportLength = 0;
    }

    void write(T...)(T args) {
        _write(text(args));
        begin();
    }

    void report(T...)(T args) {
        auto txt = text(args);

        _write(txt);

        // Store the length of the new text
        _prevReportLength = txt.length;
    }

    void end() {
        // Write a blank line to move to a new line
        output.writeln();

        // Reset this status
        begin();
    }
}

/*
class FixedWidthStatus : Status {
    private {
        size_t _fixedWidth;
        string _truncatedSuffix;
    }

    this(size_t fixedWidth, string truncatedSuffix = "...") {
        _fixedWidth = fixedWidth;
        _truncatedSuffix = truncatedSuffix.take(_fixedWidth).to!string;
    }

    override void report(in char[] text) {
        const(char)[] newText;
        if (text.length > _fixedWidth) {
            newText = "%s%s".format(text.take(_fixedWidth - _truncatedSuffix.length), _truncatedSuffix).leftJustify(_fixedWidth);
        }
        else {
            newText = text.leftJustify(_fixedWidth);
        }

        Status.report(newText);
    }
}*/
