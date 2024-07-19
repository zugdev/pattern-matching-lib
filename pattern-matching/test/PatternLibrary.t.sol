// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/PatternLibrary.sol";

contract PatternMatchingTest is Test {
    using PatternMatching for uint256[];

    uint256[] data;
    uint256[] pattern;
    uint256[] volumes;
    uint256[] shortTerm;
    uint256[] longTerm;
    uint256[] x;
    uint256[] y;
    uint256[][] transitionMatrix;
    uint256[][] trainingData;
    uint256[] labels;

    function setUp() public {
        data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
        pattern = [4, 5, 6];
        volumes = [100, 200, 150, 300, 250];
        shortTerm = [1, 2, 3, 4, 5];
        longTerm = [2, 2, 2, 2, 2];
        x = [1, 2, 3, 4, 5];
        y = [2, 4, 6, 8, 10];
        transitionMatrix = [[1, 1], [1, 1]];
        trainingData = [[1, 2], [2, 3], [3, 4]];
        labels = [0, 1, 1];
    }

    function testDetectExactPattern() view public {
        bool result = PatternMatching.detectExactPattern(data, pattern);
        assertTrue(result);
    }

    function testDetectThresholdPattern() view public {
        bool result = PatternMatching.detectThresholdPattern(data, pattern, 1);
        assertTrue(result);
    }

    function testDetectMovingAverageCrossover() view public {
        PatternMatching.MovingAverageData memory maData = PatternMatching.MovingAverageData(shortTerm, longTerm);
        bool result = PatternMatching.detectMovingAverageCrossover(maData);
        assertTrue(result);
    }

    function testDetectTrendReversal() view public {
        bool result = PatternMatching.detectTrendReversal(data);
        assertFalse(result);
    }

    function testDetectAnomaly() view public {
        bool result = PatternMatching.detectAnomaly(data, 1);
        assertTrue(result);
    }

    function testCalculateMovingAverage() view public {
        uint256[] memory result = PatternMatching.calculateMovingAverage(data, 3);
        assertEq(result.length, data.length - 2);
    }

    function testDetectDTW() pure public {
        uint256[] memory series1 = new uint256[](3);
        series1[0] = 1;
        series1[1] = 2;
        series1[2] = 3;
        uint256[] memory series2 = new uint256[](4);
        series2[0] = 1;
        series2[1] = 2;
        series2[2] = 2;
        series2[3] = 3;
        uint256 result = PatternMatching.detectDTW(series1, series2);
        assertEq(result, 0);
    }

    function testDetectSVM() view public {
        uint256[] memory weights = new uint256[](5);
        weights[0] = 1;
        weights[1] = 1;
        weights[2] = 1;
        weights[3] = 1;
        weights[4] = 1;
        uint256 bias = 0;
        uint256 result = PatternMatching.detectSVM(x, weights, bias);
        assertEq(result, 1); // Assuming a simple SVM where the class label is 1
    }

    function testCalculateEMA() view public {
        uint256 period = 3;
        uint256[] memory result = PatternMatching.calculateEMA(data, period);
        assertEq(result.length, data.length);
    }

    function testCalculateBollingerBands() view public {
        uint256 period = 3;
        uint256 multiplier = 2;
        PatternMatching.BollingerBands[] memory result = PatternMatching.calculateBollingerBands(data, period, multiplier);
        assertEq(result.length, data.length - period + 1);
    }

    function testDetectHeadAndShoulders() pure public {
        uint256[] memory hsData = new uint256[](5);
        hsData[0] = 1;
        hsData[1] = 3;
        hsData[2] = 1;
        hsData[3] = 4;
        hsData[4] = 2;
        bool result = PatternMatching.detectHeadAndShoulders(hsData);
        assertTrue(result);
    }

    function testDetectCupAndHandle() pure public {
        uint256[] memory chData = new uint256[](5);
        chData[0] = 5;
        chData[1] = 3;
        chData[2] = 4;
        chData[3] = 6;
        chData[4] = 4;
        bool result = PatternMatching.detectCupAndHandle(chData);
        assertFalse(result);
    }
}
