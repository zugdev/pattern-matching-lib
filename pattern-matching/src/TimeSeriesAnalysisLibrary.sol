// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./MathLibrary.sol";

/**
 * @title TimeSeriesAnalysis
 * @dev Library for advanced time series analysis including AR, ADF, STL, FFT, and more.
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
     * @dev Predicts future values based on past values in the time series. This is useful in finance for modeling and forecasting stock prices.
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
     * @dev Useful for creating lag features in time series data, which can be used in various statistical models.
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
     * @dev This is used to transform a non-stationary time series into a stationary one by calculating differences between consecutive values.
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
     * @dev Measures the linear relationship between lagged values of the time series, useful for identifying repeating patterns or cycles.
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
     * @dev Measures the linear relationship between lagged values of the time series, controlling for the values at all shorter lags.
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
     * @dev Tests whether a time series is stationary or not. Stationarity is a key assumption in many time series models.
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
     * @dev Decomposes a time series into trend, seasonal, and residual components. Useful for understanding underlying patterns.
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
     * @dev Smooths out short-term fluctuations and highlights longer-term trends or cycles. Commonly used in financial markets to analyze stock prices.
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

    /**
     * @notice Discrete Fast Fourier Transform (FFT)
     * @dev Transforms a time series into its frequency components. Useful for identifying periodic patterns in the data.
     * @param real The real part of the input time series data.
     * @param imag The imaginary part of the input time series data (usually zeros for real input).
     * @return freqs The frequency components of the input time series.
     */
    function fft(int256[] memory real, int256[] memory imag) public pure returns (int256[] memory, int256[] memory) {
        uint256 n = real.length;
        require(n == imag.length, "Input arrays must have the same length");
        require(n & (n - 1) == 0, "Input array length must be a power of 2");

        for (uint256 i = 0; i < n; i++) {
            uint256 j = reverseBits(i, log2(n));
            if (i < j) {
                (real[i], real[j]) = (real[j], real[i]);
                (imag[i], imag[j]) = (imag[j], imag[i]);
            }
        }

        for (uint256 len = 2; len <= n; len <<= 1) {
            int256 ang = -2 * 3141592653589793 / int256(len); // -2 * PI / len
            int256 wlenR = cos(ang);
            int256 wlenI = sin(ang);
            for (uint256 i = 0; i < n; i += len) {
                int256 wr = 1;
                int256 wi = 0;
                for (uint256 j = 0; j < len / 2; j++) {
                    int256 uR = real[i + j];
                    int256 uI = imag[i + j];
                    int256 vR = (real[i + j + len / 2] * wr - imag[i + j + len / 2] * wi) / 1e18;
                    int256 vI = (real[i + j + len / 2] * wi + imag[i + j + len / 2] * wr) / 1e18;
                    real[i + j] = uR + vR;
                    imag[i + j] = uI + vI;
                    real[i + j + len / 2] = uR - vR;
                    imag[i + j + len / 2] = uI - vI;
                    int256 nextWr = (wr * wlenR - wi * wlenI) / 1e18;
                    wi = (wr * wlenI + wi * wlenR) / 1e18;
                    wr = nextWr;
                }
            }
        }

        return (real, imag);
    }

    function reverseBits(uint256 x, uint256 n) internal pure returns (uint256) {
        uint256 result = 0;
        for (uint256 i = 0; i < n; i++) {
            if ((x & (1 << i)) != 0) {
                result |= 1 << (n - 1 - i);
            }
        }
        return result;
    }

    function log2(uint256 x) internal pure returns (uint256) {
        uint256 result = 0;
        while (x >>= 1 != 0) {
            result++;
        }
        return result;
    }

    function cos(int256 x) internal pure returns (int256) {
        // Approximate cosine function using Taylor series
        int256 ONE = 1e18;
        int256 x2 = (x * x) / ONE;
        return ONE - x2 / 2 + (x2 * x2) / (24 * ONE) - (x2 * x2 * x2) / (720 * ONE);
    }

    function sin(int256 x) internal pure returns (int256) {
        // Approximate sine function using Taylor series
        int256 ONE = 1e18;
        int256 x2 = (x * x) / ONE;
        return x - (x * x2) / (6 * ONE) + (x * x2 * x2) / (120 * ONE) - (x * x2 * x2 * x2) / (5040 * ONE);
    }
}