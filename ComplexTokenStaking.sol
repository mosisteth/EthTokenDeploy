pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ComplexToken is ERC20, ERC20Burnable, Ownable {
    // Staking reward rate
    uint256 public stakingRewardRate = 5; // 5%

    // Staking state
    struct Stake {
        uint256 amount;
        uint256 timestamp;
    }

    mapping(address => Stake) public stakes;

    constructor() ERC20("ComplexToken", "CMPLX") {
        _mint(msg.sender, 1000000 * (10 ** uint256(decimals())));
    }

    // Staking function
    function stake(uint256 _amount) public {
        require(balanceOf(msg.sender) >= _amount, "Not enough tokens to stake");
        _burn(msg.sender, _amount);
        stakes[msg.sender] = Stake(_amount, block.timestamp);
    }

    // Calculate rewards
    function calculateReward(address _staker) public view returns (uint256) {
        Stake memory staked = stakes[_staker];
        if (staked.amount == 0) return 0;
        uint256 duration = block.timestamp - staked.timestamp;
        return (staked.amount * stakingRewardRate * duration) / (100 * 365 days);
    }

    // Unstaking function with rewards
    function unstake() public {
        uint256 reward = calculateReward(msg.sender);
        _mint(msg.sender, stakes[msg.sender].amount + reward);
        delete stakes[msg.sender];
    }

    // Additional features like governance can be added here
}

