const SponsorToken = artifacts.require("./SponsorToken.sol");

module.exports = (deployer) => {
    deployer.deploy(SponsorToken);
};