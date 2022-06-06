const Airbnb =artifacts.require("Airbnb");
const SCALING_FACTOR= web3.utils.toBN(10).pow(web3.utils.toBN(18))

contract("Airbnb", async function(accounts){
   let airbnb
    beforeEach(async function(){
     airbnb=await Airbnb.new()
    })

    it("rentOutSpace",async function(){
        const price=web3.utils.toBN('25').mul(SCALING_FACTOR).div(web3.utils.toBN(100))//0.25 Ether
        const advertiseProperty =await airbnb.rentOutProperty(
            "BGT",
            "Area in Banglore",
            price
        )
        const propertyId=advertiseProperty.receipt.logs[0].args.propertyId

        let rentProperty = await airbnb.rentProperty(
            propertyId,
            6,
            8,{value: web3.utils.toWei('0.5','ether'),from:accounts[1]}
        )

        assert.ok(rentProperty.receipt.logs[0].args.propertyId.eq(propertyId))
        assert.ok(rentProperty.receipt.logs[0].args.bookingId.eq(web3.utils.toBN(0)))

        try{
            await airbnb.rentProperty(
                propertyId,
                6,
                8,
                {value:web3.utils.toWei('0.5','ether'),from: accounts[1]}
            )
            assert.fail('should have failed')
        }catch(e){
            assert.ok(e.reason.includes('property is not available for the selected dates'))
        }
        rentProperty=await airbnb.rentProperty(
            propertyId,
            113,
            116,
            {value:web3.utils.toWei('0.75','ether'),from:accounts[2]}
        )
        assert.ok(rentProperty.receipt.logs[0].args.propertyId.eq(propertyId))
      //  assert.ok(rentProperty.receipt.logs[0].arsg.bookingId.eq(web3.utils.toBN(1)))
    })
})