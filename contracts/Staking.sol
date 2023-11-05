//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract Staking is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Deposit Item
    struct DepositItem {
        uint256 apy;
        uint256 duration;
        uint256 amount;
        uint256 timestamp;
    }

    // Info of each user.
    struct UserInfo {
        uint256 amount;             // Total amount
        DepositItem[] depositItems; // Deposited list
    }

    IERC20 public immutable stakingToken;
    IERC20 public immutable rewardToken;

    uint256 public startedTimestamp;
    address public feeAddress;
    uint256 public totalStaked;
    uint256 public apy1;
    uint256 public apy2;
    uint256 public apy3;
    uint256 public exitPenaltyPerc;
    uint256 public withdrawFee;

    mapping (address => UserInfo) private userInfo;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);

    constructor(address tokenAddr, address feeAddr) {
        stakingToken = IERC20(tokenAddr);
        rewardToken = stakingToken;
        feeAddress = feeAddr;

        apy1 = 10;
        apy2 = 15;
        apy3 = 27;

        exitPenaltyPerc = 5;
        withdrawFee = 2;
        startedTimestamp = 0;
        totalStaked = 0;
    }

    function _calculateReward(address _user, uint256 _index) internal view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        require(_index < user.depositItems.length, "Index out of bound");
        if (startedTimestamp == 0 || user.amount == 0)
            return 0;
        
        uint256 dt;
        if (startedTimestamp > user.depositItems[_index].timestamp)
            dt = block.timestamp - startedTimestamp;
        else
            dt = block.timestamp - user.depositItems[_index].timestamp;
        
        if (dt > user.depositItems[_index].duration)
            dt = user.depositItems[_index].duration;
        
        return (user.depositItems[_index].amount * dt) * user.depositItems[_index].apy / 100 / 365 days;
    }

    function startReward() external onlyOwner {
        require(startedTimestamp == 0, "Can only start rewards once");
        startedTimestamp = block.timestamp;
    }

    function stopReward() external onlyOwner {
        startedTimestamp = 0;
        apy1 = 0;
        apy2 = 0;
        apy3 = 0;
    }

    function getStakedTokens(address _user) external view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        return user.amount;
    }

    function getStakedItemLength(address _user) external view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        return user.depositItems.length;
    }

    function getStakedItemAPY(address _user, uint256 _index) external view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        require(_index < user.depositItems.length, "Index out of bound");
        return user.depositItems[_index].apy;
    }

    function getStakedItemDuration(address _user, uint256 _index) external view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        require(_index < user.depositItems.length, "Index out of bound");
        return user.depositItems[_index].duration;
    }

    function getStakedItemAmount(address _user, uint256 _index) external view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        require(_index < user.depositItems.length, "Index out of bound");
        return user.depositItems[_index].amount;
    }

    function getStakedItemReward(address _user, uint256 _index) external view returns (uint256) {
        return _calculateReward(_user, _index);
    }

    function getStakedItemTimestamp(address _user, uint256 _index) external view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        require(_index < user.depositItems.length, "Index out of bound");
        if (startedTimestamp > user.depositItems[_index].timestamp)
            return startedTimestamp;
        return user.depositItems[_index].timestamp;
    }

    function getStakedItemElapsed(address _user, uint256 _index) external view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        require(_index < user.depositItems.length, "Index out of bound");

        uint256 depositTimestamp = user.depositItems[_index].timestamp;
        if (startedTimestamp > depositTimestamp)
            depositTimestamp = startedTimestamp;

        return block.timestamp - depositTimestamp;
    }

    // Stake primary tokens
    function deposit(uint256 _amount, uint256 _option) public nonReentrant {
        require(_amount > 0, "Invalid Amount");
        require(_option == 1 || _option == 2 || _option == 3, "Invalid Option");

        UserInfo storage user = userInfo[msg.sender];
        uint256 initialBalance = stakingToken.balanceOf(address(this));
        stakingToken.safeTransferFrom(address(msg.sender), address(this), _amount);

        uint256 amountTransferred = stakingToken.balanceOf(address(this)) - initialBalance;
        user.amount = user.amount.add(amountTransferred);
        totalStaked += amountTransferred;

        uint256 apy;
        uint256 duration;
        if (_option == 1) {
            apy = apy1;
            duration = 30 days;
        }
        else if (_option == 2) {
            apy = apy2;
            duration = 60 days;
        }
        else {
            apy = apy3;
            duration = 120 days;
        }

        user.depositItems.push(DepositItem({
            apy: apy,
            duration: duration,
            amount: _amount,
            timestamp: block.timestamp
        }));

        emit Deposit(msg.sender, _amount);
    }

    // Withdraw primary tokens from STAKING.
    function withdraw(uint256 _index) public nonReentrant {
        require(startedTimestamp > 0, "Not started yet");
        
        UserInfo storage user = userInfo[msg.sender];
        require(_index < user.depositItems.length, "Index out of bound");
        uint256 amount = user.depositItems[_index].amount;
        user.amount -= amount;
        totalStaked -= amount;

        uint256 dt;
        if (startedTimestamp > user.depositItems[_index].timestamp)
            dt = block.timestamp - startedTimestamp;
        else
            dt = block.timestamp - user.depositItems[_index].timestamp;
        
        if (dt < user.depositItems[_index].duration) {
            // Early withdraw
            uint256 total = rewardToken.balanceOf(address(this));
            amount -= amount * exitPenaltyPerc / 100;
            if (amount > total)
                amount = total;
            if (amount > 0) {
                stakingToken.safeTransfer(address(msg.sender), amount);
                emit EmergencyWithdraw(msg.sender, amount);
            }
        }
        else {
            // Normal Withdraw
            uint256 total = rewardToken.balanceOf(address(this));
            // Send Fee
            uint256 fee = amount * withdrawFee / 100;
            if (fee > total)
                fee = total;
            if (fee > 0)
                stakingToken.safeTransfer(feeAddress, fee);

            total -= fee;
            // Send Amount + Reward to user
            amount -= fee;
            amount += _calculateReward(msg.sender, _index);
            if (amount > total)
                amount = total;
            if (amount > 0) {
                stakingToken.safeTransfer(address(msg.sender), amount);
                emit Withdraw(msg.sender, amount);
            }
        }

        for (uint256 i = _index; i < user.depositItems.length - 1; i++)
            user.depositItems[i] = user.depositItems[i + 1];
        user.depositItems.pop();
    }

    // Withdraw reward. EMERGENCY ONLY. This allows the owner to migrate rewards to a new staking pool since we are not minting new tokens.
    function withdrawEmergencyReward(uint256 _amount) external onlyOwner {
        require(_amount <= rewardToken.balanceOf(address(this)) - totalStaked, 'not enough tokens to take out');
        rewardToken.safeTransfer(address(msg.sender), _amount);
    }

    function rewardsRemaining() public view returns (uint256) {
        uint256 reward = rewardToken.balanceOf(address(this));
        if (reward > totalStaked)
            reward -= totalStaked;
        else
            reward = 0;
        return reward;
    }

    function updateApy(uint256 newApy1, uint256 newApy2, uint256 newApy3) external onlyOwner {
        require(newApy1 <= 10000 && newApy2 <= 10000 && newApy3 <= 10000, "APY must be below 10000%");
        apy1 = newApy1;
        apy2 = newApy2;
        apy3 = newApy3;
    }

    function updateExitPenalty(uint256 newPenaltyPerc) external onlyOwner {
        require(newPenaltyPerc <= 20, "May not set higher than 20%");
        exitPenaltyPerc = newPenaltyPerc;
    }

    function updateFee(address newFeeAddress, uint256 newWithdrawFee) external onlyOwner {
        feeAddress = newFeeAddress;
        withdrawFee = newWithdrawFee;
    }

    function reset() external onlyOwner {
        uint256 balance = rewardToken.balanceOf(address(this));
        rewardToken.safeTransfer(address(msg.sender), balance);
        totalStaked = 0;
    }
}