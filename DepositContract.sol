// Constructs a sample deposit contract were depositor initiates deposit and withdrawal and bank pays a fixed interest (150)
pragma solidity ^0.8.24;

contract SavingsAccount {
    // Parties involved
    address public bank;
    address public depositor;

    // Deposit details
    uint256 public depositAmount; // Deposited amount
    uint256 public constant BASE_RATE = 100; // Base for interest rate calculations (avoid overflow with high percentages)

    // State variables
    uint256 public startTime; // Timestamp of deposit

    // Events
    event Deposited(address indexed depositor, uint256 amount);
    event Withdrawn(address indexed depositor, uint256 amount);

    // Constructor (called when the contract is deployed)
    constructor(address _depositor,uint256 depositAmount) public {
        depositor = _depositor;
        
        bank = msg.sender;
        startTime = block.timestamp;
    }

    // Function for depositor to deposit money
    function deposit() public payable {
        require(msg.sender == depositor, "Only depositor can deposit");
        depositAmount += depositAmount;
        emit Deposited(depositor, msg.value);
    }

    // Function for depositor to withdraw all funds and accrued interest
    function withdrawAll() public {
        require(msg.sender == depositor, "Only depositor can withdraw");

        // Calculate accrued interest based on elapsed time
        uint256 timeElapsed = block.timestamp - startTime;
        uint256 interestRate = BASE_RATE + BASE_RATE * 3 / 2; // 150% = 100 (base) + 150 (additional 150%)
        uint256 interestAccrued = depositAmount * interestRate * timeElapsed / (365 days * BASE_RATE);

        // Update total amount and transfer (principal + interest)
        uint256 totalAmount = depositAmount + interestAccrued;
        depositAmount = 0;
        payable(depositor).transfer(totalAmount);

        emit Withdrawn(depositor, totalAmount);
    }
}
