module dstatus.progress;

import std.algorithm.comparison : max, min;
import std.array : array;
import std.conv : to, text;
import std.format : format;
import std.range : repeat;
import std.string : leftJustify;

import dstatus.status;

class ProgressBar : Status {
    private {
        int _barWidth;
    }

    this(int barWidth) {
        super();
        _barWidth = barWidth - 6;
    }

    void progress(int percent) {
        auto percentText = "%d%%".format(percent).leftJustify(4);

        report(text(makeProgressBar(_barWidth, percent), " ", percentText));
    }
}

@safe:

pure string makeProgressBar(char leftEndChar = '[', char fillChar = '=', char tipChar = '>', char blankChar = ' ', char rightEndChar = ']')(in size_t width, in int percent) {
    auto maxFillLength = width - 2;
    auto fillLength = ((percent.to!float / 100) * maxFillLength).to!int;
    auto actualFillLength = min(fillLength, maxFillLength);

    auto fill = fillChar.repeat(actualFillLength).array();
    auto blank = blankChar.repeat(maxFillLength - actualFillLength);

    if (actualFillLength > 0 && actualFillLength < maxFillLength) {
        fill[$-1] = tipChar;
    }

    return text(leftEndChar, fill, blank, rightEndChar);
}

unittest {
    assert(makeProgressBar(10, 0).length == 10);
    assert(makeProgressBar(10, 100).length == 10);
}
