// SPDX-License-IdentifierL: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFT is ERC721URIStorage {
    // General Init
    // _tokenIds - Struct that holds the amount of items (NFT's) the contract has,
    //             Since initialized from Counters,
    //             _tokenIds has access to Counters functions such as .current() / .increase() etc..
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address contractAddress;

    constructor(address marketPlaceAddress) ERC721("Metaverse Tokens", "METT") {
        contractAddress = marketPlaceAddress;
    }

    function createToken(string memory tokenURI) public returns (uint256) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        // ERC-721 & ERC721URIStorage inherited functions.
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);
        setApprovalForAll(contractAddress, true);
        return newItemId;
    }
}
