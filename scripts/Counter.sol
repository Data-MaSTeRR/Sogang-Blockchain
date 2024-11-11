// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Counter {
    // 카운터의 상태 변수
    int256 private count;

    // 카운터 값을 증가시키는 함수
    function inc() public {
        count += 1;
    }

    // 카운터 값을 감소시키는 함수
    function dec() public {
        count -= 1;
    }

    // 현재 카운터 값을 반환하는 함수
    function get() public view returns (int256) {
        return count;
    }
}
