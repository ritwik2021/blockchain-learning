// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * @dev This is a NFT contract where a user can claim a token having a Title and Date.
 * This date is once claimed will never be claimed again by any other user.
 * to claim, user have to perform a  transaction of 1000000000000000 WEI or 0.001 ETH
 */

contract YourDate is Ownable, ERC721 {
    struct Metadata {
        string title;
        uint256 day;
        uint256 month;
        uint256 year;
    }

    uint256 constant TRANSACTION_FEE = 0.001 ether;
    uint256 constant SECONDS_PER_DAY = 24 * 60 * 60; // 24hrs in seconds

    mapping(uint256 => Metadata) id_to_date;

    constructor() ERC721("YourDate", "DATE") {
        mint("Test Origin", 1, 1, 2022); // 1st mint
    }

    // Function to mint NFT
    function mint(
        string memory title,
        uint256 day,
        uint256 month,
        uint256 year
    ) internal {
        uint256 tokenId = dateValue(day, month, year);
        id_to_date[tokenId] = Metadata(title, day, month, year);
        _safeMint(msg.sender, tokenId);
    }

    // returns the calculation of date along with month and year
    function dateValue(
        uint256 day,
        uint256 month,
        uint256 year
    ) internal pure returns (uint256) {
        require(1 <= day && day <= numDaysInMonth(month, year));
        return
            (uint256(day) - 1) +
            ((uint256(month) - 1) * 31) +
            ((uint256(year) - 1) * 372);
    }

    // calculate number of days in a month
    function numDaysInMonth(uint256 month, uint256 year)
        public
        pure
        returns (uint256)
    {
        require(
            1 <= month && month <= 12,
            "month should be in between 1 and 12"
        );
        require(1 <= year, "year must be greater than or equals to 1");

        if (
            month == 1 ||
            month == 3 ||
            month == 5 ||
            month == 7 ||
            month == 8 ||
            month == 10 ||
            month == 12
        ) {
            return 31;
        } else if (month == 2) {
            return isLeapYear(year) ? 29 : 28;
        } else {
            return 30;
        }
    }

    // check is leap year or not and returns boolean value
    function isLeapYear(uint256 year) public pure returns (bool) {
        require(1 <= year, "year must be greater than or equals to 1");
        return (((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0));
    }

    // function to claim NFT
    function claimToken(
        string calldata title,
        uint256 day,
        uint256 month,
        uint256 year
    ) external payable {
        require(
            msg.value == TRANSACTION_FEE,
            "Claiming a date at cost of ETH 0.001"
        );

        (
            uint256 latest_day,
            uint256 latest_month,
            uint256 latest_year
        ) = timestampToDate(block.timestamp);
        if (
            (year > latest_year) ||
            (year == latest_year && month > latest_month) ||
            (year == latest_year && month == latest_month && day > latest_day)
        ) {
            revert("Future date cant't be claimed...");
        }

        mint(title, day, month, year);
        payable(owner()).transfer(TRANSACTION_FEE);
    }

    function timestampToDate(uint256 timestamp)
        internal
        pure
        returns (
            uint256 day,
            uint256 month,
            uint256 year
        )
    {
        (day, month, year) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }

    function _daysToDate(uint256 _days)
        internal
        pure
        returns (
            uint256 day,
            uint256 month,
            uint256 year
        )
    {
        int256 __days = int256(_days);

        int256 L = __days + 68569 + 2440588;
        int256 N = (4 * L) / 146097;
        L = L - (146097 * N + 3) / 4;
        int256 _year = (4000 * (L + 1)) / 1461001;
        L = L - (1461 * _year) / 4 + 31;
        int256 _month = (80 * L) / 2447;
        int256 _day = L - (2447 * _month) / 80;
        L = _month / 11;
        _month = _month + 2 - 12 * L;
        _year = 100 * (N - 49) + _year + L;

        year = uint256(_year);
        month = uint256(_month);
        day = uint256(_day);
    }

    function getToken(uint256 tokenId)
        external
        view
        returns (
            string memory title,
            uint256 day,
            uint256 month,
            uint256 year
        )
    {
        require(_exists(tokenId), "token not minted");
        Metadata memory date = id_to_date[tokenId];
        title = date.title;
        day = date.day;
        month = date.month;
        year = date.year;
    }

    function ownerOf(
        uint256 day,
        uint256 month,
        uint256 year
    ) public view returns (address) {
        return ownerOf(dateValue(day, month, year));
    }
}
