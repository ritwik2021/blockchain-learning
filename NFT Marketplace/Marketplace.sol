// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NFTMarketPlace {
    // counters for counting the stats
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _nftSold;

    IERC20 public tokenAddress;
    address private owner;
    uint256 private platformFee = 25; // platform fee
    uint256 private deno = 1000; //denominator

    constructor(address _tokenAddress) {
        owner = payable(msg.sender);
        tokenAddress = IERC20(_tokenAddress);
    }

    struct NFTMarketItem {
        uint256 nftId;
        uint256 tokenId;
        uint256 price;
        uint256 royalty;
        address payable seller;
        address payable owner;
        address nftContract;
        bool sold;
    }

    mapping(uint256 => NFTMarketItem) private marketItem;

    // this will list the nft to the market place
    function listNft(
        address nftContract,
        uint256 tokenId,
        uint256 price,
        uint256 royalty
    ) public {
        require(royalty >= 0, "royalty should be between 0 to 30");
        require(royalty < 29, "royalty should be less than 30");

        _nftIds.increment();
        uint256 nftId = _nftIds.current();

        marketItem[nftId] = NFTMarketItem(
            nftId,
            tokenId,
            price,
            royalty,
            payable(msg.sender),
            payable(address(0)),
            nftContract,
            false
        );
        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);
    }

    //  User will able to buy NFT from the marketplace and transfer it
    function buyNft(uint256 tokenId) public payable {
        uint256 price = marketItem[tokenId].price;
        uint256 royaltyPer = (price * marketItem[tokenId].royalty) / deno;
        uint256 marketFee = (price * platformFee) / deno;

        tokenAddress.transferFrom(msg.sender, address(this), price);
        tokenAddress.transferFrom(msg.sender, address(owner), royaltyPer);
        tokenAddress.transferFrom(msg.sender, address(this), marketFee);

        marketItem[tokenId].owner = payable(msg.sender);
        _nftSold.increment();

        IERC721(marketItem[tokenId].nftContract).transferFrom(
            address(this),
            msg.sender,
            tokenId
        );
    }
}
