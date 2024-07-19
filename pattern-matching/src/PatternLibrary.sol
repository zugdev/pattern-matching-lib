// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./MathLibrary.sol";

library PatternLibrary {
    using MathLibrary for uint256[];
    using MathLibrary for uint256;

    // Function to calculate TWAP
    function calculateTWAP(uint256[] memory prices, uint256[] memory times) public pure returns (uint256) {
        require(prices.length == times.length, "Prices and times arrays must have the same length");
        uint256 totalWeightedPrice = 0;
        uint256 totalTime = 0;
        for (uint256 i = 0; i < prices.length; i++) {
            totalWeightedPrice += prices[i] * times[i];
            totalTime += times[i];
        }
        return totalWeightedPrice / totalTime;
    }

    // Function to detect TWAP anomalies outside a threshold
    function detectTWAPAnomaly(uint256[] memory prices, uint256 threshold) public pure returns (bool) {
        uint256 meanPrice = prices.mean();
        uint256 maxPrice = prices.max();
        uint256 minPrice = prices.min();
        uint256 priceRange = maxPrice - minPrice;
        uint256 allowedDeviation = (meanPrice * threshold) / 10000; // threshold in basis points

        return priceRange > allowedDeviation;
    }

    // Function to calculate moving average
    function calculateMovingAverage(uint256[] memory data, uint256 windowSize) public pure returns (uint256[] memory) {
        require(data.length >= windowSize, "Insufficient data length");
        uint256[] memory movingAverage = new uint256[](data.length - windowSize + 1);
        for (uint256 i = 0; i <= data.length - windowSize; i++) {
            uint256 sum = 0;
            for (uint256 j = 0; j < windowSize; j++) {
                sum += data[i + j];
            }
            movingAverage[i] = sum / windowSize;
        }
        return movingAverage;
    }

    // Function to detect price spikes outside a threshold
    function detectPriceSpike(uint256[] memory prices, uint256 threshold) public pure returns (bool) {
        for (uint256 i = 1; i < prices.length; i++) {
            if (prices[i] > prices[i - 1] * (1 + threshold / 10000) || prices[i] < prices[i - 1] * (1 - threshold / 10000)) {
                return true; // Price spike detected
            }
        }
        return false;
    }

    // Function to detect LP imbalance outside a threshold
    function detectLPImbalance(uint256[] memory assetRatios, uint256 threshold) public pure returns (bool) {
        uint256 meanValue = assetRatios.mean();
        for (uint256 i = 0; i < assetRatios.length; i++) {
            if (assetRatios[i] > meanValue * (1 + threshold / 10000) || assetRatios[i] < meanValue * (1 - threshold / 10000)) {
                return true; // LP imbalance detected
            }
        }
        return false;
    }

    // Function to detect outliers based on standard deviation
    function detectOutliers(uint256[] memory data, uint256 deviationThreshold) public pure returns (bool) {
        uint256 meanValue = data.mean();
        uint256 stdDev = data.standardDeviation();
        uint256 upperBound = meanValue + (stdDev * deviationThreshold);
        uint256 lowerBound = meanValue > stdDev * deviationThreshold ? meanValue - stdDev * deviationThreshold : 0;

        for (uint256 i = 0; i < data.length; i++) {
            if (data[i] > upperBound || data[i] < lowerBound) {
                return true; // Outlier detected
            }
        }
        return false;
    }
}
