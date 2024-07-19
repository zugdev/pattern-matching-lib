// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/PatternLibrary.sol";
import "../src/MathLibrary.sol";

contract PatternLibraryTest is Test {
    using PatternLibrary for uint256[];
    using MathLibrary for uint256[];

    function testCalculateTWAP() pure public {
        uint256[] memory prices = new uint256[](5);
        prices[0] = 100;
        prices[1] = 200;
        prices[2] = 300;
        prices[3] = 400;
        prices[4] = 500;

        uint256[] memory times = new uint256[](5);
        times[0] = 1;
        times[1] = 1;
        times[2] = 1;
        times[3] = 1;
        times[4] = 1;

        uint256 expected = 300;
        uint256 result = PatternLibrary.calculateTWAP(prices, times);

        assertEq(result, expected, "TWAP calculation failed");
    }

    function testDetectTWAPAnomaly() pure public {
        uint256[] memory prices = new uint256[](5);
        prices[0] = 100;
        prices[1] = 200;
        prices[2] = 300;
        prices[3] = 400;
        prices[4] = 1000;

        bool result = PatternLibrary.detectTWAPAnomaly(prices, 200); // 2%

        assertTrue(result, "TWAP anomaly detection failed");
    }

    function testCalculateMovingAverage() pure public {
        uint256[] memory data = new uint256[](5);
        data[0] = 1;
        data[1] = 2;
        data[2] = 3;
        data[3] = 4;
        data[4] = 5;

        uint256 windowSize = 3;
        uint256[] memory expected = new uint256[](3);
        expected[0] = 2; // (1+2+3)/3
        expected[1] = 3; // (2+3+4)/3
        expected[2] = 4; // (3+4+5)/3

        uint256[] memory result = PatternLibrary.calculateMovingAverage(data, windowSize);

        for (uint256 i = 0; i < result.length; i++) {
            assertEq(result[i], expected[i], "Moving average calculation failed");
        }
    }

    function testDetectPriceSpike() pure public {
        uint256[] memory prices = new uint256[](5);
        prices[0] = 100;
        prices[1] = 200;
        prices[2] = 300;
        prices[3] = 400;
        prices[4] = 1000;

        bool result = PatternLibrary.detectPriceSpike(prices, 100); // 1%

        assertTrue(result, "Price spike detection failed");
    }

    function testDetectLPImbalance() pure public {
        uint256[] memory assetRatios = new uint256[](5);
        assetRatios[0] = 100;
        assetRatios[1] = 200;
        assetRatios[2] = 300;
        assetRatios[3] = 400;
        assetRatios[4] = 1000;

        bool result = PatternLibrary.detectLPImbalance(assetRatios, 200); // 2%

        assertTrue(result, "LP imbalance detection failed");
    }

    function testDetectOutliers() pure public {
        uint256[] memory data = new uint256[](8);
        data[0] = 2;
        data[1] = 4;
        data[2] = 4;
        data[3] = 4;
        data[4] = 5;
        data[5] = 5;
        data[6] = 7;
        data[7] = 20;

        bool result = PatternLibrary.detectOutliers(data, 2); // 2 standard deviations

        assertTrue(result, "Outlier detection failed");
    }
}
