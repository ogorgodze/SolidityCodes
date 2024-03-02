// CBDC toy model with intrest rate payments
pragma solidity ^0.8.24;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
contract CBDC is ERC20 {
    address public CentralBank;
    uint public IRBasisPoints=100;
    mapping(address=>bool) public blacklist;
    mapping(address=>uint) private stakedTreasuryBond;
    mapping (address=>uint) private stakedTS;
    event UpdateControllingParty(address oldControllingParty, address newControllingParty);
    event UpdateIntrestRate(uint oldIR, uint newIR);
    event IncreseM0(uint oldM0, uint newM0);
    event UpdateBlackList(address AML_CFT, bool block);
    event StakeTresuryBonds(address user, uint amount);
    event UnstakeTresuryBonds(address user, uint amount);
    event ClaimTreasuryBonds(address user, uint amount);

    constructor(address _CentralBank, uint initialM0)
        ERC20("Central Bank Digital Currency", "CBDC") {
        CentralBank=_CentralBank;
        _mint(CentralBank,initialM0);
    }
    function updateControllingParty(address newControllingParty) external {
        require(msg.sender==CentralBank,"You are not the Central Bank");
        CentralBank=newControllingParty;
        _transfer(CentralBank, newControllingParty, balanceOf(CentralBank));
        emit UpdateControllingParty(msg.sender, newControllingParty);
    }
    function updateIR(uint newIRBasisPoints) external {
        require(msg.sender==CentralBank,"You are not the Central Bank");
        uint oldIRBasisPoint=IRBasisPoints;
        IRBasisPoints=newIRBasisPoints;
        emit UpdateIntrestRate(oldIRBasisPoint, newIRBasisPoints);
    }
    function increaseM0(uint inflationAmount) external {
        require(msg.sender==CentralBank,"You are not the Central Bank");
        uint oldM0=totalSupply();
        _mint(msg.sender,inflationAmount);
    }
    function updateBlackList(address AML_CFT, bool blacklisted) external {
        require(msg.sender==CentralBank,"You are not the Central Bank");
        blacklist[AML_CFT]=blacklisted;
        emit UpdateBlackList(AML_CFT, blacklisted);
    }
    function stakeTreasuryBonds(uint amount) external {
        require(amount>0, "Savings are 0!");
        require(balanceOf(msg.sender)>=amount, "Your balance is not enough");
        _transfer(msg.sender,address(this),amount);
        if(stakedTreasuryBond[msg.sender]>0) claimTreasuryBonds();
        stakedTS[msg.sender]=block.timestamp;
        stakedTreasuryBond[msg.sender]+=amount;
        emit StakeTresuryBonds(msg.sender, amount);
    }
    function unstakeTreasuryBonds(uint amount) public {
        require(amount>0, "Saving is 0");
        require(stakedTreasuryBond[msg.sender]>=amount,"You want more tha you have saved");
        claimTreasuryBonds();
        stakedTreasuryBond[msg.sender] -=amount;
        _transfer(address(this),msg.sender,amount);
    }
    function claimTreasuryBonds() public {
        require(stakedTreasuryBond[msg.sender]>0,"You have not saved anything");
        uint secondsStaked=block.timestamp-stakedTS[msg.sender];
        uint rewards=stakedTreasuryBond[msg.sender]*secondsStaked*IRBasisPoints/(10000*60*60*24*365);
        stakedTS[msg.sender]=block.timestamp;
        emit ClaimTreasuryBonds(msg.sender, rewards);
    }
    function _transfer(address from, address to, uint amount) internal virtual override {
        require(blacklist[from]==false, "Sender is in AML-CFT list");
        require(blacklist[to]==false,"Reciver is in ALM-CFT list");
        super._transfer(from, to, amount);
    }




}
