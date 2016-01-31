module dstatus.progress;

import std.algorithm.comparison;
import std.format;
import std.range;
import std.stdio;
import std.string;

import dstatus.status;

class ProgressBar : Status {
    private {
        int _barWidth;
    }

    this(int barWidth) {
        _barWidth = barWidth;
    }

    void progress(int percent) {
        auto barFillLength = cast(int) ((cast(float) percent / 100) * _barWidth);

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
