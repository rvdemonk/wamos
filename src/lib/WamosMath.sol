// SPDX-License-Identifier: MIT

pragma solidity <0.9.0;

library WamosMath {
    function splitFirstFiveIntegers(uint256 x, uint256 mod)
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
        a = x % mod;
        b = (x / 10) % mod;
        c = (x / 100) % mod;
        d = (x / 1000) % mod;
        e = (x / 10000) % mod;
        return (a, b, c, d, e);
    }

    // function splitWordForTenDigits(uint256 word)
    //     public
    //     pure
    //     returns (uint256[10] memory digits)
    // {
    //     for (uint256 i = 0; i < 10; i++) {
    //         digits.push((word / (10 * i)) % 10);
    //     }
    // }
}
