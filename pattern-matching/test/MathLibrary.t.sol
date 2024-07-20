// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/MathLibrary.sol";

contract MathLibraryTest is Test {
    using MathLibrary for uint256[];

    function testMean() pure public {
        uint256[] memory data = new uint256[](5);
        data[0] = 1;
        data[1] = 2;
        data[2] = 3;
        data[3] = 4;
        data[4] = 5;

        uint256 expected = 3;
        uint256 result = data.mean();

        assertEq(result, expected, "Mean calculation is incorrect");
    }

    function testMedianOdd() pure public {
        uint256[] memory data = new uint256[](5);
        data[0] = 1;
        data[1] = 2;
        data[2] = 3;
        data[3] = 4;
        data[4] = 5;

        uint256 expected = 3;
        uint256 result = data.median();

        assertEq(result, expected, "Median calculation for odd length is incorrect");
    }

    function testMedianEven() pure public {
        uint256[] memory data = new uint256[](4);
        data[0] = 1;
        data[1] = 2;
        data[2] = 4;
        data[3] = 5;

        uint256 expected = 3; // (2 + 4) / 2
        uint256 result = data.median();

        assertEq(result, expected, "Median calculation for even length is incorrect");
    }

    function testMode() pure public {
        uint256[] memory data = new uint256[](5);
        data[0] = 1;
        data[1] = 2;
        data[2] = 2;
        data[3] = 3;
        data[4] = 4;

        uint256 expected = 2;
        uint256 result = data.mode();

        assertEq(result, expected, "Mode calculation is incorrect");
    }

    function testMax() pure public {
        uint256[] memory data = new uint256[](5);
        data[0] = 1;
        data[1] = 2;
        data[2] = 3;
        data[3] = 4;
        data[4] = 5;

        uint256 expected = 5;
        uint256 result = data.max();

        assertEq(result, expected, "Max calculation is incorrect");
    }

    function testMin() pure public {
        uint256[] memory data = new uint256[](5);
        data[0] = 1;
        data[1] = 2;
        data[2] = 3;
        data[3] = 4;
        data[4] = 5;

        uint256 expected = 1;
        uint256 result = data.min();

        assertEq(result, expected, "Min calculation is incorrect");
    }

    function testStandardDeviation() pure public {
        uint256[] memory data = new uint256[](8);
        data[0] = 2;
        data[1] = 4;
        data[2] = 4;
        data[3] = 4;
        data[4] = 5;
        data[5] = 5;
        data[6] = 7;
        data[7] = 9;

        uint256 expected = 2; // The expected result here is a simplified version.
        uint256 result = data.standardDeviation();

        assertEq(result, expected, "Standard Deviation calculation is incorrect");
    }

    function testSort() pure public {
        uint256[] memory data = new uint256[](5);
        data[0] = 5;
        data[1] = 3;
        data[2] = 4;
        data[3] = 1;
        data[4] = 2;

        uint256[] memory expected = new uint256[](5);
        expected[0] = 1;
        expected[1] = 2;
        expected[2] = 3;
        expected[3] = 4;
        expected[4] = 5;

        uint256[] memory result = data.sort();

        for (uint256 i = 0; i < data.length; i++) {
            assertEq(result[i], expected[i], "Sort function is incorrect");
        }
    }

    function testSqrt() pure public {
        uint256 data = 16;
        uint256 expected = 4;
        uint256 result = MathLibrary.sqrt(data);

        assertEq(result, expected, "Square root calculation is incorrect");
    }
}
