// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

library MathLibrary {
    function mean(uint256[] memory data) public pure returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i < data.length; i++) {
            sum += data[i];
        }
        return sum / data.length;
    }

    // there is a fancier ll approach see: https://github.com/gnosis/dx-price-oracle/blob/fcf2dd0fac65754ed1f99f899cb95799892f5d5a/contracts/DutchXPriceOracle.sol#L80
    function median(uint256[] memory data) public pure returns (uint256) {
        uint256[] memory sortedData = sort(data);
        uint256 middle = data.length / 2;
        if (data.length % 2 == 0) {
            return (sortedData[middle - 1] + sortedData[middle]) / 2;
        } else {
            return sortedData[middle];
        }
    }

    function mode(uint256[] memory data) public pure returns (uint256) {
        uint256[] memory frequency = new uint256[](data.length);
        uint256 maxFreq = 0;
        uint256 modeValue = data[0];
        for (uint256 i = 0; i < data.length; i++) {
            frequency[data[i]]++;
            if (frequency[data[i]] > maxFreq) {
                maxFreq = frequency[data[i]];
                modeValue = data[i];
            }
        }
        return modeValue;
    }

    function max(uint256[] memory data) public pure returns (uint256) {
        uint256 maxValue = data[0];
        for (uint256 i = 1; i < data.length; i++) {
            if (data[i] > maxValue) {
                maxValue = data[i];
            }
        }
        return maxValue;
    }

    function min(uint256[] memory data) public pure returns (uint256) {
        uint256 minValue = data[0];
        for (uint256 i = 1; i < data.length; i++) {
            if (data[i] < minValue) {
                minValue = data[i];
            }
        }
        return minValue;
    }

    function standardDeviation(uint256[] memory data) public pure returns (uint256) {
        uint256 meanValue = mean(data);
        uint256 varianceSum = 0;
        for (uint256 i = 0; i < data.length; i++) {
            uint256 diff = data[i] > meanValue ? data[i] - meanValue : meanValue - data[i];
            varianceSum += diff * diff;
        }
        uint256 variance = varianceSum / data.length;
        return sqrt(variance);
    }

    // to get median without sorting look at: https://github.com/gnosis/dx-price-oracle/blob/fcf2dd0fac65754ed1f99f899cb95799892f5d5a/contracts/DutchXPriceOracle.sol#L80
    function sort(uint256[] memory data) internal pure returns (uint256[] memory) {
        uint256[] memory sortedData = data;
        quickSort(sortedData, int(0), int(sortedData.length - 1));
        return sortedData;
    }

    function quickSort(uint256[] memory arr, int left, int right) internal pure {
        int i = left;
        int j = right;
        if (i == j) return;
        uint256 pivot = arr[uint(left + (right - left) / 2)];
        while (i <= j) {
            while (arr[uint(i)] < pivot) i++;
            while (pivot < arr[uint(j)]) j--;
            if (i <= j) {
                (arr[uint(i)], arr[uint(j)]) = (arr[uint(j)], arr[uint(i)]);
                i++;
                j--;
            }
        }
        if (left < j) quickSort(arr, left, j);
        if (i < right) quickSort(arr, i, right);
    }

    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}
