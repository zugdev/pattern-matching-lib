// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./MathLibrary.sol";

/**
 * @title TimeSeriesAnalysis
 * @dev Library for advanced time series analysis including AR, ADF, STL...
 */
library TimeSeriesAnalysis {

    using MathLibrary for uint256[];

    // Struct for STL decomposition components
    struct STLComponents {
        uint256[] trend;
        uint256[] seasonal;
        uint256[] residual;
    }

    /**
     * @notice Autoregressive Model (AR)
     * @param data The input time series data.
     * @param p The order of the autoregressive model.
     * @return predictions The predicted values based on the AR model.
     */
    function autoregressive(uint256[] memory data, uint256 p) public pure returns (uint256[] memory) {
        require(data.length > p, "Insufficient data length");
        uint256[] memory coefficients = new uint256[](p);
        uint256[] memory predictions = new uint256[](data.length - p);
        for (uint256 i = p; i < data.length; i++) {
            uint256 prediction = 0;
            for (uint256 j = 0; j < p; j++) {
                prediction += data[i - j - 1] * coefficients[j];
            }
            predictions[i - p] = prediction;
        }
        return predictions;
    }

    /**
     * @notice Compute lagged values
     * @param data The input time series data.
     * @param lag The lag period.
     * @return lagged The lagged values.
     */
    function laggedValues(uint256[] memory data, uint256 lag) public pure returns (uint256[] memory) {
        require(data.length > lag, "Insufficient data length");
        uint256[] memory lagged = new uint256[](data.length - lag);
        for (uint256 i = lag; i < data.length; i++) {
            lagged[i - lag] = data[i - lag];
        }
        return lagged;
    }

    /**
     * @notice Compute lagged differences
     * @param data The input time series data.
     * @param lag The lag period.
     * @return differences The lagged differences.
     */
    function laggedDifferences(uint256[] memory data, uint256 lag) public pure returns (uint256[] memory) {
        require(data.length > lag, "Insufficient data length");
        uint256[] memory differences = new uint256[](data.length - lag);
        for (uint256 i = lag; i < data.length; i++) {
            differences[i - lag] = data[i] > data[i - lag] ? data[i] - data[i - lag] : data[i - lag] - data[i];
        }
        return differences;
    }

    /**
     * @notice Compute autocorrelation
     * @param data The input time series data.
     * @param lag The lag period.
     * @return autocorr The autocorrelation value.
     */
    function autocorrelation(uint256[] memory data, uint256 lag) public pure returns (int256) {
        require(data.length > lag, "Insufficient data length");
        uint256 meanValue = data.mean();
        int256 numerator = 0;
        int256 denominator = 0;
        for (uint256 i = lag; i < data.length; i++) {
            numerator += int256((data[i] - meanValue) * (data[i - lag] - meanValue));
        }
        for (uint256 i = 0; i < data.length; i++) {
            denominator += int256((data[i] - meanValue) * (data[i] - meanValue));
        }
        return numerator / denominator;
    }

    /**
     * @notice Compute partial autocorrelation (simplified)
     * @param data The input time series data.
     * @param lag The lag period.
     * @return pacf The partial autocorrelation value.
     */
    function partialAutocorrelation(uint256[] memory data, uint256 lag) public pure returns (int256) {
        require(data.length > lag, "Insufficient data length");
        int256[] memory pacf = new int256[](lag + 1);
        pacf[0] = 1;
        for (uint256 k = 1; k <= lag; k++) {
            int256 numerator = 0;
            int256 denominator = 0;
            for (uint256 i = k; i < data.length; i++) {
                numerator += int256((data[i] - data.mean()) * (data[i - k] - data.mean()));
            }
            for (uint256 i = 0; i < data.length; i++) {
                denominator += int256((data[i] - data.mean()) * (data[i] - data.mean()));
            }
            pacf[k] = numerator / denominator;
        }
        return pacf[lag];
    }

    /**
     * @notice Augmented Dickey-Fuller Test (simplified)
     * @param data The input time series data.
     * @param lag The lag period.
     * @return isStationary Boolean indicating if the series is stationary.
     */
    function augmentedDickeyFuller(uint256[] memory data, uint256 lag) public pure returns (bool) {
        require(data.length > lag, "Insufficient data length");
        uint256[] memory differences = laggedDifferences(data, 1);
        uint256[] memory laggedDifferencesData = laggedValues(differences, lag);
        uint256[] memory laggedData = laggedValues(data, lag);
        int256 sum = 0;
        for (uint256 i = 0; i < laggedDifferencesData.length; i++) {
            sum += int256(laggedDifferencesData[i] * laggedData[i]);
        }
        return sum < 0; // Return true if the series is stationary
    }

    /**
     * @notice Seasonal Decomposition of Time Series (STL)
     * @param data The input time series data.
     * @param seasonLength The length of the seasonality period.
     * @return components The decomposed components (trend, seasonal, residual).
     */
    function stlDecomposition(uint256[] memory data, uint256 seasonLength) public pure returns (STLComponents memory) {
        require(data.length >= seasonLength * 2, "Insufficient data length");
        uint256[] memory trend = movingAverage(data, seasonLength);
        uint256[] memory seasonal = new uint256[](data.length);
        uint256[] memory residual = new uint256[](data.length);

        for (uint256 i = 0; i < data.length; i++) {
            if (i < seasonLength || i >= data.length - seasonLength) {
                seasonal[i] = data[i] - trend[i];
                residual[i] = data[i] - trend[i];
            } else {
                seasonal[i] = data[i] - trend[i];
                residual[i] = data[i] - trend[i] - seasonal[i];
            }
        }

        return STLComponents(trend, seasonal, residual);
    }

    /**
     * @notice Calculate moving average
     * @param data The input time series data.
     * @param windowSize The size of the moving average window.
     * @return movAvg The calculated moving average values.
     */
    function movingAverage(uint256[] memory data, uint256 windowSize) public pure returns (uint256[] memory) {
        require(data.length >= windowSize, "Insufficient data length");
        uint256[] memory movAvg = new uint256[](data.length);
        for (uint256 i = 0; i <= data.length - windowSize; i++) {
            uint256 sum = 0;
            for (uint256 j = 0; j < windowSize; j++) {
                sum += data[i + j];
            }
            movAvg[i + windowSize / 2] = sum / windowSize;
        }
        return movAvg;
    }
}
