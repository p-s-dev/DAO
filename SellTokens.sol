contract TokenInterface {
  function balanceOf(address _owner) constant returns (uint256 balance);
  function allowance(address _owner, address _spender) constant returns (uint256 remaining);
  function transfer(address _to, uint256 _amount) returns (bool success);
  function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
  function receiveEther() returns(bool);
}

contract BuyBackOffer_v2 {
    TokenInterface public tokenObj;

    event TransferEvent(address _from, address _to, uint256 _value);
    event ReturnEvent(uint256 _value);
    event NotEnoughEthErrorEvent(uint trySend, uint available);
    event NotEnoughDaoErrorEvent(uint trySend, uint available);
    event LowBalance(uint trySend, uint available);
    event LowAllowance(uint trySend, uint available);

    // Constructor function for this contract. Called during contract creation
    function BuyBackOffer_v2(){
        tokenObj = TokenInterface(0x87cd17715607a2eeE5ef7d292317A858EBd8f5f5);
    }

    // @dev allows eth or dao to be sent to the contract
    function deposit(){
        return;
    }

    // sell dao back to DTH at price double ico
    function exchange1EthFor50Dao(){
        
        var tokens_to_send = msg.value / 2;
        uint daoBalance = tokenObj.balanceOf(this);
        if (tokens_to_send > daoBalance) {
            NotEnoughDaoErrorEvent(tokens_to_send, daoBalance);
            throw;
        }
        
        if (msg.value > this.balance) {
            NotEnoughEthErrorEvent(msg.value, this.balance);
            throw;
        }

        // send tokens back to buyer
        if (!tokenObj.transfer(msg.sender, tokens_to_send)) throw;
        TransferEvent(this, msg.sender, tokens_to_send);
        // send eth from buyer to dao
        if (!tokenObj.receiveEther.value(msg.value)()) throw;
        ReturnEvent(msg.value);

    }

    // buy dao from DTH at ico price
    // Must call dao.allow(100000000000000000) for 1 eth
    function exchange100DaoFor1Eth(){

        var tokens_to_send = msg.value;

        uint daoBalance = tokenObj.balanceOf(msg.sender);
        if (daoBalance < tokens_to_send) {
            LowBalance(tokens_to_send, daoBalance);
            tokens_to_send = daoBalance;
        }
            
        uint daoAllowance = tokenObj.allowance(msg.sender, this);
        if (daoAllowance < tokens_to_send) {
            LowAllowance(tokens_to_send, daoAllowance);
            tokens_to_send = daoAllowance;
        }

        var eth_to_return = msg.value + tokens_to_send;
        if (eth_to_return > this.balance) {
            NotEnoughEthErrorEvent(eth_to_return, this.balance);
            throw;
        }

        if (!tokenObj.transferFrom(msg.sender, this, tokens_to_send)) throw;
        TransferEvent(msg.sender, this, tokens_to_send);
        if (!msg.sender.send(eth_to_return)) throw;
        ReturnEvent(eth_to_return);
    }

}
