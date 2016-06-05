contract DaoInterface {

    address public curator;
    uint256 public totalSupply;
    uint public minQuorumDivisor;
    modifier onlyTokenholders {}
    function actualBalance() constant returns (uint _actualBalance);
    function balanceOf(address _owner) constant returns (uint256 balance);
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

contract AutoSplitCurator {
//    uint constant minProposalDebatePeriod = 2 weeks;
    uint constant minProposalDebatePeriod = 5 minutes;
    address public parentDaoAddress;
    address public childDaoAddress;
    DaoInterface parentDao;
    DaoInterface childDao;
    address public splitInitiator;
    uint public latestAutoCuratorGeneratedProposalId;
    uint public parentDaoSplitProposalId;

    function AutoSplitCurator(address _parentDaoAddress, address _splitInitiator) {
        parentDaoAddress = _parentDaoAddress;
        parentDao = DaoInterface(_parentDaoAddress);
        splitInitiator = _splitInitiator;
    }

    function initializeWithParentDaoSplitProposalId(uint _proposalID) {
        var (recipient,,,,,,,,,,,creator) = parentDao.proposals(_proposalID);
        if (recipient != address(this) || creator != splitInitiator) throw;
        parentDaoSplitProposalId = _proposalID;
        childDaoAddress = parentDao.getNewDAOAddress(_proposalID);
        childDao = DaoInterface(childDaoAddress);

        // add debugMinQuorumRequired, debugSplitInitiatorOwns calculations here
    }

    // must send 1 child-dao to AutoSplitCurator
    // TODO: executing transaction seems broken when proposal is created via this script
    // TODO: also make proposal to get funds from extraBalance
    // TOTO: build-in the transaction to create the split against the parent-dao, and vote, and call splitDao
    // TODO: integrate orcalize for automatic scheduled execution
    function prepareWithdrawProposalGivenSplitProposalId() {
        childDao.halveMinQuorum();
        childDao.changeAllowedRecipients(splitInitiator, true);
        bytes bites;
        latestAutoCuratorGeneratedProposalId = childDao.newProposal(splitInitiator,
                             childDao.balance,
                             "AutoCurator withdraw proposal",
                             bites,
                             minProposalDebatePeriod,
                             false);
        childDao.vote(latestAutoCuratorGeneratedProposalId, true);
    }



//    function changeAllowedRecipients() {
//        childDao.changeAllowedRecipients(splitInitiator, true);
//    }

//    function newProposal() {
//        latestAutoCuratorGeneratedProposalId = childDao.newProposal(splitInitiator,
//                             childDao.balance,
//                             "AutoCurator withdraw proposal",
//                             "",
//                             minProposalDebatePeriod,
//                             false);
//    }

//    function vote() {
//        childDao.vote(latestAutoCuratorGeneratedProposalId, true);
//    }

//    function lowerQuorum() {
//        childDao.halveMinQuorum();
//    }

    function debugMinQuorumRequired() returns (uint _minQuorum) {
        return childDao.totalSupply() / childDao.minQuorumDivisor() +
            (childDao.balance * childDao.totalSupply()) / (3 * (childDao.actualBalance()));
    }

    function debugSplitInitiatorOwns() returns (uint _minQuorum) {
        return childDao.balanceOf(splitInitiator);
    }


}

