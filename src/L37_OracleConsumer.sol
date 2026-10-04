// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// Chainlink AggregatorV3Interface (subset).
interface AggregatorV3Interface {
    function decimals() external view returns (uint8);
    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}

/// @title Lab 37 — Safe price-feed consumption: staleness, negative/zero answers, decimals normalisation.
contract OracleConsumer {
    AggregatorV3Interface public immutable feed;
    uint256 public immutable maxAge;
    error Stale();
    error BadAnswer();

    constructor(AggregatorV3Interface f, uint256 maxAge_) {
        feed = f;
        maxAge = maxAge_;
    }

    /// @return price with 18 decimals
    function price() public view returns (uint256) {
        (, int256 a,, uint256 updatedAt,) = feed.latestRoundData();
        if (a <= 0) revert BadAnswer();
        if (updatedAt == 0 || block.timestamp - updatedAt > maxAge) revert Stale();
        uint8 d = feed.decimals();
        return d <= 18 ? uint256(a) * 10 ** (18 - d) : uint256(a) / 10 ** (d - 18);
    }

    /// USD value (18 decimals) of `amount` tokens that have `tokenDecimals` decimals.
    function valueOf(uint256 amount, uint8 tokenDecimals) external view returns (uint256) {
        return amount * price() / 10 ** tokenDecimals;
    }
}
