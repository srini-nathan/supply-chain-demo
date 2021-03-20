// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./accessControl/Roles.sol";

 struct AssetHistoryElement {
    address creator; 
    uint256 timestamp;
    bytes32 assetId;
    bytes32 assetType;
  }

contract ProductProvenance is ERC721, Roles {

    address private owner;

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping(address => AssetHistoryElement) private assetHistoryLedger;
    mapping (bytes32 => bool) public forSale;

    //this lets you look up a token by the uri (assuming there is only one of each uri for now)
    mapping (bytes32 => uint256) public uriToTokenId;

    constructor(bytes32 _assetId, bytes32 _assetType, address _creator) 
    public 
    ERC721("myProducts", "MPDS") 
    Roles(_creator) {
      owner = _creator;
      AssetHistoryElement memory assetHistory = AssetHistoryElement(owner, block.timestamp,  _assetId, _assetType);
      assetHistoryLedger[address(this)] = assetHistory;
    }

    function getAssetHistoryByContract(address _productProvenance) external view returns (AssetHistoryElement memory) {
      return assetHistoryLedger[_productProvenance];
    }

    function mintProduct(string memory _tokenURI) public returns (uint256) {
      // Generate hash from tokenURI | Can I also use my own generated TokenID?  
      bytes32 uriHash = keccak256(abi.encodePacked(_tokenURI));

      // Make sure the uriHash is still for sale
      require(forSale[uriHash],"NOT FOR SALE");

      // Make sure the token is not for sale anymore
      forSale[uriHash] = false;

      // Increase token counter | Can I also use my own generated TokenID?  
      _tokenIds.increment();

      // Use current token counter as ID
      uint256 id = _tokenIds.current();

      // Mint the NFT and attach the token with the current ID to the message sender
      _mint(msg.sender, id);

      // Save the tokenID and tokenURI combination
      uriToTokenId[uriHash] = id;

      emit ProductMintToken(msg.sender, id, uriHash);

      return id;
    }

    function setProductForSale(string memory tokenURI) public {
      // Generate hash from tokenURI | Can I also use my own generated TokenID?  
      bytes32 uriHash = keccak256(abi.encodePacked(tokenURI));

      // Make sure the uriHash is still not for sale
      require(!forSale[uriHash],"IS ALREADY FOR SALE");

      // Make sure the token is for sale anymore
      forSale[uriHash] = true;
  }

    function updateProduct (uint _tokenID, string memory _oldTokenURI, string memory _newTokenURI) public onlyOwner {

      bytes32 newUriHash = keccak256(abi.encodePacked(_newTokenURI));
      bytes32 oldUriHash = keccak256(abi.encodePacked(_oldTokenURI));

      require(!forSale[newUriHash],"IS ALREADY FOR SALE");
      require(!forSale[oldUriHash],"IS ALREADY FOR SALE");

      
      require(uriToTokenId[oldUriHash] == _tokenID,"WRONG PRODUCT");

        delete uriToTokenId[oldUriHash];

        _setTokenURI(_tokenID, _newTokenURI);
        
        uriToTokenId[newUriHash] = _tokenID;

        emit UpdateTokenURI(_tokenID, _newTokenURI);
    }


    function unsetProductForSale(string memory tokenURI) public onlyOwner {
      // Generate hash from tokenURI | Can I also use my own generated TokenID?  
      bytes32 uriHash = keccak256(abi.encodePacked(tokenURI));

      // Make sure the uriHash is still for sale
      require(forSale[uriHash],"NOT FOR SALE");

      // Make sure the token is not for sale anymore
      forSale[uriHash] = false;
  }

    function burnToken (uint _tokenID) public onlyOwner {
        _burn(_tokenID);
        emit BurnToken(_tokenID);
    }

    event ProductMintToken(address _owner, uint _tokenID, bytes32 _uriHash);
    event UpdateTokenURI(uint _tokenID, string _tokenURI);
    event BurnToken(uint _tokenID);
    
}
