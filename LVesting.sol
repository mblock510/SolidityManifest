// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  
    constructor() {
        _transferOwnership(_msgSender());
    }

  
    function owner() public view virtual returns (address) {
        return _owner;
    }
   
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
   
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
  
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}



interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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


contract LVesting is Ownable, ReentrancyGuard {

    struct UserData {
        uint256 totalAmount;
        uint256 userDebt;
        uint256 splits;
        uint256 start;
        uint256 timelock;
    }

    mapping(address=> UserData[] ) public userData;

    IERC20 public lToken;

    function setUserData(address _user, uint256 _amount, uint256 _splits, uint256 _timelock) external onlyOwner returns(bool) {
        bool isSet = setUserDataPrivate(_user, _amount, _splits, _timelock);
        require(isSet, "user set error.");
        return isSet;
    }

    function resetUserData(
        address _user, 
        uint256 _index,
        uint256 _amount, 
        uint256 _dept, 
        uint256 _splits, 
        uint256 _start, 
        uint256 _timelock
    ) external onlyOwner returns(bool) {
        require(_index < getUserLength(_user), "wrong index.");
        UserData storage user = userData[_user][_index];
        user.totalAmount = _amount;
        user.userDebt = _dept;
        user.splits = _splits;
        user.start = _start;
        user.timelock = _timelock;
        return true;
    }

    function setUserDataBatch(
        address[] memory _users, 
        uint256[] memory _amounts, 
        uint256[] memory _splitsList,
        uint256[] memory _lockList
    ) external onlyOwner returns(bool) {

        require(_users.length > 0, "length equal 0.");
        require(
            _users.length == _amounts.length && 
            _amounts.length == _splitsList.length && 
            _splitsList.length == _lockList.length,
             "length mismatch."
        );

        bool[] memory allsets = new bool[](_users.length);

        for(uint256 i = 0; i < _users.length; i++){
            allsets[i] = setUserDataPrivate(_users[i], _amounts[i], _splitsList[i], _lockList[i]);
        }

        bool isSet = !boolContains(allsets, false);
        require(isSet, "users set error.");
        return isSet;
    }

    function userWithdraw(uint256 _index) external returns(bool) {
        bool isWithdraw = userWithdrawPrivate(_msgSender(), _index);
        require(isWithdraw, "withdraw error.");
        return isWithdraw;
    }

    function userWithdrawOwner(address _user, uint256 _index) external onlyOwner returns(bool) {
        bool isWithdraw = userWithdrawPrivate(_user, _index);
        require(isWithdraw, "withdraw error.");
        return isWithdraw;
    }

    function setLToken(IERC20 _lToken) external onlyOwner {
        lToken = _lToken;
    }

    function ERC20Withdraw(address _tokenAddress, uint256 _tokenAmount, bool _withdrawAll) external onlyOwner returns(bool) {
        IERC20 token = IERC20(_tokenAddress);
        uint256 tokenBalance = token.balanceOf(address(this));
        uint256 tokenAmount;
        if(_withdrawAll){
            tokenAmount = tokenBalance;
        } else {
            tokenAmount = _tokenAmount;
        }
        require(tokenAmount <= tokenBalance, "token balance must be larger.");
        require(tokenAmount > 0, "token amount should be positif.");
        token.transfer(_msgSender(), tokenAmount);
        return true;
    }
    
    function getUserLength(address _user) public view returns(uint256){
        return userData[_user].length;
    }

    function getPendingAmount(address _user, uint256 _index) public view returns(uint256){
        require(_index < getUserLength(_user), "wrong index.");
        UserData memory user = userData[_user][_index];
        uint256 split = uint256(user.timelock / user.splits);
        uint256 pendingAmount;
        for(uint256 i = 0; i < user.splits; i++){
            if(block.timestamp >= uint256(uint256((i+1) * split) + user.start)){
                if(i + 1 < user.splits) {
                    pendingAmount += uint256(user.totalAmount / user.splits);
                } else {
                    pendingAmount += uint256(user.totalAmount - pendingAmount);
                }
            } 
        }
        return pendingAmount - user.userDebt;
    }

    function boolContains(bool[] memory boolList, bool value) public pure returns(bool){
        bool isIn;
        for(uint256 i = 0; i < boolList.length; i++){
            if(boolList[i] == value){
                isIn = true;
                break;
            }
        }
        return isIn;
    }

    function setUserDataPrivate(address _user, uint256 _amount, uint256 _splits, uint256 _timelock) private returns(bool) {
        UserData memory user;
        user.totalAmount = _amount;
        user.splits = _splits;
        user.start = block.timestamp;
        user.timelock = _timelock;
        userData[_user].push(user);
        return true;
    }

    function userWithdrawPrivate(address _user, uint256 _index) private returns(bool) {
        require(_index < getUserLength(_user), "wrong index.");
        require(address(lToken) != address(0), "lToken unset.");
        uint256 amountAvailable = getPendingAmount(_user, _index);
        require(amountAvailable > 0, "nothing to withdraw.");
        require(amountAvailable <= lToken.balanceOf(address(this)), "not enough fund.");
        UserData storage user = userData[_user][_index];
        user.userDebt += amountAvailable;
        lToken.transfer(_user, amountAvailable);
        return true;
    }
}
