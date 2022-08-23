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
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}


interface IdUSDT is IERC20 {
    function mint(address _receiver, uint256 _amount) external;
    function burn(address _address, uint256 _amount) external;
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



interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}

interface INFT {
    function evolveExternal(address _receiver, uint256 _rarity, uint256 _batch) external returns(bool);
    function mintExternal(address _receiver, uint256 _amount) external returns(bool);
    function amountToUpgrade() external view returns(uint256);
}


contract ContractSwap is Ownable, ReentrancyGuard {

    event Swap(address sender, uint256 burnedDGO, uint256 mintedDUSDT, uint256 timestamp);
    
    event Evolved(
        address receiver, 
        uint256 burnedId, 
        uint256 amountBurned, 
        uint256 mintedId, 
        uint256 _amountMinted, 
        uint256 _timestamp
    );

    event NFTMint(
        address receiver, 
        uint256 nftAmount, 
        uint256 amountBurned, 
        uint256 _timestamp
    );


    modifier check{
        require(address(USDT) != address(0), "check: USDT is not set yet in contract.");
        require(address(dUSDT) != address(0), "check: dUSDT is not set yet in contract.");
        require(address(DGO) != address(0), "check: DGO is not set yet in contract.");
        require(address(router) != address(0), "check: router is not set yet in contract.");
        require(
            IPancakeFactory(router.factory()).getPair(address(USDT), address(DGO)) != address(0), 
            "check: pair USDT-DGO is not set yet."
        );
        _;
    }

    struct UserData {
        uint256 totalDepositUSDT;
        uint256 totalBurnedDGO;
        uint256 totaldUSDTBurned;
        uint256 nftMinted;
        uint256 nftBurned;
        uint256 bundleEvolved;
    }

    IdUSDT public dUSDT;
    IERC20 public USDT;
    IERC20 public DGO;
    IPancakeRouter02 router;
    INFT NFT;

    mapping(address => UserData) public userData;
    mapping(IERC20 => bool) public isTokenAllowed;
    mapping(IERC20 => bool) isTokenInSwap;

    address constant public  deadWallet = 0x000000000000000000000000000000000000dEaD;
    address public devWallet;
    uint256 public pct;
    uint256 public nftPrice = 200 ether;

    function swap(IERC20 _token, uint256 _amount) external check returns(bool){
        require(isTokenAllowed[_token], "swap: token is not allowed.");
        require(_amount > 0, "swap: amount must be positive.");
        require(!isTokenInSwap[_token], "swap: token in swap currently, please try later.");
        UserData storage user = userData[_msgSender()];
        uint256[] memory data = new uint256[](8);
        isTokenInSwap[_token] = true;
        data[0] = _token.balanceOf(address(this)); // previous token balance
        _token.transferFrom(_msgSender(), address(this), _amount);
        data[1] = _token.balanceOf(address(this)); // new token balance
        isTokenInSwap[_token] = false;
        data[3] = data[1] - data[0]; // difference balance
        user.totalDepositUSDT += data[3];
        require(data[3] >= _amount, "swap: token amount received is not enough.");
        if(address(_token) != address(USDT)){
            data[4] = privateSwap(
                address(_token), 
                address(USDT), 
                data[3],
                address(this)
            ); // swap amount from token to usdt
        } else {
            data[4] = data[3]; // usdt amount equal deposite amount
        }

        data[5] = privateSwap(
            address(USDT), 
            address(DGO), 
            data[4],
            address(this)
        ); // swap amount from USDT to DGO

        data[6] = data[5] - uint256(uint256(data[5] * pct) / 10000); // DGO amount to burn minus pct
        data[7] = data[5] - data[6]; // DGO amount to send to devWallet

        if(data[6] > 0) DGO.transfer(deadWallet, data[6]);
        if(data[7] > 0 && devWallet != address(0)) DGO.transfer(devWallet, data[7]);

        user.totalBurnedDGO += data[6];
        dUSDT.mint(_msgSender(), data[4]);
        emit Swap(_msgSender(), data[6], data[4], block.timestamp);
        return true;
    }

    function privateSwap(
        address tokenA, 
        address tokenB, 
        uint256 amount,
        address to
    ) private returns(uint256){
        require(isTokenAllowed[IERC20(tokenA)], "privateSwap: token is not allowed.");
        require(amount > 0, "privateSwap: amount must be positive.");
        // require(!isTokenInSwap[IERC20(tokenA)], "privateSwap: token in swap currently, please try later.");
        require(!isTokenInSwap[IERC20(tokenB)], "privateSwap: token in swap currently, please try later.");
        require(
            IPancakeFactory(router.factory()).getPair(tokenA, tokenB) != address(0), 
            "privateSwap: pair is not set."
        );
        isTokenInSwap[IERC20(tokenA)] = true;
        isTokenInSwap[IERC20(tokenB)] = true;
        IERC20(tokenA).approve(address(router), amount);
        uint256[] memory data = new uint256[](4);
        address[] memory path = new address[](2);
        path[0] = tokenA;
        path[1] = tokenB;
        data[0] = router.getAmountsOut(amount, path)[1]; 
        data[1] = IERC20(tokenB).balanceOf(to);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            data[0],
            path,
            to,
            block.timestamp
        );
        
        data[2] = IERC20(tokenB).balanceOf(to);
        data[3] = data[2] - data[1];
        require(data[3] >= data[0], "privateSwap: tokenB amount received is not enough.");
        isTokenInSwap[IERC20(tokenA)] = false;
        isTokenInSwap[IERC20(tokenB)] = false;
        return data[3];
    }

    function ERC20Withdraw(address _tokenAddress, uint256 _tokenAmount, bool _withdrawAll) external onlyOwner returns(bool) {
        IERC20 token = IERC20(_tokenAddress);
        require(!isTokenInSwap[token], "ERC20Withdraw: token is in swap currently, please try later.");
        isTokenInSwap[token] = true;
        uint256 tokenBalance = token.balanceOf(address(this));
        uint256 tokenAmount;
        if(_withdrawAll){
            tokenAmount = tokenBalance;
        } else {
            tokenAmount = _tokenAmount;
        }
        require(tokenAmount > 0, "ERC20withdraw: token amount should be positif.");
        require(tokenAmount <= tokenBalance, "ERC20withdraw: token balance must be larger than amount.");
        token.transfer(_msgSender(), tokenAmount);
        isTokenInSwap[token] = false;
        return true;
    }

    function mintNft(uint256 _amount) external returns(bool){
        require(_amount > 0, "mintNft: amount of nft must be positif.");
        require(address(dUSDT) != address(0), "mintNft: dUSDT is not set yet in contract.");
        require(address(NFT) != address(0), "mintNft: NFT is not set yet in contract.");
        UserData storage user = userData[_msgSender()];
        uint256 amountExpected = getPriceForNftAmount(_amount);
        uint256 prevTokenBalance = dUSDT.balanceOf(_msgSender());
        dUSDT.burn(_msgSender(), amountExpected);
        uint256 newTokenBalance = dUSDT.balanceOf(_msgSender());
        isTokenInSwap[IERC20(address(dUSDT))] = false;
        uint256 diff = prevTokenBalance - newTokenBalance;
        require(diff >= amountExpected, "mintNft: dUSDT burn error");
        bool isMinted = NFT.mintExternal(_msgSender(), _amount);
        require(isMinted, "mintNft: nft mint error.");
        user.nftMinted += _amount;
        user.totaldUSDTBurned += amountExpected;

        emit NFTMint(
            _msgSender(),
            _amount, 
            amountExpected, 
            block.timestamp
        );

        return true;
    }

    function evolveNft(uint256 _rarity, uint256 _batch) external returns(bool){
        require(_batch > 0, "evolveNft: batch must be positif.");
        require(address(NFT) != address(0), "evolveNft: NFT is not set yet in contract.");
        UserData storage user = userData[_msgSender()];
        uint256 amountToBurn = _batch * amountToUpgrade();
        bool isEvolved = NFT.evolveExternal(_msgSender(), _rarity, _batch);
        require(isEvolved, "evolveNft: nft evolution error.");
        user.bundleEvolved += _batch;
        user.nftBurned += amountToBurn;

        emit Evolved(
            _msgSender(), 
            _rarity, 
            amountToBurn, 
            _rarity + 1, 
            _batch, 
            block.timestamp
        );
        return true;
    }

    function setDUSDT(IdUSDT _dUSDT) external onlyOwner {
        dUSDT = _dUSDT;
    }

    function setUSDT(IERC20 _USDT) external onlyOwner {
        USDT = _USDT;
    }

    function setDGO(IERC20 _DGO) external onlyOwner {
        DGO = _DGO;
    }

    function setRouter(IPancakeRouter02 _router) external onlyOwner {
        router = _router;
    }

    function setAllowedToken(IERC20 _token, bool _isAllowed) external onlyOwner {
        isTokenAllowed[_token] = _isAllowed;
    }

    function setPct(uint256 _pct) external onlyOwner {
        pct = _pct;
    } 
    
    function setDevWallet(address _devWallet) external onlyOwner {
        devWallet = _devWallet;
    }

    function setNFT(INFT _NFT) external onlyOwner {
        NFT = _NFT;
    }

    function setNftPrice(uint256 _nftPrice) external onlyOwner {
        nftPrice = _nftPrice;
    }

    function amountToUpgrade() public view returns(uint256){
        require(
            address(NFT) != address(0), 
            "amountToUpgrade: NFT is not set yet in contract."
        );
        return NFT.amountToUpgrade();
    }

    function getPriceForNftAmount(uint256 nftAmount) public view returns(uint256){
        return nftPrice * nftAmount;
    }
}