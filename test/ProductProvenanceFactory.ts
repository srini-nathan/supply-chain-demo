import { ethers, waffle, artifacts } from "hardhat";
import { Artifact } from "hardhat/types";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";
import { ProductProvenanceFactory } from "../typechain/ProductProvenanceFactory";
import { ProductProvenance } from "../typechain/ProductProvenance";
import { Signers } from "../types";
import { expect } from "chai";
import { Contract } from "ethers";

const { deployContract } = waffle;

describe("Unit tests", function () {
  let admin: SignerWithAddress;
  before(async function () {
    const signers: SignerWithAddress[] = await ethers.getSigners();
    admin = signers[0];
  });

  describe("ProductProvenanceFactory", function () {
    let productProvenanceFactoryArtifact: Artifact;
    let ProductProvenanceArtifact: Artifact;
    let productProvenanceFactory: Contract;
    let productProvenance: Contract;
    beforeEach(async function () {
      productProvenanceFactoryArtifact = await artifacts.readArtifact("ProductProvenanceFactory");
      ProductProvenanceArtifact = await artifacts.readArtifact("ProductProvenance");
      productProvenanceFactory = <ProductProvenanceFactory>(
        await deployContract(admin, productProvenanceFactoryArtifact)
      );
    });

    it("should return empty assets", async function () {
      expect(await productProvenanceFactory.connect(admin).getAllSupplyChainAssets()).to.eql([]);
    });

    it("should create asset type", async () => {
      const assetId = ethers.utils.formatBytes32String("ckmhns7au000001kygiq5gnak");
      const assetType = ethers.utils.formatBytes32String("Medical");
      await productProvenanceFactory.connect(admin).createAssetType(assetId, assetType, admin.address);

      const assetContractAddress = await productProvenanceFactory.connect(admin).getAllSupplyChainAssets();

      productProvenance = await ethers.getContractAt(ProductProvenanceArtifact.abi, assetContractAddress[0]);
      expect(assetContractAddress[0]).to.eql(productProvenance.address);

      const resultAssetHistory = await productProvenance
        .connect(admin)
        .getAssetHistoryByContract(assetContractAddress[0]);

      expect(resultAssetHistory["assetType"]).to.eql(assetType);
      expect(resultAssetHistory["assetId"]).to.eql(assetId);
      expect(resultAssetHistory["creator"]).to.eql(admin.address);
    });
  });
});
