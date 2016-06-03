/*

Author: psdev



*/

contract TokenInterface {
  function balanceOf(address _owner) constant returns (uint256 balance);
  function transfer(address _to, uint256 _amount) returns (bool success);
  function receiveEther() returns(bool);
}

contract SellTokensInterface {
    uint constant PROPOSED = 0;
    uint constant SIGNED   = 1;
    uint constant DAO_PER_ETH = 100;
    uint constant WEI_PER_ETH = 1000000000000000000;
    uint constant RETURN_TOKEN_GRACE_PERIOD = 5 days;
}

contract SellTokens is SellTokensInterface {

    TokenInterface public theDao;
    uint public state = PROPOSED;
    uint public signedDate = 0;
    mapping (address => uint) public allowedFreeExchanges;


    event TransferEvent(address _from, address _to, uint256 _value);
    event ReturnEvent(uint256 _value);
    event NotEnoughEthErrorEvent(uint trySend, uint available);
    event NotEnoughDaoErrorEvent(uint trySend, uint available);

    // Constructor function for this contract. Called during contract creation
    function SellTokens(){
        //theDao = TokenInterface(0xbb9bc244d798123fde783fcc1c72d3bb8c189413);
        theDao = TokenInterface(0xd00f1c987bE018456568B8FDdB93C5780A590Ed1);
        populateAllowedFreeExchanges();
    }

    function sign() {
        if (state == PROPOSED && msg.sender == address(theDao)) {
            state = SIGNED;
            signedDate = now;
        }
    }

    function requestTokensBack() {
        if (msg.value != 0 || allowedFreeExchanges[msg.sender] == 0) throw;

        if (state != SIGNED || now > signedDate + RETURN_TOKEN_GRACE_PERIOD) throw;

        // return tokens
        if (!theDao.transfer(msg.sender, allowedFreeExchanges[msg.sender] * WEI_PER_ETH * DAO_PER_ETH)) throw;

    }

    function buy100DaoFor1Eth(){

        var tokens_to_send = msg.value;
        uint daoBalance = theDao.balanceOf(this);
        if (tokens_to_send > daoBalance) {
            NotEnoughDaoErrorEvent(tokens_to_send, daoBalance);
            throw;
        }

        if (msg.sender.send(allowedFreeExchanges[msg.sender])) {
        }
        if (msg.value > this.balance) {
            NotEnoughEthErrorEvent(msg.value, this.balance);
            throw;
        }

        // send tokens back to buyer
        if (!theDao.transfer(msg.sender, tokens_to_send)) throw;
        TransferEvent(this, msg.sender, tokens_to_send);
        // send eth from buyer to dao
        if (!theDao.receiveEther.value(msg.value)()) throw;
        ReturnEvent(msg.value);

    }

    // accounts and amounts sent to dao, rounded down & only txn > 100 tokens
    function populateAllowedFreeExchanges() internal {
        allowedFreeExchanges[address(0x8f0e61b52499dd240229be1d64b3d0af35c7b1f32b06a1ecaf9fb661c98f2e14)] = 400;
        allowedFreeExchanges[address(0x02f7eff29590a097ebde43b74ac0795689c6299ad0946d0bae52473b060df7bf)] = 3156;
        allowedFreeExchanges[address(0xf6915c39e097cf34ea5ff6e789483b9e02a665b563f87766e3d6335bff783c72)] = 990;
        allowedFreeExchanges[address(0x614a870bf33156463d68713e533bd93cbcb8acc2ac2600fbe090585efcc0583c)] = 104;
        allowedFreeExchanges[address(0x221622572b905eb45e4ed95a7fbf31ed5f334c6fc7a24ed53f2d61c79f874087)] = 9000;
        allowedFreeExchanges[address(0x6378c774ed07c8fb4335ef5c6cf52f2a175aabff8d1149cf05189a0cb93f47e9)] = 4999;
        allowedFreeExchanges[address(0x08590207ef9fc84d0ad51444def6093f1c98d139becc7037d1dc1506098f90b8)] = 1644;
        allowedFreeExchanges[address(0xbd58e9a69e9661f37444547cbc08f3b8a850d3d2c779be5f555882843581154b)] = 100;
        allowedFreeExchanges[address(0xce2256317ae738cb8d973ec0a00d3cca737a8874b57973729c001c16d87a750f)] = 29551;
    }




}
