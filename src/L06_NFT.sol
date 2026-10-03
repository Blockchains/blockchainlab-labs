// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/// @title Lab 06 — ERC-721 with a fixed supply and paid mint.
contract LabNFT is ERC721 {
    uint256 public constant MAX = 100;
    uint256 public constant PRICE = 0.01 ether;
    uint256 public minted;
    address public immutable treasury;
    error SoldOut();
    error WrongPrice();

    constructor(address t) ERC721("Lab NFT", "LNFT") {
        treasury = t;
    }

    function mint() external payable returns (uint256 id) {
        if (minted == MAX) revert SoldOut();
        if (msg.value != PRICE) revert WrongPrice();
        id = ++minted;
        _safeMint(msg.sender, id);
    }

    function withdraw() external {
        payable(treasury).transfer(address(this).balance);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://blockchainlab.com/nft/";
    }
}
