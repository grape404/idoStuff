// SPDX-License-Identifier: Unlicensed
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

pragma solidity ^0.8.0;

contract MCFido is Ownable, ReentrancyGuard {
    IERC20 tokenAddress;
    IUniswapV2Router02 routerAddress;

    address public idoAdmin;
    address public lpTokenReceiver;

    // TODO: suggestion TokenPrice as it's similar to tokenPrice
    uint256 public TokenPrice; //How many tokens per base token e.g 1 BNB = n amount of tokens
    uint256 public _phase;
    uint256 public SOFTCAP;
    uint256 public HARDCAP;
    uint256 public minimumContribution = 1e16;
    uint256 public tokenPrice; // measured in tokenUnits,
    uint256 public paidSpots;
    uint256 public GweiCollected = 0; //Gwei or jager for ETH/BNB
    uint256 public maxAmount;
    uint256 public tokenDecimals;

    bool public isActive; // sets initial flag to false
    bool public marketOn;

    mapping(address => BuyersData) public Buyers;

    //depends on the decimals, e.g if token has 18 decimals the calculation can be done directly
    struct BuyersData {
        uint256 contribution;
        uint256 owedTokens;
    }

    constructor(
        IERC20 _tokenAddress,
        IUniswapV2Router02 _routerAddress,
        address payable _idoAdmin,
        address _lpTokenReceiver,
        uint256 _paidSpots,
        uint256 _maxAmount,
        uint256 _tokenDecimals,
        uint256 _softcap,
        uint256 _hardcap
    ) public {
        routerAddress = _routerAddress;
        lpTokenReceiver = _lpTokenReceiver;
        tokenAddress = _tokenAddress;
        tokenDecimals = _tokenDecimals;
        idoAdmin = _idoAdmin;
        paidSpots = _paidSpots;
        maxAmount = _maxAmount;
        SOFTCAP = _softcap;
        HARDCAP = _hardcap;
    }

    function setAmountToSell(uint256 _amount) public onlyOwner {
        require(_amount > 0, "Amount needs to be bigger than 0");
    }

    function cancelSale() public onlyOwner {
        //changes phase, enable base token withdraw
    }

    function _UserDepositPhaseOne() public payable nonReentrant {
        //require(_phase == 1 && tokenAddress.balanceOf(msg.sender)>minimumHoldings, "This function is only callable in phase 1");//only holders are able to participate in phase 1
        //require(msg.value < maximumPurchase&& msg.value > minimumContribution,"One of the following parameters is incorrect:MinimumAmount/MaxAmount");
        BuyersData storage _contributionInfo = Buyers[msg.sender];
        uint256 amount_in = msg.value;
        uint256 tokensSold = (amount_in * tokenPrice) / (10**18);
        _contributionInfo.contribution = msg.value;
        _contributionInfo.owedTokens += tokensSold;
        GweiCollected += amount_in;
    }

    /*
  function _returnContributors() public view returns(uint256){
      return contributionNumber;
  }
  */

    function _remainingContractTokens() public view returns (uint256) {
        return tokenAddress.balanceOf(address(this));
    }

    function _returnPhase() public view returns (uint256) {
        return _phase;
    }

    function _startMarket() public onlyOwner {
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
    receive() external payable {
        //NA
    }

    function _lockLiquidity() internal {
        /*liquidity Forwarder
pairs reserved amount and bnb to create liquidity pool
*/
    }

    function withdrawTokens() public {
        uint256 currentTokenBalance = tokenAddress.balanceOf(address(this));
        BuyersData storage buyer = Buyers[msg.sender];
        require(_phase == 3 && marketOn == true, "not ready to claim");
        uint256 tokensOwed = buyer.owedTokens;
        require(
            tokensOwed > 0 && currentTokenBalance > 0,
            "No tokens to be transfered or contract empty"
        );
        tokenAddress.transfer(msg.sender, tokensOwed * 10**tokenDecimals);
        buyer.owedTokens = 0;
    }

    function addLiquidity() public onlyOwner {
        uint256 amountOfBNB = address(this).balance;
        uint256 amountOFTokens = tokenAddress.balanceOf(address(this));

        IERC20(tokenAddress).approve(address(routerAddress), amountOFTokens);

        (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        ) = IUniswapV2Router02(routerAddress).addLiquidityETH{
                value: amountOfBNB
            }(
                address(tokenAddress),
                amountOFTokens,
                0,
                0,
                lpTokenReceiver,
                block.timestamp + 1200
            );
    }
}
