// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AggregatorV3Interface} from "@chainlink/local/src/data-feeds/interfaces/AggregatorV3Interface.sol";

contract PriceReader {
    AggregatorV3Interface public immutable PRICE_FEED;

    constructor(address priceFeedAddress) {
        PRICE_FEED = AggregatorV3Interface(priceFeedAddress);
    }

    function getLatestPrice() public view returns (int256) {
        (, int256 answer, , ,) = PRICE_FEED.latestRoundData();
        return answer;
    }

    function getDecimals() public view returns (uint8) {
        return PRICE_FEED.decimals();
    }

    function getPriceIn18Decimals() public view returns (int256) {
        int256 price = getLatestPrice();
        uint8 decimals = getDecimals();

        if (decimals == 18) {
            return price;
        }

        if (decimals < 18) {
            uint256 factor = 10 ** (18 - decimals);
            return price * _toInt256(factor);
        }

        uint256 divisor = 10 ** (decimals - 18);
        return price / _toInt256(divisor);
    }

    function _toInt256(uint256 value) private pure returns (int256) {
        require(value <= uint256(type(int256).max), "Value too large");
        // forge-lint: disable-next-line(unsafe-typecast)
        return int256(value);
    }
}
