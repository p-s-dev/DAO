// <ORACLIZE_API>
/*
Copyright (c) 2015-2016 Oraclize srl, Thomas Bertani



Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:



The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.



THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

contract OraclizeI {
    address public cbAddress;
    function query(uint _timestamp, string _datasource, string _arg) returns (bytes32 _id);
    function query_withGasLimit(uint _timestamp, string _datasource, string _arg, uint _gaslimit) returns (bytes32 _id);
    function query2(uint _timestamp, string _datasource, string _arg1, string _arg2) returns (bytes32 _id);
    function query2_withGasLimit(uint _timestamp, string _datasource, string _arg1, string _arg2, uint _gaslimit) returns (bytes32 _id);
    function getPrice(string _datasource) returns (uint _dsprice);
    function getPrice(string _datasource, uint gaslimit) returns (uint _dsprice);
    function useCoupon(string _coupon);
    function setProofType(byte _proofType);
}
contract OraclizeAddrResolverI {
    function getAddress() returns (address _addr);
}
contract usingOraclize {
    uint constant day = 60*60*24;
    uint constant week = 60*60*24*7;
    uint constant month = 60*60*24*30;
    byte constant proofType_NONE = 0x00;
    byte constant proofType_TLSNotary = 0x10;
    byte constant proofStorage_IPFS = 0x01;
    uint8 constant networkID_auto = 0;
    uint8 constant networkID_mainnet = 1;
    uint8 constant networkID_testnet = 2;
    uint8 constant networkID_morden = 2;
    uint8 constant networkID_consensys = 161;

    OraclizeAddrResolverI OAR;

    OraclizeI oraclize;
    modifier oraclizeAPI {
        address oraclizeAddr = OAR.getAddress();
        if (oraclizeAddr == 0){
            oraclize_setNetwork(networkID_auto);
            oraclizeAddr = OAR.getAddress();
        }
        oraclize = OraclizeI(oraclizeAddr);
        _
    }
    modifier coupon(string code){
        oraclize = OraclizeI(OAR.getAddress());
        oraclize.useCoupon(code);
        _
    }

    function oraclize_setNetwork(uint8 networkID) internal returns(bool){
        if (getCodeSize(0x1d3b2638a7cc9f2cb3d298a3da7a90b67e5506ed)>0){
            OAR = OraclizeAddrResolverI(0x1d3b2638a7cc9f2cb3d298a3da7a90b67e5506ed);
            return true;
        }
        if (getCodeSize(0x9efbea6358bed926b293d2ce63a730d6d98d43dd)>0){
            OAR = OraclizeAddrResolverI(0x9efbea6358bed926b293d2ce63a730d6d98d43dd);
            return true;
        }
        if (getCodeSize(0x20e12a1f859b3feae5fb2a0a32c18f5a65555bbf)>0){
            OAR = OraclizeAddrResolverI(0x20e12a1f859b3feae5fb2a0a32c18f5a65555bbf);
            return true;
        }
        return false;
    }

    function oraclize_query(string datasource, string arg) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oraclize.query.value(price)(0, datasource, arg);
    }
    function oraclize_query(uint timestamp, string datasource, string arg) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oraclize.query.value(price)(timestamp, datasource, arg);
    }
    function oraclize_query(uint timestamp, string datasource, string arg, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        return oraclize.query_withGasLimit.value(price)(timestamp, datasource, arg, gaslimit);
    }
    function oraclize_query(string datasource, string arg, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        return oraclize.query_withGasLimit.value(price)(0, datasource, arg, gaslimit);
    }
    function oraclize_query(string datasource, string arg1, string arg2) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oraclize.query2.value(price)(0, datasource, arg1, arg2);
    }
    function oraclize_query(uint timestamp, string datasource, string arg1, string arg2) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oraclize.query2.value(price)(timestamp, datasource, arg1, arg2);
    }
    function oraclize_query(uint timestamp, string datasource, string arg1, string arg2, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        return oraclize.query2_withGasLimit.value(price)(timestamp, datasource, arg1, arg2, gaslimit);
    }
    function oraclize_query(string datasource, string arg1, string arg2, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        return oraclize.query2_withGasLimit.value(price)(0, datasource, arg1, arg2, gaslimit);
    }
    function oraclize_cbAddress() oraclizeAPI internal returns (address){
        return oraclize.cbAddress();
    }
    function oraclize_setProof(byte proofP) oraclizeAPI internal {
        return oraclize.setProofType(proofP);
    }

    function getCodeSize(address _addr) constant internal returns(uint _size) {
        assembly {
            _size := extcodesize(_addr)
        }
    }


    function parseAddr(string _a) internal returns (address){
        bytes memory tmp = bytes(_a);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint i=2; i<2+2*20; i+=2){
            iaddr *= 256;
            b1 = uint160(tmp[i]);
            b2 = uint160(tmp[i+1]);
            if ((b1 >= 97)&&(b1 <= 102)) b1 -= 87;
            else if ((b1 >= 48)&&(b1 <= 57)) b1 -= 48;
            if ((b2 >= 97)&&(b2 <= 102)) b2 -= 87;
            else if ((b2 >= 48)&&(b2 <= 57)) b2 -= 48;
            iaddr += (b1*16+b2);
        }
        return address(iaddr);
    }


    function strCompare(string _a, string _b) internal returns (int) {
        bytes memory a = bytes(_a);
        bytes memory b = bytes(_b);
        uint minLength = a.length;
        if (b.length < minLength) minLength = b.length;
        for (uint i = 0; i < minLength; i ++)
            if (a[i] < b[i])
                return -1;
            else if (a[i] > b[i])
                return 1;
        if (a.length < b.length)
            return -1;
        else if (a.length > b.length)
            return 1;
        else
            return 0;
   }

    function indexOf(string _haystack, string _needle) internal returns (int)
    {
        bytes memory h = bytes(_haystack);
        bytes memory n = bytes(_needle);
        if(h.length < 1 || n.length < 1 || (n.length > h.length))
            return -1;
        else if(h.length > (2**128 -1))
            return -1;
        else
        {
            uint subindex = 0;
            for (uint i = 0; i < h.length; i ++)
            {
                if (h[i] == n[0])
                {
                    subindex = 1;
                    while(subindex < n.length && (i + subindex) < h.length && h[i + subindex] == n[subindex])
                    {
                        subindex++;
                    }
                    if(subindex == n.length)
                        return int(i);
                }
            }
            return -1;
        }
    }

    function strConcat(string _a, string _b, string _c, string _d, string _e) internal returns (string){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
        for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
        for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
        for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];
        return string(babcde);
    }

    function strConcat(string _a, string _b, string _c, string _d) internal returns (string) {
        return strConcat(_a, _b, _c, _d, "");
    }

    function strConcat(string _a, string _b, string _c) internal returns (string) {
        return strConcat(_a, _b, _c, "", "");
    }

    function strConcat(string _a, string _b) internal returns (string) {
        return strConcat(_a, _b, "", "", "");
    }

    // parseInt
    function parseInt(string _a) internal returns (uint) {
        return parseInt(_a, 0);
    }

    // parseInt(parseFloat*10^_b)
    function parseInt(string _a, uint _b) internal returns (uint) {
        bytes memory bresult = bytes(_a);
        uint mint = 0;
        bool decimals = false;
        for (uint i=0; i<bresult.length; i++){
            if ((bresult[i] >= 48)&&(bresult[i] <= 57)){
                if (decimals){
                   if (_b == 0) break;
                    else _b--;
                }
                mint *= 10;
                mint += uint(bresult[i]) - 48;
            } else if (bresult[i] == 46) decimals = true;
        }
        return mint;
    }


}
// </ORACLIZE_API>


contract DaoInterface {

    // Token Creation
    uint public closingTime;

    // Token
    uint256 public totalSupply;
    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _amount) returns (bool success);

    // Dao
    address public curator;
    uint public minQuorumDivisor;
    modifier onlyTokenholders {}
    function actualBalance() constant returns (uint _actualBalance);
    function halveMinQuorum() returns (bool _success);
    function changeAllowedRecipients(address _recipient, bool _allowed) external returns (bool _success);
    function getNewDAOAddress(uint _proposalID) constant returns (address _newDAO);
    function numberOfProposals() constant returns (uint _numberOfProposals);
    function newProposal(
        address _recipient,
        uint _amount,
        string _description,
        bytes _transactionData,
        uint _debatingPeriod,
        bool _newCurator
    ) onlyTokenholders returns (uint _proposalID);
    function vote(
        uint _proposalID,
        bool _supportsProposal
    ) onlyTokenholders returns (uint _voteID);
    function splitDAO(
        uint _proposalID,
        address _newCurator
    ) returns (bool _success);
    function executeProposal(
        uint _proposalID,
        bytes _transactionData
    ) returns (bool _success);
    function proposals(uint _proposalID) returns(
        address recipient,
        uint amount,
        uint descriptionIdx,
        uint votingDeadline,
        bool open,
        bool proposalPassed,
        bytes32 proposalHash,
        uint proposalDeposit,
        bool newCurator,
//        SplitData[] splitData,
        uint yea,
        uint nay,
//        mapping (address => bool) votedYes,
//        mapping (address => bool) votedNo,
        address creator
    );
    struct Proposal {
        // The address where the `amount` will go to if the proposal is accepted
        // or if `newCurator` is true, the proposed Curator of
        // the new DAO).
        address recipient;
        // The amount to transfer to `recipient` if the proposal is accepted.
        uint amount;
        // A plain text description of the proposal
        string description;
        // A unix timestamp, denoting the end of the voting period
        uint votingDeadline;
        // True if the proposal's votes have yet to be counted, otherwise False
        bool open;
        // True if quorum has been reached, the votes have been counted, and
        // the majority said yes
        bool proposalPassed;
        // A hash to check validity of a proposal
        bytes32 proposalHash;
        // Deposit in wei the creator added when submitting their proposal. It
        // is taken from the msg.value of a newProposal call.
        uint proposalDeposit;
        // True if this proposal is to assign a new Curator
        bool newCurator;
        // Data needed for splitting the DAO
        SplitData[] splitData;
        // Number of Tokens in favor of the proposal
        uint yea;
        // Number of Tokens opposed to the proposal
        uint nay;
        // Simple mapping to check if a shareholder has voted for it
        mapping (address => bool) votedYes;
        // Simple mapping to check if a shareholder has voted against it
        mapping (address => bool) votedNo;
        // Address of the shareholder who created the proposal
        address creator;
    }
   struct SplitData {
        // The balance of the current DAO minus the deposit at the time of split
        uint splitBalance;
        // The total amount of DAO Tokens in existence at the time of split.
        uint totalSupply;
        // Amount of Reward Tokens owned by the DAO at the time of split.
        uint rewardToken;
        // True if the split dao can accept new eth during creation
        bool publicCreation;
        // The new DAO contract created at the time of split.
//        DAO newDAO;
    }
}

contract AutoSplitCurator is usingOraclize {
//    uint constant minProposalDebatePeriod = 2 weeks;
    uint constant minProposalDebatePeriod = 5 minutes;
//    uint constant minSplitDebatePeriod = 1 weeks;
    uint constant minSplitDebatePeriod = 5 minutes;
    address public parentDaoAddress;
    address public childDaoAddress;
    DaoInterface parentDao;
    DaoInterface childDao;
    address public splitInitiator;
    uint public latestAutoCuratorSplitProposalId;
    uint public latestAutoCuratorWithdrawProposalId;
    uint public parentDaoSplitProposalId;

    bytes32 public oraclizeSplitProposalId;
    bytes32 public oraclizeSplitExecutionId;
    bytes32 public oraclizeRefundProposalId;

    modifier onlySplitter {
        if (msg.sender != splitInitiator)
            throw;
        _
    }

//    function AutoSplitCurator(address _parentDaoAddress, address _splitInitiator) {
    function AutoSplitCurator() {
        parentDaoAddress = 0x121F19E6Ce30900Cdd199484A0837EaD841FdDA9;
        parentDao = DaoInterface(parentDaoAddress);
        splitInitiator = address(msg.sender);
    }

    function proposeSplit() onlySplitter {
        latestAutoCuratorSplitProposalId = parentDao.newProposal(address(this),
                             0,
                             "AutoCurator split proposal",
                             "",
                             minSplitDebatePeriod,
                             true);
        parentDao.vote(latestAutoCuratorSplitProposalId, true);
        oraclizeSplitProposalId = oraclize_query(now + minSplitDebatePeriod + 1, "URL","");
    }

    // wait minSplitDebatePeriod, then call this
    function executeParentDaoSplit() onlySplitter {
        parentDao.splitDAO(latestAutoCuratorSplitProposalId, address(this));
        childDaoAddress = parentDao.getNewDAOAddress(latestAutoCuratorSplitProposalId);
        childDao = DaoInterface(childDaoAddress);
        oraclizeSplitExecutionId = oraclize_query(childDao.closingTime() + 1, "URL","");
    }

    // must send 1 child-dao to AutoSplitCurator
    // TODO: executing transaction seems broken when proposal is created via this script
    // TODO: also make proposal to get funds from extraBalance
    // TODO: integrate orcalize for automatic scheduled execution
    // wait creation then call this
    function prepareWithdrawProposalGivenSplitProposalId() onlySplitter {
        childDao.halveMinQuorum();
        childDao.changeAllowedRecipients(splitInitiator, true);
        latestAutoCuratorWithdrawProposalId = childDao.newProposal(splitInitiator,
                             childDao.balance,
                             "AutoCurator withdraw proposal",
                             "",
                             minProposalDebatePeriod,
                             false);
        childDao.vote(latestAutoCuratorWithdrawProposalId, true);
        oraclizeRefundProposalId = oraclize_query(now + minProposalDebatePeriod + 1, "URL","");
    }

    function executeChildDaoProposal(uint _proposalID) onlySplitter {
        childDao.executeProposal(_proposalID, "");
    }

    function __callback(bytes32 myid, string result) {
        if (msg.sender != oraclize_cbAddress()) throw;

        if (myid == oraclizeSplitProposalId) {
            executeParentDaoSplit();
        } else if (myid == oraclizeSplitExecutionId) {
            prepareWithdrawProposalGivenSplitProposalId();
        } else if (myid == oraclizeRefundProposalId) {
            executeChildDaoProposal(latestAutoCuratorWithdrawProposalId);
        }
    }

    function withdrawDao() onlySplitter {
        if (!parentDao.transfer(msg.sender, parentDao.balanceOf(address(this)))) throw;
    }

    function withdrawChildDao() onlySplitter {
        if (!childDao.transfer(msg.sender, childDao.balanceOf(address(this)))) throw;
    }

    function withdrawEth() onlySplitter {
        if (!msg.sender.send(this.balance)) throw;
    }


}

