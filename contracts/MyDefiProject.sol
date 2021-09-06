pragma solidity ^0.8.6;
//SPDX-License-Identifier:UNLICENSED

//interact with compound
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import './CTokenInterface.sol';
import './ComptrollerInterface.sol';
import './PriceOracleInterface.sol';

contract MyDefiProject {

    ComptrollerInterface public comptroller;
    PriceOracleInterface public priceOracle;

    constructor(
        //hardcoding here because is more flexible for testnets
        address _comptroller,
        address _priceOracle
    ){//instanciate our price controller and variable
        comptroller = ComptrollerInterface(_comptroller);
        priceOracle = PriceOracleInterface(_priceOracle);
    }

    //cToken which we want to lend and the amount of underlying DAI
    function supply(address cTokenAddress, uint underlyingAmount) external {
        //pointer to the CToken and the address on parameters
        CTokenInterface cToken = CTokenInterface(cTokenAddress);
        address underlyingAddress = cToken.underlying();
        IERC20(underlyingAddress).approve(cTokenAddress, underlyingAmount);
        //call mint function on the CToken contract, this is the lending
        //the token will be send from our contract to their contract
        uint result = cToken.mint(underlyingAmount);
        require(//message error in case of if mint is failed
            result == 0,
            'cToken#mint() failed. see Compound ErrorReporter.sol for more details'
        );
    }
    //once you have the Ctoken you want to redeem it against the underlying token
    //that you initially lend + the interest
    function redeem(address cTokenAddress, uint cTokenAmount) external {
        CTokenInterface cToken = CTokenInterface(cTokenAddress);
        uint result = cToken.redeem(cTokenAmount);
         require(//message error in case of if mint is failed
            result == 0,
            'cToken#redeem() failed. see Compound ErrorReporter.sol for more details'
        );
    }
//borrowing part
//first to borrow once you have lend some tokens to compound, you need to indicate to compound which 
//of this tokens you use as collaterals
function enterMarket(address cTokenAddress) external {
    //array of cToken addresses that we want to use as collateral
    //we can pass an array of cToken addresses
     address[] memory markets = new address[](1);
     //first entry of the market
     markets[0] = cTokenAddress;
     //give to us an array of results
     uint[] memory results = comptroller.enterMarkets(markets);
     require(
        results[0] == 0,
        'comptroller#enterMarket() failed. see Compound ErrorReporter.sol for more details'
        );
    }

    //when we are enter to the markets, we are ready to borrow some tokens
    function borrow(address cTokenAddress, uint borrowAmount) external {
        //pointer to get addrss of the underlyings
        CTokenInterface cToken = CTokenInterface(cTokenAddress);
        //call the borrow function
        uint result = cToken.borrow(borrowAmount);
        require(
            result == 0,
            'cToken#borrow() failed. see Compound ErrorReporter.sol for more details'
        );
    }

    //repay our loan, no concept of loan duration in compound
    //specify underlying amount we want to repay
    function repayBorrow(address cTokenAddress, uint underlyingAmount) external {
        CTokenInterface cToken = CTokenInterface(cTokenAddress);
        //call the borrow function
        address underlyingAddress = cToken.underlying();
        //approve the underlying to be spent by the cToken address
        IERC20(underlyingAddress).approve(cTokenAddress, underlyingAmount);
        uint result = cToken.repayBorrow(underlyingAmount);
        require(
            result == 0,
            'cToken#repayBorrow() failed. see Compound ErrorReporter.sol for more details'
        );
    }

    //what is the maximum amount you can borrow from the asset
    //cTokenAdress: we want to borrow the underlying asset of the cToken
    function getMaxBorrow(address cTokenAddress) external view returns(uint) {
        //what is the amount of money in dollars we shortffall or how much money we are short off
        (uint result, uint liquidity, uint shortfall) = comptroller
            .getAccountLiquidity(address(this));
        require(
            result == 0,
            'comptroller#getAccountLiquidity() failed. see Compound ErrorReporter.sol for more details'
        );
        require(shortfall == 0, 'account underwater');
        require(liquidity > 0, 'account does not have collateral');
        //get the price of the underlying token
        uint underlyingPrice = priceOracle.getUnderlyingPrice(cTokenAddress);
        //if the liquidity is 1000 we can borrow 1000$
        //if the underlying price is 100, means the price of the token is 100$ ,
        //we can borrow 10 of this token
        return liquidity / underlyingPrice;
    }



}