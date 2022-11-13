// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Abs {
    /// Pass in a number and get it's absolute value
    function getAbs(int256 _n) public pure returns (int256 result) {
        if (_n < 0) {
            result = -(_n);
        } else {
            result = _n;
        }
    }
}
