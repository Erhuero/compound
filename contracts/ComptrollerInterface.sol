pragma solidity ^0.8.6;
//SPDX-License-Identifier:UNLICENSED

interface ComptrollerInterface {
  function enterMarkets(address[] calldata cTokens) external returns (uint[] memory);
  function getAccountLiquidity(address owner) external view returns(uint, uint, uint);
}