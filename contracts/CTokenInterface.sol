pragma solidity ^0.8.6;
//SPDX-License-Identifier:UNLICENSED

interface CTokenInterface {
  function mint(uint mintAmount) external returns (uint);
  function redeem(uint redeemTokens) external returns (uint);
  function redeemUnderlying(uint redeemAmount) external returns (uint);
  function borrow(uint borrowAmount) external returns (uint);
  function repayBorrow(uint repayAmount) external returns (uint);
  function underlying() external view returns(address);
}