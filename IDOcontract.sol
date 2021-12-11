pragma solidity ^0.8.4;
// SPDX-License-Identifier: Unlicensed
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
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
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract Ownable is Context { // Basic access contract module
	address private _owner;
	address private _previousOwner;
	uint private _lockTime;
	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	constructor (){
		//address msgSender = _msgSender();
		_owner = 0xb8D23FcF7a399898aE9D7a070025CBc774a39b4C; //Token Creator Address Renouncement will not be required due to nature of the project
		emit OwnershipTransferred(address(0),0xb8D23FcF7a399898aE9D7a070025CBc774a39b4C); //Token Creator Address Renouncement will not be required due to nature of the project
	}

	function owner() public view returns (address){
		return _owner;
	}

	modifier onlyOwner(){
		require(_owner == _msgSender(),"Caller is not the owner");  //Only callable by original owner
		_;
	}

	function renounceOwnership() public virtual onlyOwner{
		emit OwnershipTransferred(_owner, address(0));

		_owner = address(0);
	}

	function transferOwnership(address newOwner) public virtual onlyOwner{
		require(newOwner != address(0),"Ownable: new owner is the zero address");
		emit OwnershipTransferred(_owner,newOwner);
		_owner = newOwner;
	}
}


contract MCFido is Ownable,ReentrancyGuard{
    IERC20 factoryAddress = IERC20("FactoryAddress");
    uint256 TokenPrice; //How many tokens per base token e.g 1 BNB = n amount of tokens
    uint256 _phase;
    uint256 SOFTCAP;
    uint256 HARDCAP;
    uint256 minimumContribution = 1*10**16;
    bool isActive = false; // sets initial flag to false
    uint256 tokenPrice; // measured in tokenUnits, 
    IERC20 tokenAddress;
    uint8 tokenDecimals;
    address idoAdmin;
    uint256 paidSpots;
    uint256 GweiCollected=0; //Gwei or jager for ETH/BNB
    uint256 maxAmount;
    bool marketOn=false;
    mapping (address => BuyersData) Buyers;
    //depends on the decimals, e.g if token has 18 decimals the calculation can be done directly 
    struct BuyersData{
        uint256 contribution;
        uint256 owedTokens;
        
    }
    constructor(IERC20 _tokenAddress,address payable _idoAdmin, 
    uint256 _paidSpots,uint256 _maxAmount,
    uint256 _tokenDecimals,uint256 _softcap,uint256 _hardcap) public{
    tokenAddress = _tokenAddress;
    tokenDecimals = _tokenDecimals;
    idoAdmin = _idoAdmin;
    paidSpots = _paidSpots;
    maxAmount = _maxAmount;
    
     
    }


function setAmountToSell(uint256 _amount) public onlyOwner{
    require(_amount >0,"Amount needs to be bigger than 0");

}
function cancelSale()public onlyOwner{
    //changes phase, enable base token withdraw
}
function _UserDepositPhaseOne() public payable nonReentrant{
    //require(_phase == 1 && tokenAddress.balanceOf(msg.sender)>minimumHoldings, "This function is only callable in phase 1");//only holders are able to participate in phase 1 
    //require(msg.value < maximumPurchase&& msg.value > minimumContribution,"One of the following parameters is incorrect:MinimumAmount/MaxAmount");
    BuyersData storage _contributionInfo = Buyers[msg.sender];
     uint256 amount_in = msg.value;
     uint256 tokensSold = amount_in * tokenPrice  / (10 ** 18);
     _contributionInfo.contribution = msg.value;
     _contributionInfo.owedTokens += tokensSold;
     GweiCollected += amount_in;
}
    /*
  function _returnContributors() public view returns(uint256){
      return contributionNumber;
  }
  */

function _remainingContractTokens() public view returns(uint256){
    return tokenAddress.balanceOf(address(this));
}

function _returnPhase () public view returns (uint256){
    return _phase;
}

function _startMarket() public onlyOwner{
    /*
    Approve balance required from this contract to pcs liquidity factory
    
    finishes ido status
    creates liquidity in pcs
    forwards funds to project creator
    forwards mcf fee to mcf wallet
    locks liquidity
    */

}
//Contract shouldnt accept bnb/eth/etc thru fallback functions, pending implementation if its the opposite
 receive() external payable{
        //NA
    }

function _lockLiquidity() internal{
/*liquidity Forwarder
pairs reserved amount and bnb to create liquidity pool
*/
}

function withdrawTokens() public{
    uint256 currentTokenBalance = tokenAddress.balanceOf(address(this));
    BuyersData storage buyer = Buyers[msg.sender];
    require(_phase == 3 && marketOn==true,"not ready to claim");
    uint256 tokensOwed = buyer.owedTokens;
    require(tokensOwed>0 && currentTokenBalance>0,"No tokens to be transfered or contract empty");
    tokenAddress.transfer(msg.sender,tokensOwed*10**tokenDecimals);
    buyer.owedTokens=0;
}
}