module dstatus.progress;

import std.algorithm.comparison : max, min;
import std.array : array;
import std.conv : to, text;
import std.format : format;
import std.range : repeat;
import std.string : leftJustify;

import dstatus.status;
import dstatus.terminal;

class ProgressBar(alias mkProgressBar) : Status {
    private {
        size_t _width;
    }

    this(in size_t width) {
        super();
        _width = width - 6;
    }

    final void progress(in short percent) {
        auto percentText = "%d%%".format(percent).leftJustify(4);

        report(text(mkProgressBar(_width, percent), " ", percentText));
    }
}

class OperationProgressIndicator(alias mkProgressBar, alias mkStepCounter) : Status {
    private {
        size_t _stepWidth;
        size_t _descriptionWidth;
        size_t _percentTextWidth;
        size_t _progressBarWidth;

        int _stepCount;
        int _currentStep;
        string _stepDescription;
    }

    this(in size_t width, in int stepCount) {
        _stepCount = stepCount;

        _stepWidth = mkStepCounter(_stepCount, _stepCount).length + 1;
        _descriptionWidth = (width / 2) - _stepWidth;

        auto progressWidth = (width / 2) - 2;
        _percentTextWidth = 4;
        _progressBarWidth = progressWidth - _percentTextWidth - 1;
    }

    final void step(in string description) {
        ++_currentStep;
        _stepDescription = description;
    }

    final void progress(in short percent) {
        auto percentText = "%d%%".format(percent).leftJustify(_percentTextWidth);

        auto indicator = text(
            mkStepCounter(_currentStep, _stepCount),
            " ",
            makeFixedWidth(_descriptionWidth, _stepDescription),
            " ",
            mkProgressBar(_progressBarWidth, percent),
            " ",
            percentText);

        report(indicator);
    }
}

auto progressBar(alias mkProgressBar = makeProgressBar)(in size_t width) {
    return new ProgressBar!(mkProgressBar)(width);
}

auto operationProgressIndicator(alias mkProgressBar = makeProgressBar, alias mkStepCounter = makeStepCounter)(in size_t width, in int stepCount) {
    return new OperationProgressIndicator!(mkProgressBar, mkStepCounter)(width, stepCount);
}

@safe:

pure string makeProgressBar(char leftEndChar = '[', char fillChar = '=', char tipChar = '>', char blankChar = ' ', char rightEndChar = ']')(in size_t width, in short percent) {
    auto maxFillLength = width - 2;
    auto fillLength = ((percent.to!float / 100) * maxFillLength).to!size_t;
    auto actualFillLength = min(fillLength, maxFillLength);

    auto fill = fillChar.repeat(actualFillLength).array();
    auto blank = blankChar.repeat(maxFillLength - actualFillLength);

    if (actualFillLength > 0 && actualFillLength < maxFillLength) {
        fill[$-1] = tipChar;
    }

    return text(leftEndChar, fill, blank, rightEndChar);
}

pure string makeStepCounter(string divider = "/")(in int currentStep, in int stepCount) {
    auto stepCountText = text(stepCount);
    auto currentStepText = text(currentStep).rightJustify(stepCountText.length);

    return currentStepText ~ divider ~ stepCountText;
}

unittest {
    assert(makeProgressBar(10, 0).length == 10);
    assert(makeProgressBar(10, 100).length == 10);
}
