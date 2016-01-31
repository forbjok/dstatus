module dstatus.status;

import std.range;
import std.stdio;
import std.string;

class Status {
    private {
        size_t _prevReportLength = 0;
    }

    void begin() {
        _prevReportLength = 0;
    }

    void report(in char[] text) {
        /* Write a backspace for each character in the previous reported text
           to reset the cursor to its original starting location. */
        write('\b'.repeat(_prevReportLength));

        // Write the new text
        write(text);

        /* If text is shorter than the previous length,
           overwrite the remainder with spaces. */
        if (text.length < _prevReportLength) {
            auto remainderLength = _prevReportLength - text.length;
            write(' '.repeat(remainderLength), '\b'.repeat(remainderLength));
        }

        // Store the length of the new text
        _prevReportLength = text.length;
    }

    void end() {
        // Write a blank line to move to a new line
        writeln();

        // Reset this status
        begin();
    }
}

class FixedWidthStatus : Status {
    private {
        size_t _fixedWidth;
        string _truncatedSuffix;
    }

    this(size_t fixedWidth, string truncatedSuffix = "...") {
        import std.conv : to;
        
        _fixedWidth = fixedWidth;
        _truncatedSuffix = truncatedSuffix.take(_fixedWidth).to!string;
    }

    override void report(in char[] text) {
        import std.conv : to;

        const(char)[] newText;
        if (text.length > _fixedWidth) {
            newText = "%s%s".format(text.take(_fixedWidth - _truncatedSuffix.length), _truncatedSuffix).leftJustify(_fixedWidth);
        }
        else {
            newText = text.leftJustify(_fixedWidth);
        }

        Status.report(newText);
    }
}
