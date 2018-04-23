const SponsorToken = artifacts.require("SponsorToken");

contract('SponsorToken', (accounts) => {
    let contract;
    const ponzi = 110;
    const tokenCreator = accounts[0];

    it("should deploy contract successfully", async () => {
        contract = await SponsorToken.deployed();
    });

    it("should supply zero token after contract was deployed", async () => {
        const totalSupply = await contract.totalSupply.call();
        assert.equal(totalSupply.toNumber(), 0);
    });

    it("should create token correctly", async () => {
        const transaction = await contract.create(ponzi, { from: tokenCreator });
        const [_id, _creator, _value, _head, _ponzi] = await contract.tokens.call(0);

        assert.equal(_id.toNumber(), 0);
        assert.equal(_creator, tokenCreator);
        assert.equal(_value.toNumber(), 0);
        assert.equal(_head.toNumber(), 0);
        assert.equal(_ponzi.toNumber(), ponzi);
    });

    it("should supply one token after the first token was created", async () => {
        const totalSupply = await contract.totalSupply.call();
        assert.equal(totalSupply.toNumber(), 1);
    });
});