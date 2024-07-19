// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/TimeSeriesAnalysisLibrary.sol";

contract TimeSeriesAnalysisTest is Test {
    using TimeSeriesAnalysis for uint256[];

    uint256[] data;
    uint256[] data2;
    uint256[] data3;

    function setUp() public {
        data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
        data2 = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29];
        data3 = [30, 28, 26, 25, 24, 22, 20, 19, 17, 15];
    }

    function testAutoregressive() view public {
        uint256 p = 2;
        uint256[] memory result = TimeSeriesAnalysis.autoregressive(data, p);
        assertEq(result.length, data.length - p);
    }

    function testLaggedValues() view public {
        uint256 lag = 2;
        uint256[] memory result = TimeSeriesAnalysis.laggedValues(data, lag);
        assertEq(result.length, data.length - lag);
        assertEq(result[0], data[0]);
    }

    function testLaggedDifferences() view public {
        uint256 lag = 2;
        uint256[] memory result = TimeSeriesAnalysis.laggedDifferences(data, lag);
        assertEq(result.length, data.length - lag);
        assertEq(result[0], data[lag] - data[0]);
    }

    // failing test
    function testAutocorrelation() view public {
        uint256 lag = 2;
        int256 result = TimeSeriesAnalysis.autocorrelation(data, lag);
        assertTrue(result >= -1 && result <= 1);
    }

    // failing test
    function testPartialAutocorrelation() view public {
        uint256 lag = 2;
        int256 result = TimeSeriesAnalysis.partialAutocorrelation(data, lag);
        assertTrue(result >= -1 && result <= 1);
    }

    // failing test
    function testAugmentedDickeyFuller() view public {
        uint256 lag = 1;
        bool result = TimeSeriesAnalysis.augmentedDickeyFuller(data3, lag);
        assertTrue(result);
    }

    function testStlDecomposition() view public {
        uint256 seasonLength = 2;
        TimeSeriesAnalysis.STLComponents memory components = TimeSeriesAnalysis.stlDecomposition(data, seasonLength);
        assertEq(components.trend.length, data.length);
        assertEq(components.seasonal.length, data.length);
        assertEq(components.residual.length, data.length);
    }

    function testMovingAverage() view public {
        uint256 windowSize = 2;
        uint256[] memory result = TimeSeriesAnalysis.movingAverage(data, windowSize);
        assertEq(result.length, data.length);
    }
}
