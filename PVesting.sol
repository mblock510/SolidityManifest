// SPDX-License-Identifier: MIT
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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}




interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}


interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


contract PresaleVesting is Ownable {

    bool paused = false;
    IERC20 public token;
    uint256 public stageAmount = 50000000 ether;
    uint256 public rate = 650; 
    address public WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; // WBNB
    address public stableCoin = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; //BUSD

    IPancakeRouter02 public router;

    struct UserTx {
        bool wBNBDeposit;
        uint256 depositTimestamp;
        uint256 depositAmount;
        uint256 totalAmountAllowed;
        uint256 amountReceived;
        uint256[] totalAmountSplitted;
    }

    mapping(address => UserTx[]) public userTxList;

    uint256[] public timestamps = [
                                    13 weeks,  // 3 months   
                                    26 weeks, // 6 months    
                                    39 weeks, // 9 months      
                                    52 weeks, // 12 months
                                    65 weeks  // 15 months   
                                ]; 

     uint256[] public distributionPct = [
                                            10, // 10%
                                            15, // 15%
                                            20, // 20%
                                            25  // 25%
                                        ];

    event Deposit(address recipient, uint256 tokenAmount, uint256 pid, uint256 timestamp);
    event Withdraw(address recipient, uint256 tokenAmount, uint256 pid, uint256 timestamp);

    constructor(IERC20 _token){
        token = _token;
        router = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    }

    function deposit(address[] memory _addressesList, uint256[] memory _amountsList, bool[] memory _isBNB) external onlyOwner returns(bool){
        require(!paused, "depositPresale: contract isn't available currently.");
        require(_addressesList.length > 0, "depositPresale: addresses list should not be empty.");
        require(_addressesList.length == _amountsList.length && _amountsList.length == _isBNB.length, "depositPresale: addresses list length should be equal to amount list length.");
        uint256 totalTokenAmount;
        for(uint256 i = 0; i < _amountsList.length; i++){
            require(_amountsList[i] > 0, "depositPresale: amount should not be equal to zero.");
            require(_addressesList[i] != address(0), "depositPresale: address should not be address zero.");
            uint256 tokenAmount;
            if(_isBNB[i]){
                tokenAmount = getRate(_amountsList[i]);
                totalTokenAmount += tokenAmount;
            } else {
                tokenAmount = getBUSDRate(_amountsList[i]);
                totalTokenAmount += tokenAmount;
            }
            uint256[] memory split = splitCalculation(tokenAmount);
            UserTx memory userTx = UserTx({
                wBNBDeposit: _isBNB[i],
                depositTimestamp: block.timestamp,
                depositAmount: _amountsList[i],
                totalAmountAllowed: tokenAmount,
                amountReceived: 0,
                totalAmountSplitted: split
            });
            userTxList[_addressesList[i]].push(userTx);
            emit Deposit(_addressesList[i], tokenAmount, getUserTxLength(_addressesList[i]) - 1, block.timestamp);
        }
        require(stageAmount >= totalTokenAmount, "deposit: not enough amount available for presale.");
        stageAmount -= totalTokenAmount;
        return true;
    }

    function getRate(uint256 _ethAmount) public view returns(uint256){
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = stableCoin;
        uint256 amountOut = router.getAmountsOut(_ethAmount, path)[1];
        return uint256(uint256(amountOut * 10000) / rate);
    }

    function getSplit(address _user, uint256 _pid) public view returns(uint256[] memory) {
        UserTx memory userTx = userTxList[_user][_pid];
        return userTx.totalAmountSplitted;
    }

    function splitCalculation(uint256 tokenAmount) public view returns(uint256[] memory) {
        uint256[] memory split = new uint256[](5);
        split[0] = uint256(uint256(tokenAmount * distributionPct[0]) / 100);
        split[1] = uint256(uint256(tokenAmount * distributionPct[1]) / 100);
        split[2] = uint256(uint256(tokenAmount * distributionPct[2]) / 100);
        split[3] = uint256(uint256(tokenAmount * distributionPct[3]) / 100);
        split[4] = tokenAmount - (split[0] + split[1] + split[2] + split[3]);
        return split;
    }

    function userInfos(address _user, uint256 _pid) public view returns(UserTx memory) {
        return userTxList[_user][_pid];
    }
    
    function getUserTxLength(address _user) public view  returns(uint256){
        return userTxList[_user].length;
    }
    
    function withdraw(uint256 _pid) external returns(bool){
        require(getUserTxLength(_msgSender()) > _pid , "withdraw: no user transaction at this index.");
        UserTx storage userTx = userTxList[_msgSender()][_pid];
        uint256 availableAmount = getPending( _msgSender(), _pid);
        require(availableAmount > 0, "withdraw: nothing to withdraw.");
        require(token.balanceOf(address(this)) >= availableAmount, "withdraw: contract token balance isn't well provided.");
        token.transfer(_msgSender(), availableAmount);
        userTx.amountReceived += availableAmount;
        emit Withdraw(_msgSender(), availableAmount, _pid, block.timestamp);
        return true;
    }
    
    function getPending(address _user, uint256 _pid) public view returns(uint256){
        UserTx memory userTx = userTxList[_user][_pid];
        uint256 pending;
        for(uint256 i = 0; i < userTx.totalAmountSplitted.length; i++){
            if(block.timestamp >= userTx.depositTimestamp + timestamps[i]){
                pending += userTx.totalAmountSplitted[i];
            }
        }
        return pending - userTx.amountReceived;
    }

    function getBUSDRate(uint256 _busdAmount) public view returns(uint256){
        return uint256(uint256(_busdAmount * 10000) / rate);
    }

    function getAllUserPending(address _user) public view returns(uint256){
       uint256 allPendings;
       for(uint256 i = 0; i < getUserTxLength(_user); i++){
           allPendings += getPending(_user, i);
       }
       return allPendings;
    }
    
    function setToken(address _token) external onlyOwner {
        token = IERC20(_token);
    }


    function setWBNB(address _WBNB) public onlyOwner {
        WBNB = _WBNB;
    }

    function setStableCoin(address _stableCoin) external onlyOwner {
        stableCoin = _stableCoin;
    }

    function setRouter(address _router) external onlyOwner {
        router = IPancakeRouter02(_router);
        setWBNB(router.WETH());
    }

    function setPaused(bool _paused) external onlyOwner {
        paused = _paused;
    }

    function addStageAmount(uint256 _stageAmount) external onlyOwner {
        stageAmount += _stageAmount;
    }  
    
    function reduceStageAmount(uint256 _stageAmount) external onlyOwner {
        stageAmount -= _stageAmount;
    }

    function setTimestamps(uint256[] memory _timestamps) external onlyOwner {
        require(_timestamps.length == timestamps.length, "setTimestamps: wrong timpstamps array length.");
        timestamps = _timestamps;
    }

    function setDistributionPct(uint256[] memory _distributionPct) external onlyOwner {
        require(distributionPct.length == distributionPct.length, "setTimestamps: wrong distributionPct array length.");
        distributionPct = _distributionPct;
    }

    function BNBWithdraw(uint256 _ethAmount, bool _withdrawAll) external onlyOwner returns(bool){
        uint256 ethBalance = address(this).balance;
        uint256 ethAmount;
        if(_withdrawAll){
            ethAmount = ethBalance;
        } else {
            ethAmount = _ethAmount;
        }
        require(ethAmount <= ethBalance, "withdraw: eth balance must be larger than amount.");
        (bool success,) = payable(_msgSender()).call{value: ethAmount}(new bytes(0));
        require(success, "withdraw: transfer error.");
        return true;
    }

    function ERC20Withdraw(address _tokenAddress, uint256 _tokenAmount, bool _withdrawAll) external onlyOwner returns(bool){
        IERC20 anyToken = IERC20(_tokenAddress);
        uint256 tokenBalance = anyToken.balanceOf(address(this));
        uint256 tokenAmount;
        if(_withdrawAll){
            tokenAmount = tokenBalance;
        } else {
            tokenAmount = _tokenAmount;
        }
        require(_tokenAmount <= tokenBalance, "ERC20withdraw: token balance must be larger than amount.");
        require(_tokenAmount > 0, "ERC20withdraw: token should be positif.");
        token.transfer(_msgSender(), tokenAmount);
        return true;
    }
    
    receive() external payable {}
}