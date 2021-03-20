// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./ProductProvenance.sol";

contract ProductProvenanceFactory {
    address[] private deployedSupplyChainAssets;
    uint256 public count=0;

    function createAssetType(bytes32 _assetId, bytes32 _assetType, address _creator) public {
        ProductProvenance newProductProvenance = new ProductProvenance(_assetId, _assetType, _creator);
        deployedSupplyChainAssets.push(address(newProductProvenance));
        count++;
    }

    function getAllSupplyChainAssets() public view returns (address[] memory) {
        return deployedSupplyChainAssets;
    }
}

