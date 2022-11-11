// SPDX-License-Identifier: MIT

pragma solidity <0.9.0;

library WamosMath {
    function splitFirstFiveIntegers(uint256 x, uint256 base)
        public
        pure
        returns (
            uint256 a,
            uint256 b,
            uint256 c,
            uint256 d,
            uint256 e
        )
    {
        a = x % base;
        b = (x / 10) % base;
        c = (x / 100) % base;
        d = (x / 1000) % base;
        e = (x / 10000) % base;
        return (a, b, c, d, e);
    }

    /** Modifies storage array in place */
    function splitAllIntegers(uint256 x, uint256 base, uint256[] storage array)
        public
    {
        while (x > base) {
            array.push(x % base);
            x = x / base;
        }
    }
}
