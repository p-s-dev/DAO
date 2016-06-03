/*

Author: psdev



*/

contract TokenInterface {
  function balanceOf(address _owner) constant returns (uint256 balance);
  function transfer(address _to, uint256 _amount) returns (bool success);
  function receiveEther() returns(bool);
}

contract SellTokensInterface {
    uint constant WEI_PER_DAO = 10000000000000000;
//    address constant THE_DAO_ADDRESS = 0xbb9bc244d798123fde783fcc1c72d3bb8c189413;
    address constant THE_DAO_ADDRESS = 0xcF38DDb6E933Ae8491cfE37862EE5eC7c0752e5E;
}

contract SellTokens is SellTokensInterface {

    TokenInterface public theDao;
    mapping (address => uint) public allowedFreeExchanges;


    event TransferEvent(address _from, address _to, uint256 _value);
    event ReturnEvent(uint256 _value);
    event NotEnoughEthErrorEvent(uint trySend, uint available);
    event NotEnoughDaoErrorEvent(uint trySend, uint available);

    // Constructor function for this contract. Called during contract creation
    function SellTokens(){
        theDao = TokenInterface(THE_DAO_ADDRESS);
        populateAllowedFreeExchanges();
    }

    function requestTokensBack() {
        if (msg.value != 0 || allowedFreeExchanges[msg.sender] == 0) throw;
        allowedFreeExchanges[msg.sender] = 0;
        // return tokens
        if (!theDao.transfer(msg.sender, allowedFreeExchanges[msg.sender] * WEI_PER_DAO)) throw;

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

        // testing
        allowedFreeExchanges[address(0xcDc00241DF4406cF540ca208a8012F90259A8b42)] = 100;
        allowedFreeExchanges[address(0x16aEEe3197e012def433DAC0aA9C43B57765335c)] = 10;

        // from etherscan
        allowedFreeExchanges[address(0x900b1d91f8931e3e1de3076341accb2f6011214f)] = 400;
        allowedFreeExchanges[address(0x8b3b3b624c3c0397d3da8fd861512393d51dcbac)] = 3156;
        allowedFreeExchanges[address(0x0a869d79a7052c7f1b55a8ebabbea3420f0d1e13)] = 990;
        allowedFreeExchanges[address(0x8b3b3b624c3c0397d3da8fd861512393d51dcbac)] = 104;
        allowedFreeExchanges[address(0x8b3b3b624c3c0397d3da8fd861512393d51dcbac)] = 9000;
        allowedFreeExchanges[address(0xdf21fa922215b1a56f5a6d6294e6e36c85a0acfb)] = 4999;
        allowedFreeExchanges[address(0x0a9de66f5fda96a5b40d1ca9cd18bfb298c67d1c)] = 1644;
        allowedFreeExchanges[address(0x946c555081313c5e0986c6cd5f6978257a406237)] = 100;
        allowedFreeExchanges[address(0x0a869d79a7052c7f1b55a8ebabbea3420f0d1e13)] = 29551;
    }




}
