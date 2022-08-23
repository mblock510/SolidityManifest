// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

interface IERC20 {
  
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}



interface IAccessControl {
  
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);
    function getRoleAdmin(bytes32 role) external view returns (bytes32);
    function grantRole(bytes32 role, address account) external;
    function revokeRole(bytes32 role, address account) external;
    function renounceRole(bytes32 role, address account) external;
}


library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {
 
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}


interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


abstract contract ERC165 is IERC165 {
   
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}


abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounce
Role(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}


library Address {
  
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
       
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

interface IPoolReward {
    function checkBalance(address _tokenReward) external view returns (uint256);
    function transferReward(address _tokenReward, address _to,  uint256 amount) external;
}


contract Stake is AccessControl, ReentrancyGuard{
    using SafeERC20 for IERC20;

    bytes32 public constant SUBADMIN_ROLE = keccak256("SUBADMIN_ROLE");
    bytes32 public constant ENTERSTAKER_ROLE = keccak256("ENTERSTAKER_ROLE");
    bytes32 public constant LEAVESTAKER_ROLE = keccak256("LEAVESTAKER_ROLE");
    bytes32 public constant CLAIMER_ROLE = keccak256("CLAIMER_ROLE");


    modifier onlyOwner{
        require(hasRole(SUBADMIN_ROLE, msg.sender), "must have admin role to transfer");
        _;
    }

    modifier onlyEnterStaker{
        require(hasRole(ENTERSTAKER_ROLE, address(this)), "current fonction is locked");
        _;
    }

    modifier onlyLeaveStaker{
        require(hasRole(LEAVESTAKER_ROLE, address(this)), "current fonction is locked");
        _;
    }

    modifier onlyClaimer{
        require(hasRole(CLAIMER_ROLE, address(this)), "current fonction is locked");
        _;
    }

    struct PoolInfo {
        bool      activate;
        IERC20    lpToken;            
        IERC20    tokenReward;        
        uint256   lastRewardBlock;    
        uint256   rewardPerBlock;     
        uint256   lpFee;             
        uint256   rewardFee;         
        uint256   supply;
        uint256   timeLock;
        uint256   accPerShare;
        uint256   bonus_multiplier;
        uint256   blockToClaim;
        uint256   stopBlock;
    }
    
    struct UserInfo {
        uint256   amount;     
        uint256   rewardDebt;  
        uint256   startBlock;
        uint256   lastClaim;
    }
    
    uint256 rewardsScaler = 1e12;
    PoolInfo[] public poolInfo;
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;

    address public burnAddress = 0x000000000000000000000000000000000000dEaD;
    address public devAddress;
    IPoolReward public poolReward;
    
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(
        address _poolRewardAddress,
        address _devAddress
    ) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(SUBADMIN_ROLE, msg.sender);
        _setupRole(ENTERSTAKER_ROLE, address(this));
        _setupRole(LEAVESTAKER_ROLE, address(this));
        _setupRole(CLAIMER_ROLE, address(this));
        poolReward = IPoolReward(_poolRewardAddress);
        devAddress = _devAddress;
    }

    function getMultiplier(uint256 _pid, uint256 _from, uint256 _to) public view returns (uint256) {
        PoolInfo memory pool = poolInfo[_pid];
        return (_to - _from) * pool.bonus_multiplier;
    }

    function add(
        bool      _activate,
        IERC20    _lpToken,           
        IERC20    _tokenReward,        
        uint256   _rewardPerBlock,    
        uint256   _lpFee,             
        uint256   _rewardFee,          
        uint256   _startBlock,
        uint256   _timeLock,
        uint256   _stopBlock,
        uint256   _bonus_multiplier,
        uint256   _blockToClaim

        ) public onlyOwner {
        uint256 _lastRewardBlock = block.number > _startBlock ? block.number : _startBlock;
        poolInfo.push(PoolInfo({
            activate:           _activate,
            lpToken:            _lpToken,
            tokenReward:        _tokenReward,
            lastRewardBlock:    _lastRewardBlock,
            rewardPerBlock:     _rewardPerBlock,
            lpFee:              _lpFee,
            rewardFee:          _rewardFee,
            supply:             0,
            timeLock:           _timeLock,
            stopBlock:          _stopBlock,
            accPerShare:        0,
            bonus_multiplier:   _bonus_multiplier,
            blockToClaim:       _blockToClaim     
        }));
    }

    function pendingRewards(uint256 _pid, address _user) public view returns (uint256) {
        PoolInfo memory pool = poolInfo[_pid];
        UserInfo memory user = userInfo[_pid][_user];
        uint256 lpSupply = pool.supply;
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier;
            if(block.number >= pool.stopBlock){
                multiplier = getMultiplier(_pid, pool.lastRewardBlock, pool.stopBlock);
            } else {
                multiplier = getMultiplier(_pid, pool.lastRewardBlock, block.number);
            }
            uint256 reward = multiplier * pool.rewardPerBlock;
            pool.accPerShare = pool.accPerShare + (reward * rewardsScaler / lpSupply);
        }
        uint256 pending = user.amount * pool.accPerShare / rewardsScaler - user.rewardDebt;
        
        uint256 pendingToClaim = pending;
        if (pending > 0){
            if(pool.rewardFee > 0){
                uint256 userFees = pending * pool.rewardFee / 10000;
                uint256 toClaim = pending - userFees;
                if (userFees > 0){
                    pendingToClaim = toClaim;
                }
            }
        }
        return pendingToClaim;
    }


    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; pid++) {
            updatePool(pid);
        }
    }

    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.supply;
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier;
        if(block.number >= pool.stopBlock){
            multiplier = getMultiplier(_pid, pool.lastRewardBlock, pool.stopBlock);
            pool.lastRewardBlock = pool.stopBlock;
        } else {
            multiplier = getMultiplier(_pid, pool.lastRewardBlock, block.number);
            pool.lastRewardBlock = block.number;
        }
        uint256 reward = multiplier * pool.rewardPerBlock;
        pool.accPerShare = pool.accPerShare + (reward * rewardsScaler / lpSupply);
    }

    function enterStaking(uint256 _pid, uint256 _amount) public onlyEnterStaker nonReentrant{
        require(_amount > 0, "enterStaking: amount must be positif.");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_msgSender()];
        require(pool.activate, "enterStaking: pool is not currently available.");
        require(block.number < pool.stopBlock, "enterStaking: pool rewards are closed.");
        updatePool(_pid);
        if(user.amount > 0 && pendingRewards(_pid, _msgSender()) > 0) claimRewardsInternal(_pid);
        uint256 previousAmount = pool.lpToken.balanceOf(address(this));
        pool.lpToken.safeTransferFrom(address(_msgSender()), address(this), _amount);
        require(pool.lpToken.balanceOf(address(this))>= previousAmount + _amount, "enterStaking: transfer lp token error.");
        pool.supply = pool.supply + _amount;
        user.startBlock = user.amount == 0 ? block.number : user.startBlock;
        user.amount += _amount;
        user.rewardDebt = user.amount * pool.accPerShare / rewardsScaler;
        emit Deposit(_msgSender(), _pid, _amount);
    }

    function claimRewards(uint256 _pid) public onlyClaimer nonReentrant{
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_msgSender()];
        require(address(poolReward) != address(0), "claimRewards: please set pool reward");
        updatePool(_pid);
        require(user.lastClaim == 0 || block.number > user.lastClaim + pool.blockToClaim, "claimRewards: please wait to claim.");
        uint256 pending = user.amount * pool.accPerShare / rewardsScaler - user.rewardDebt;
        require(pending > 0, "claimRewards: nothing to claim");
        require(poolReward.checkBalance(address(pool.tokenReward)) > pending, "claimRewards: not enougth found in the pool."); 

        if(pool.rewardFee > 0){
            uint256 feeReward = pending * pool.rewardFee / 10000;
            uint256 feeRewardDev = feeReward / 5;
            uint256 feeRewardBurn = feeReward - feeRewardDev;
            uint256 RewardToMint = pending - feeReward;
            if (feeReward > 0 && feeRewardDev > 0 && feeRewardBurn > 0){
                poolReward.transferReward(address(pool.tokenReward), burnAddress, feeRewardBurn);
                poolReward.transferReward(address(pool.tokenReward), devAddress, feeRewardDev);
                poolReward.transferReward(address(pool.tokenReward), _msgSender(), RewardToMint);
            } else {
                poolReward.transferReward(address(pool.tokenReward), _msgSender(), pending);
            }
        }else {
            poolReward.transferReward(address(pool.tokenReward), _msgSender(), pending);
        }
        user.rewardDebt = user.amount * pool.accPerShare / rewardsScaler;
        user.lastClaim = block.number;
    }


    function claimRewardsInternal(uint256 _pid) internal {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_msgSender()];
        require(address(poolReward) != address(0), "claimRewards: please set pool reward.");
        require(user.lastClaim == 0 || block.number > user.lastClaim + pool.blockToClaim, "claimRewards: please wait to claim.");
        uint256 pending = user.amount * pool.accPerShare / rewardsScaler - user.rewardDebt;
        if(pending > 0){
            if(poolReward.checkBalance(address(pool.tokenReward)) > pending){
                if(pool.rewardFee > 0){
                    uint256 feeReward = pending * pool.rewardFee / 10000;
                    uint256 feeRewardDev = feeReward / 5;
                    uint256 feeRewardBurn = feeReward - feeRewardDev;
                    uint256 RewardToMint = pending - feeReward;
                    if (feeReward > 0 && feeRewardDev > 0 && feeRewardBurn > 0){
                        poolReward.transferReward(address(pool.tokenReward), burnAddress, feeRewardBurn);
                        poolReward.transferReward(address(pool.tokenReward), devAddress, feeRewardDev);
                        poolReward.transferReward(address(pool.tokenReward), _msgSender(), RewardToMint);
                    } else {
                        poolReward.transferReward(address(pool.tokenReward), _msgSender(), pending);
                    }
                } else {
                    poolReward.transferReward(address(pool.tokenReward), _msgSender(), pending);
                }
                user.rewardDebt = user.amount * pool.accPerShare / rewardsScaler;
                user.lastClaim = block.number;
            }
        }
    }
        

    function leaveStaking(uint256 _pid) public onlyLeaveStaker nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_msgSender()];
        require(user.amount > 0, "leaveStaking: no user amount");
        uint256 blockLimit = user.startBlock + pool.timeLock > pool.stopBlock ? pool.stopBlock : user.startBlock + pool.timeLock;
        require(block.number >= blockLimit , "leaveStaking: not yet time to withdraw");
        updatePool(_pid);
        if(pendingRewards(_pid, _msgSender()) > 0) claimRewardsInternal(_pid);
        uint256 amountToWithdraw = user.amount;
        if(pool.lpFee > 0) {
            uint256 lpToStakeForever = user.amount * pool.lpFee * rewardsScaler / 10000;
            uint256 lpToMint = user.amount - lpToStakeForever / rewardsScaler;
            if(lpToMint > 0 && lpToStakeForever > 0) amountToWithdraw = lpToMint;
        }
        uint256 previousAmount = pool.lpToken.balanceOf(address(this));
        pool.lpToken.safeTransfer(_msgSender(), amountToWithdraw);
        require(pool.lpToken.balanceOf(address(this)) <= previousAmount - amountToWithdraw, "leaveStaking: withdraw error");
        user.amount = 0;
        pool.supply = pool.supply - amountToWithdraw;
        user.rewardDebt = user.amount * pool.accPerShare / rewardsScaler;
        emit Withdraw(_msgSender(), _pid, amountToWithdraw);
    }
    

    function getData(uint256 _pid, address _user) external view returns( uint256[] memory ){
            uint256 length = poolInfo.length;
            require(length > 0 && _pid <= length - 1, "getData: pid not exist.");
            PoolInfo storage pool = poolInfo[_pid];
            UserInfo storage user = userInfo[_pid][_user];
            uint256[] memory data = new uint256[](19);
            data[0]  =  user.amount;                     //  user staked amount
            data[1]  =  pendingRewards(_pid, _user);     //  user reward pending by pool
            data[2]  =  user.rewardDebt;                 //  user reward debt
            data[3]  =  user.startBlock;                 //  user start block (reset each re-enter staking)
            data[4]  =  user.startBlock + pool.timeLock; //  block from user will be able lo leave staking pool
            data[5]  =  block.number;                    //  current block number
            data[6]  =  user.lastClaim;                  //  last block number user was claim rewards 
            data[7]  =  pool.lastRewardBlock;            //  last rewards block of a pool
            data[8]  =  pool.rewardPerBlock;             //  reward per block for each pool
            data[9]  =  pool.lpFee;                      //  lp token fees set for each pool (will be apply at leaveStaking): 1000 = 10% 
            data[10] =  pool.rewardFee;                  //  reward fees set for each pool (will be apply at claimReward): 1000 = 10%         
            data[11] =  pool.supply;                     //  lp supply for each pool
            data[12] =  pool.timeLock;                   //  timelock: user could leave staking from user startblock + timelock
            data[13] =  pool.accPerShare;                //  rewards allowed by lp share
            data[14] =  pool.bonus_multiplier;           //  pool bonus multiplier
            data[15] =  pool.blockToClaim;               //  pool blocks between 2 claims
            data[16] =  pool.stopBlock;                  //  pool block of pool end reward
            data[17] =  !pool.activate ? 0 : 1;          //  pool state: inactive = 0, active = 1
            data[18] =  length;                          //  list pools length

        return data;
    }

    function getPoolLength() external view returns(uint256){
        return uint256(poolInfo.length);
    }
    
    function getCurrentBlock() public view returns(uint256){
        return block.number;
    }
    
    function setAddressPoolReward(address _newPoolRewardAddress) external onlyOwner {
        poolReward = IPoolReward(_newPoolRewardAddress);
    }
    
    function setBlockToClaim(uint256 _pid, uint256 _newBlockToClaim) external onlyOwner {
        PoolInfo storage pool = poolInfo[_pid];
        pool.blockToClaim = _newBlockToClaim;
    }

    function updateMultiplier(uint256 _pid, uint256 _bonus_multiplier) external onlyOwner {
        PoolInfo storage pool = poolInfo[_pid];
        pool.bonus_multiplier = _bonus_multiplier;
    }

    function setPoolTimeLock(uint256 _pid, uint256 _newTimeLock) external onlyOwner {
        PoolInfo storage pool = poolInfo[_pid];
        pool.timeLock = _newTimeLock;
    }

    function setPoolLpToken(uint256 _pid, IERC20 _newLpToken) external onlyOwner {
        PoolInfo storage pool = poolInfo[_pid];
        pool.lpToken = _newLpToken;
    }

    function setPoolTokenReward(uint256 _pid, IERC20 _newTokenReward) external onlyOwner {
        PoolInfo storage pool = poolInfo[_pid];
        pool.tokenReward = _newTokenReward;
    }

    function setRewardPerBlock(uint256 _pid, uint256 _newRewardPerBlock) external onlyOwner {
        PoolInfo storage pool = poolInfo[_pid];
        pool.rewardPerBlock = _newRewardPerBlock;
    }

     function setPoolStopBlock(uint256 _pid, uint256 _newStopBlock) external onlyOwner {
        PoolInfo storage pool = poolInfo[_pid];
        pool.stopBlock = _newStopBlock;
    }

    function setPoolLpFee(uint256 _pid, uint256 _lpFee) external onlyOwner {
        require(_lpFee <= 2000, "lp fees can't be greater than 20%");
        PoolInfo storage pool = poolInfo[_pid];
        pool.lpFee = _lpFee;
    }
    
    function setRewardFee(uint256 _pid, uint256 _rewardFee) external onlyOwner {
        require(_rewardFee <= 2000, "reward fees can't be greater than 20%");
        PoolInfo storage pool = poolInfo[_pid];
        pool.rewardFee = _rewardFee;
    }

    function setPoolActivate(uint256 _pid, bool _isActivate) external onlyOwner {
        PoolInfo storage pool = poolInfo[_pid];
        pool.activate = _isActivate;
    }

    function setDevAddress(address _devAddress) external onlyOwner {
        devAddress = _devAddress;
    }

    function setRewardScaller(uint256 _rewardsScaler) external onlyOwner {
        rewardsScaler = _rewardsScaler;
    }
}