const CurrencyContract = artifacts.require('CurrencyContract');
const IntermoneyToken = artifacts.require('IntermoneyToken');
const DsxtToken = artifacts.require('DsxtToken');
const Exchanger = artifacts.require('Exchanger');

contract('CurrencyContract', accounts => {

    beforeEach(async function() {
		this.owner = accounts[0];
		this.intermoneyToken = await IntermoneyToken.new();
        this.dsxtToken = await DsxtToken.new();
        this.backend = accounts[9];
        this.exchanger = await Exchanger.new(this.backend);

        this.client1 = accounts[1];
        this.client2 = accounts[2];

        this.intermoneyCurrency = await CurrencyContract.new(this.intermoneyToken.address, this.exchanger.address);
        this.dsxtCurrency = await CurrencyContract.new(this.dsxtToken.address, this.exchanger.address);
	})

    describe('it should work', () => {
        it('should run', async function() {
            await this.dsxtToken.transfer(accounts[1], 1000);
            //create order
            const nonce = 1;
            const sellValue = 1000;
            const sellRate = 10;
            const direction = false;

            const soliditySha3 = web3.utils.soliditySha3(
                {t: 'uint256', v: nonce},
                {t: 'uint256', v: sellValue},
                {t: 'uint256', v: sellRate},
                {t: 'bool', v: direction}
            );

            const address = '0x2F618C7606F040340Fb2f34f4c58fF2183119913';
            const hexSignature = '0x37b19f2d7d6f728cab3209050cfe83c4214948e69fee4cd1ef663c6b03abb817319c388dc66e776bd58f2b2b9eed6cf48e2983c97edbafff380f96733d70f9ae1b';

            const result = await this.exchanger.checkSignature(address,
                nonce, sellValue, sellRate, direction, hexSignature)

            assert.equal(result, true, 'wrong signature');

        });
    });
});