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

        // this.client1 = '0x2F618C7606F040340Fb2f34f4c58fF2183119913';
        // this.client2 = '0x2F618C7606F040340Fb2f34f4c58fF2183119913';

        this.intermoneyCurrency = await CurrencyContract.new(this.intermoneyToken.address, this.exchanger.address);
        this.dsxtCurrency = await CurrencyContract.new(this.dsxtToken.address, this.exchanger.address);
	})

    describe('exchanger contract', () => {
        it('shoudl check values', async function() {
            const intermoneyValue = 20000;
            const dsxtValue = 20000;
            const client1Value = 10000;
            const client2Value = 5000;
            const client1Rate = 20000;
            const client2Rate = 20000;
            const nonce = 0;
            const tradePrice = 20000;
            const client1Sign = "0xe7e812ed24f9681fa8c72e98eee7add068b9fc0b2a603fb44c639444658ed1796105afa5c166d86b78e02760c7e0be026e3b1207e8f0f6bf88751d8b5386a53b1c";
            const client2Sign = "0x3b81332efb1c5b1a4390baf96a459cfa586ab5230f19c4e52d6890947df90e1c1753bed09a4813693f48f3819e737ad92d35ba94a470f4b782b33d087db5c7ba1c";

            // const client1intermoneyBalance = 9000;
            // const client1dsxtBalance = 2000;
            // const client2intermonyBalance = 1000;
            // const client2dsxtBalance = 18000;

            await this.exchanger.addCurrencyContracts(this.intermoneyCurrency.address, this.dsxtCurrency.address);

            await this.intermoneyToken.transfer(this.client1, intermoneyValue);
            await this.dsxtToken.transfer(this.client2, dsxtValue);

            await this.intermoneyToken.approve(this.intermoneyCurrency.address, intermoneyValue, {from: this.client1});
            await this.dsxtToken.approve(this.dsxtCurrency.address, dsxtValue, {from: this.client2});

            await this.intermoneyCurrency.deposit(intermoneyValue, {from: this.client1});
            await this.dsxtCurrency.deposit(dsxtValue, {from: this.client2});

            console.log('client1 intermoneyToken balance: ', (await this.intermoneyCurrency.balances(this.client1)).toString());
            console.log('client1 dsxtToken balance: ', (await this.dsxtCurrency.balances(this.client1)).toString());
            console.log('client2 intermoneyToken balance: ', (await this.intermoneyCurrency.balances(this.client2)).toString());
            console.log('client2 dsxtToken balance: ', (await this.dsxtCurrency.balances(this.client2)).toString());

            // await this.exchanger.exchange(client1Sign, client2Sign, this.client1, this.client2, [nonce, client1Value,
            //     client1Rate, nonce, client2Value, client2Rate, tradePrice], {from: this.backend});

            // console.log('After exchange:');
            // console.log('client1 intermoneyToken balance: ', (await this.intermoneyCurrency.balances(this.client1)).toString());
            // console.log('client1 dsxtToken balance: ', (await this.dsxtCurrency.balances(this.client1)).toString());
            // console.log('client2 intermoneyToken balance: ', (await this.intermoneyCurrency.balances(this.client2)).toString());
            // console.log('client2 dsxtToken balance: ', (await this.dsxtCurrency.balances(this.client2)).toString());
            //
            // assert.equal((await this.intermoneyCurrency.balances(this.client1)).toString(), client1intermoneyBalance, 'client1intermoneyBalance');
            // assert.equal((await this.dsxtCurrency.balances(this.client1)).toString(), client1dsxtBalance, 'client1dsxtBalance');
            // assert.equal((await this.intermoneyCurrency.balances(this.client2)).toString(), client2intermonyBalance, 'client2intermonyBalance');
            // assert.equal((await this.dsxtCurrency.balances(this.client2)).toString(), client2dsxtBalance, 'client2dsxtBalance');


            // await this.exchanger.exchange(client1Sign, client2Sign, this.client1, this.client2, [nonce, client1Value,
            //     client1Rate, nonce, client2Value, client2Rate, tradePrice], {from: this.backend});
            //
            // console.log('After exchange:');
            // console.log('client1 intermoneyToken balance: ', (await this.intermoneyCurrency.balances(this.client1)).toString());
            // console.log('client1 dsxtToken balance: ', (await this.dsxtCurrency.balances(this.client1)).toString());
            // console.log('client2 intermoneyToken balance: ', (await this.intermoneyCurrency.balances(this.client2)).toString());
            // console.log('client2 dsxtToken balance: ', (await this.dsxtCurrency.balances(this.client2)).toString());
        })
    });
});