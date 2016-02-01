module dstatus.progress;

import std.algorithm.comparison : max;
import std.conv : to;
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
        _barWidth = barWidth;
    }

    void progress(int percent) {
        auto barFillLength = ((percent.to!float / 100) * _barWidth).to!int;

        auto front = ">";

        if (barFillLength == 0 || barFillLength == _barWidth)
            front = "";

        auto fill = '='.repeat(max(barFillLength - front.length, 0));
        auto empty = ' '.repeat(_barWidth - barFillLength);

        auto percentText = "%d%%".format(percent).leftJustify(4);

        auto bar = "[%s%s%s] %s".format(fill, front, empty, percentText);

        report(bar);
    }
}
