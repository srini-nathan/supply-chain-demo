// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;
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

struct Product {
    uint256 id;
    string title;
    string description;
    uint256 date;
    address payable owner;
    uint256 price;
    string image;
}

contract ProductProvenance is ERC721, Roles {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping(address => AssetHistoryElement) private assetHistoryLedger;
    mapping(bytes32 => bool) public forSale;

    //this lets you look up a token by the uri (assuming there is only one of each uri for now)
    mapping(bytes32 => uint256) public uriToTokenId;

    Product[] public products;
    uint256 public lastId;
    mapping(address => mapping(address => Product[])) public sellerProducts; // The published products by the seller

    // Product id => true or false
    mapping(uint256 => bool) public productExists;

    // Product id => product
    mapping(uint256 => Product) public productById;

    constructor(
        bytes32 _assetId,
        bytes32 _assetType,
        address _creator
    ) public ERC721("myProducts", "MPDS") Roles(_creator) {
        AssetHistoryElement memory assetHistory = AssetHistoryElement(_creator, block.timestamp, _assetId, _assetType);
        assetHistoryLedger[address(this)] = assetHistory;
    }

    function getAssetHistoryByContract(address _productProvenance) external view returns (AssetHistoryElement memory) {
        return assetHistoryLedger[_productProvenance];
    }

    function publishProduct(
        string memory _title,
        string memory _description,
        uint256 _price,
        string memory _image
    ) public onlyOwner {
        require(bytes(_title).length > 0, "The title cannot be empty");
        require(bytes(_description).length > 0, "The description cannot be empty");
        require(_price > 0, "The price cannot be empty (denoted in ETH)");
        require(bytes(_image).length > 0, "The image cannot be empty");

        Product memory p = Product(lastId, _title, _description, block.timestamp, msg.sender, _price * 1e18, _image);
        products.push(p);
        sellerProducts[msg.sender][address(this)].push(p);
        productById[lastId] = p;
        productExists[lastId] = true;

        _safeMint(msg.sender, lastId); // Create a new token for this product which will be owned by owner until sold
        lastId++;
    }

    function getProduct(uint256 _id)
        public
        view
        returns (
            uint256 id,
            string memory title,
            string memory description,
            uint256 date,
            address payable owner,
            uint256 price,
            string memory image
        )
    {
        Product memory p = productById[_id];
        id = p.id;
        title = p.title;
        description = p.description;
        date = p.date;
        owner = p.owner;
        price = p.price;
        image = p.image;
    }

    function exists(uint256 tokenId) public view returns (bool) {
        return _exists(tokenId);
    }

    function getAllProductIds() public view returns (Product[] memory) {
        return sellerProducts[msg.sender][address(this)];
    }
}
