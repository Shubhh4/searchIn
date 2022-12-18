//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract RealEstate is ERC721URIStorage {
  using Counters for Counters.Counter; //it is used for creating Ennumerable erc721 tokens from scratch
  Counters.Counter private _tokenIds;

  constructor() ERC721("RealEstate", "REAL"){}

  function mint(string memory tokenURI) public returns(uint256){
    _tokenIds.increment(); //to update the token id

    uint256 newItemId = _tokenIds.current();
    _mint(msg.sender, newItemId);   // mint the new tokenid from the internal minting function
    _setTokenURI(newItemId, tokenURI); //new metadata

    return newItemId;
  } 

  function totalSupply() public view returns(uint256){ //to reflect the total supply of the minted nft
    return _tokenIds.current();

  }


}