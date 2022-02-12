// SPDX-License-IdentifierL: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NFTMarket is ReentrancyGuard {
    // General Init
    // Explanation: _itemsIds is a Struct that holds the amount of items (NFT's) the contract has,
    //              since initialized from Counters,
    //              _itemIds has access to Counters functions such as .current() / .increase() etc..

    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;

    address payable owner;

    uint256 listingPrice = 0.025 ether;

    constructor() {
        owner = payable(msg.sender);
    }

    struct MarketItem {
        uint256 itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    // TODO: Learn more about the mapping function.
    mapping(uint256 => MarketItem) private idToMarketItem;

    event MarketItemCreated(
        uint256 indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    function createMarketItem(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) public payable nonReentrant {
        require(price > 0, "Price must be at least 1 wei.");
        require(
            msg.value == listingPrice,
            "Price must be equal to listing price."
        );

        _itemIds.increment();
        uint256 itemId = _itemIds.current();

        // Current MarketItem struct ready to ship.
        idToMarketItem[itemId] = MarketItem(
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            payable(address(0)),
            price,
            false
        );

        // Transfer Ownership
        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        // Trigger the item creation event
        emit MarketItemCreated(
            itemId,
            nftContract,
            tokenId,
            msg.sender,
            address(0),
            price,
            false
        );
    }

    function createMarketSale(address nftContract, uint256 itemId)
        public
        payable
        nonReentrant
    {
        uint256 price = idToMarketItem[itemId].price;
        uint256 tokenId = idToMarketItem[itemId].tokenId;

        // Check if the buyer is asking for the actual price of the item.
        require(
            msg.value == price,
            "Pleasse Submit the asking price in order to complete the purchase."
        );

        // Transfer the value of the transaction to the seller.
        idToMarketItem[itemId].seller.transfer(msg.value);

        // Tranfer the ownership of the token to the buyer.
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);

        // Setting the buyer address to be the owner of the token.
        idToMarketItem[itemId].owner = payable(msg.sender);

        // Setting the item to sold.
        idToMarketItem[itemId].sold = true;

        // Incrementing the amount of items sold.
        _itemsSold.increment();

        // Pay the owner of the contract. ( Commission for the market place creator :) )
        payable(owner).transfer(listingPrice);
    }
}

// 47:00
