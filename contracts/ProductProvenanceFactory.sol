// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

import "./ProductProvenance.sol";

contract ProductProvenanceFactory {
    address[] private deployedSupplyChainAssets;

    function createAssetType(bytes32 _assetId, bytes32 _assetType) public {
        ProductProvenance newProductProvenance = new ProductProvenance(_assetId, _assetType, msg.sender);
        deployedSupplyChainAssets.push(address(newProductProvenance));
    }

    function getAllSupplyChainAssets() public view returns (address[] memory) {
        return deployedSupplyChainAssets;
    }
}
