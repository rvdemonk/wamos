// SPDX-License-Identifier: MIT

pragma solidity <0.9.0;

/**
 * @dev @notice VERY EXPERIMENTAL; WILL BE HEAVILY MODIFIED FOR RELEASE
 *              MANY FUNCTIONS ARE MERELY DRAFTS
 */

library WamosMathV1 {
    function splitFirstFiveIntegers(
        uint256 x,
        uint256 base
    )
        public
        pure
        returns (uint256 a, uint256 b, uint256 c, uint256 d, uint256 e)
    {
        a = x % base;
        b = (x / 10) % base;
        c = (x / 100) % base;
        d = (x / 1000) % base;
        e = (x / 10000) % base;
        return (a, b, c, d, e);
    }

    /** Modifies storage array in place */
    function splitAllIntegers(
        uint256 x,
        uint256 base,
        uint256[] storage array
    ) public {
        while (x > base) {
            array.push(x % base);
            x = x / base;
        }
    }

    function splitSecondFiveIntegers(
        uint256 x,
        uint256 base
    )
        public
        pure
        returns (uint256 a, uint256 b, uint256 c, uint256 d, uint256 e)
    {
        a = (x / 100000) % base;
        b = (x / 1000000) % base;
        c = (x / 10000000) % base;
        d = (x / 100000000) % base;
        e = (x / 1000000000) % base;
        return (a, b, c, d, e);
    }

    function splitFirstFiveIntegersArray(
        uint256 x,
        uint256 base
    ) public pure returns (uint256[5] memory values) {
        uint256 a = x % base;
        uint256 b = (x / 10) % base;
        uint256 c = (x / 100) % base;
        uint256 d = (x / 1000) % base;
        uint256 e = (x / 10000) % base;
        values = [a, b, c, d, e];
        return values;
    }
}
