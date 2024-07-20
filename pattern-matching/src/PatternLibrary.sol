// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./MathLibrary.sol";

/**
 * @title PatternMatching
 * @dev Library for detecting various patterns in time series data.
 */
library PatternMatching {
    using MathLibrary for uint256[];

    /**
     * @notice Detect an exact pattern within the data.
     * @dev This function scans through the data to find an exact match for the given pattern. Useful for identifying predefined sequences in time series data.
     */
    function detectExactPattern(uint256[] memory data, uint256[] memory pattern) public pure returns (bool) {
        require(data.length >= pattern.length, "Insufficient data length");
        for (uint256 i = 0; i <= data.length - pattern.length; i++) {
            bool isMatch = true;
            for (uint256 j = 0; j < pattern.length; j++) {
                if (data[i + j] != pattern[j]) {
                    isMatch = false;
                    break;
                }
            }
            if (isMatch) {
                return true;
            }
        }
        return false;
    }

    /**
     * @notice Detect a pattern within the data allowing for a threshold of variance.
     * @dev This function identifies patterns that match within a certain threshold, useful for detecting similar but not identical sequences.
     */
    function detectThresholdPattern(uint256[] memory data, uint256[] memory pattern, uint256 threshold) public pure returns (bool) {
        require(data.length >= pattern.length, "Insufficient data length");
        for (uint256 i = 0; i <= data.length - pattern.length; i++) {
            bool isMatch = true;
            for (uint256 j = 0; j < pattern.length; j++) {
                if (data[i + j] < pattern[j] - threshold || data[i + j] > pattern[j] + threshold) {
                    isMatch = false;
                    break;
                }
            }
            if (isMatch) {
                return true;
            }
        }
        return false;
    }

    // Struct for moving average crossover detection
    struct MovingAverageData {
        uint256[] shortTerm;
        uint256[] longTerm;
    }

    /**
     * @notice Detect a moving average crossover.
     * @dev This function checks for a crossover between short-term and long-term moving averages, a common indicator in financial analysis for signaling potential buy/sell points.
     */
    function detectMovingAverageCrossover(MovingAverageData memory maData) public pure returns (bool) {
        require(maData.shortTerm.length == maData.longTerm.length, "Data arrays must have the same length");
        bool previousShortAbove = maData.shortTerm[0] > maData.longTerm[0];
        for (uint256 i = 1; i < maData.shortTerm.length; i++) {
            bool currentShortAbove = maData.shortTerm[i] > maData.longTerm[i];
            if (currentShortAbove != previousShortAbove) {
                return true; // Crossover detected
            }
            previousShortAbove = currentShortAbove;
        }
        return false;
    }

    /**
     * @notice Detect a volume spike in the data.
     * @dev Identifies significant increases in volume, can indicate strong market interest / whales trade.
     */
    function detectVolumeSpike(uint256[] memory volumes, uint256 threshold) public pure returns (bool) {
        for (uint256 i = 1; i < volumes.length; i++) {
            if (volumes[i] > volumes[i - 1] * threshold) {
                return true; // Volume spike detected
            }
        }
        return false;
    }

    /**
     * @notice Detect a trend reversal (simplified double top pattern).
     * @dev This function looks for a double top pattern, which can signal a potential reversal in the current trend.
     */
    function detectTrendReversal(uint256[] memory data) public pure returns (bool) {
        require(data.length >= 3, "Insufficient data length");
        for (uint256 i = 1; i < data.length - 1; i++) {
            if (data[i] > data[i - 1] && data[i] > data[i + 1]) {
                return true; // Potential double top detected
            }
        }
        return false;
    }

    /**
     * @notice Detect anomalies in the data based on deviation from the mean.
     * @dev This function identifies data points that deviate significantly from the mean, useful for outlier detection.
     */
    function detectAnomaly(uint256[] memory data, uint256 deviation) public pure returns (bool) {
        uint256 meanValue = data.mean();
        uint256 stdDev = data.standardDeviation();
        for (uint256 i = 0; i < data.length; i++) {
            if (data[i] > meanValue + deviation * stdDev || data[i] < meanValue - deviation * stdDev) {
                return true; // Anomaly detected
            }
        }
        return false;
    }

    /**
     * @notice Calculate the moving average of the data.
     * @dev Computes the moving average over a specified window size, smoothing out short-term fluctuations to highlight longer-term trends.
     */
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

    /**
     * @notice Detect sequences in data using a simplified Hidden Markov Model (HMM).
     * @dev Uses a transition matrix to model state transitions in the data sequence, useful for identifying hidden states and predicting future states.
     */
    function detectHMM(uint256[] memory data, uint256[] memory states, uint256[][] memory transitionMatrix) public pure returns (bool) {
        require(data.length == states.length, "Data and states length mismatch");
        uint256 currentState = states[0];
        for (uint256 i = 1; i < data.length; i++) {
            if (transitionMatrix[currentState][states[i]] == 0) {
                return false; // Transition not allowed
            }
            currentState = states[i];
        }
        return true;
    }

    /**
     * @notice Detect patterns using a simplified K-Nearest Neighbors (KNN) algorithm.
     * @dev Classifies data points based on their distance to the nearest neighbors in the training set, useful for pattern recognition and anomaly detection.
     */
    function detectKNN(uint256[] memory data, uint256[][] memory trainingData, uint256[] memory labels, uint256 k) public pure returns (uint256) {
        require(data.length == trainingData[0].length, "Data length mismatch");
        uint256[] memory distances = new uint256[](trainingData.length);
        for (uint256 i = 0; i < trainingData.length; i++) {
            uint256 distance = 0;
            for (uint256 j = 0; j < data.length; j++) {
                distance += (data[j] > trainingData[i][j]) ? data[j] - trainingData[i][j] : trainingData[i][j] - data[j];
            }
            distances[i] = distance;
        }
        uint256[] memory sortedIndexes = sortIndexes(distances);
        return getMostFrequentLabel(sortedIndexes, labels, k);
    }

    /**
     * @notice Sort indexes based on distances.
     * @dev Helper function to sort indexes of an array based on their corresponding values in another array.
     */
    function sortIndexes(uint256[] memory distances) internal pure returns (uint256[] memory) {
        uint256[] memory indexes = new uint256[](distances.length);
        for (uint256 i = 0; i < distances.length; i++) {
            indexes[i] = i;
        }
        quickSort(distances, indexes, int(0), int(distances.length - 1));
        return indexes;
    }

    function quickSort(uint256[] memory distances, uint256[] memory indexes, int left, int right) internal pure {
        int i = left;
        int j = right;
        if (i == j) return;
        uint256 pivot = distances[uint(left + (right - left) / 2)];
        while (i <= j) {
            while (distances[uint(i)] < pivot) i++;
            while (pivot < distances[uint(j)]) j--;
            if (i <= j) {
                (distances[uint(i)], distances[uint(j)]) = (distances[uint(j)], distances[uint(i)]);
                (indexes[uint(i)], indexes[uint(j)]) = (indexes[uint(j)], indexes[uint(i)]);
                i++;
                j--;
            }
        }
        if (left < j) quickSort(distances, indexes, left, j);
        if (i < right) quickSort(distances, indexes, i, right);
    }

    function getMostFrequentLabel(uint256[] memory sortedIndexes, uint256[] memory labels, uint256 k) internal pure returns (uint256) {
        uint256[] memory frequency = new uint256[](10) ; // Assume labels range from 0 to 9 (dec base) can add a parameter for that tho
        for (uint256 i = 0; i < k; i++) {
            frequency[labels[sortedIndexes[i]]]++;
        }
        uint256 maxFreq = 0;
        uint256 label = 0;
        for (uint256 i = 0; i < frequency.length; i++) {
            if (frequency[i] > maxFreq) {
                maxFreq = frequency[i];
                label = i;
            }
        }
        return label;
    }

    /**
     * @notice Detect patterns using Dynamic Time Warping (DTW).
     * @dev Measures similarity between two time series by aligning them with minimum distance, useful for pattern recognition in time series data.
     */
    function detectDTW(uint256[] memory series1, uint256[] memory series2) public pure returns (uint256) {
        uint256 n = series1.length;
        uint256 m = series2.length;
        uint256[][] memory dtw = new uint256[][](n + 1);
        for (uint256 i = 0; i <= n; i++) {
            dtw[i] = new uint256[](m + 1);
            for (uint256 j = 0; j <= m; j++) {
                dtw[i][j] = type(uint256).max;
            }
        }
        dtw[0][0] = 0;
        for (uint256 i = 1; i <= n; i++) {
            for (uint256 j = 1; j <= m; j++) {
                uint256 cost = (series1[i - 1] > series2[j - 1]) ? series1[i - 1] - series2[j - 1] : series2[j - 1] - series1[i - 1];
                dtw[i][j] = cost + min(dtw[i - 1][j], min(dtw[i][j - 1], dtw[i - 1][j - 1]));
            }
        }
        return dtw[n][m];
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @notice Calculate the correlation between two data sets.
     * @dev Measures the strength and direction of the linear relationship between two variables. Useful for identifying relationships in financial and scientific data.
     */
    function correlation(uint256[] memory x, uint256[] memory y) public pure returns (uint256) {
        require(x.length == y.length, "Arrays must be of the same length");
        uint256 meanX = x.mean();
        uint256 meanY = y.mean();
        uint256 numerator = 0;
        uint256 sumX = 0;
        uint256 sumY = 0;
        for (uint256 i = 0; i < x.length; i++) {
            numerator += (x[i] - meanX) * (y[i] - meanY);
            sumX += (x[i] - meanX) * (x[i] - meanX);
            sumY += (y[i] - meanY) * (y[i] - meanY);
        }
        return numerator / MathLibrary.sqrt(sumX * sumY);
    }

    /**
     * @notice Calculate the covariance between two data sets.
     * @dev Measures the joint variability of two random variables. Useful for identifying the relationship between the performance of two assets in finance.
     */
    function covariance(uint256[] memory x, uint256[] memory y) public pure returns (uint256) {
        require(x.length == y.length, "Arrays must be of the same length");
        uint256 meanX = x.mean();
        uint256 meanY = y.mean();
        uint256 cov = 0;
        for (uint256 i = 0; i < x.length; i++) {
            cov += (x[i] - meanX) * (y[i] - meanY);
        }
        return cov / x.length;
    }

    /**
     * @notice Detect patterns using a simplified Support Vector Machines (SVM) algorithm.
     * @dev Classifies data points by finding the optimal hyperplane that separates different classes. Useful for binary classification problems.
     */
    function detectSVM(uint256[] memory data, uint256[] memory weights, uint256 bias) public pure returns (uint256) {
        require(data.length == weights.length, "Data and weights length mismatch");
        uint256 sum = 0;
        for (uint256 i = 0; i < data.length; i++) {
            sum += data[i] * weights[i];
        }
        return sum + bias > 0 ? 1 : 0; // Return class label
    }

    /**
     * @notice Calculate the Exponential Moving Average (EMA) of the data.
     * @dev Smooths out data by applying more weight to recent observations. Commonly used in financial analysis to track stock prices.
     */
    function calculateEMA(uint256[] memory data, uint256 period) public pure returns (uint256[] memory) {
        require(data.length >= period, "Insufficient data length");
        uint256[] memory ema = new uint256[](data.length);
        uint256 multiplier = (2 * 1e18) / (period + 1);
        ema[0] = data[0];
        for (uint256 i = 1; i < data.length; i++) {
            ema[i] = ((data[i] * multiplier) / 1e18) + ((ema[i - 1] * (1e18 - multiplier)) / 1e18);
        }
        return ema;
    }

    // Bollinger Bands
    struct BollingerBands {
        uint256 upperBand;
        uint256 middleBand;
        uint256 lowerBand;
    }

    /**
     * @notice Calculate Bollinger Bands for the data.
     * @dev Uses moving averages and standard deviations to identify overbought or oversold conditions. Commonly used in financial markets.
     */
    function calculateBollingerBands(uint256[] memory data, uint256 period, uint256 multiplier) public pure returns (BollingerBands[] memory) {
        require(data.length >= period, "Insufficient data length");
        BollingerBands[] memory bands = new BollingerBands[](data.length - period + 1);
        for (uint256 i = 0; i <= data.length - period; i++) {
            uint256[] memory window = new uint256[](period);
            for (uint256 j = 0; j < period; j++) {
                window[j] = data[i + j];
            }
            uint256 meanValue = window.mean();
            uint256 stdDev = window.standardDeviation();
            bands[i].middleBand = meanValue;
            bands[i].upperBand = meanValue + (stdDev * multiplier);
            bands[i].lowerBand = meanValue - (stdDev * multiplier);
        }
        return bands;
    }

    /**
     * @notice Detect Head and Shoulders pattern in the data.
     * @dev Identifies the head and shoulders pattern, which signals a potential reversal from a bullish to a bearish trend.
     */
    function detectHeadAndShoulders(uint256[] memory data) public pure returns (bool) {
        require(data.length >= 5, "Insufficient data length");
        for (uint256 i = 2; i < data.length - 2; i++) {
            if (data[i - 2] < data[i - 1] && data[i - 1] > data[i] && data[i] < data[i + 1] && data[i + 1] > data[i + 2]) {
                return true; // Head and Shoulders pattern detected
            }
        }
        return false;
    }

    /**
     * @notice Detect Cup and Handle pattern in the data.
     * @dev Identifies the cup and handle pattern, which signals a potential continuation of an upward trend.
     */
    function detectCupAndHandle(uint256[] memory data) public pure returns (bool) {
        require(data.length >= 4, "Insufficient data length");
        for (uint256 i = 1; i < data.length - 2; i++) {
            if (data[i - 1] > data[i] && data[i] < data[i + 1] && data[i + 1] > data[i + 2] && data[i + 2] < data[i + 3]) {
                return true; // Cup and Handle pattern detected
            }
        }
        return false;
    }
}
