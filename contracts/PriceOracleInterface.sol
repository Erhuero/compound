pragma solidity ^0.8.6;
//SPDX-License-Identifier:UNLICENSED

interface PriceOracleInterface {
  function getUnderlyingPrice(address asset) external view returns(uint);
}