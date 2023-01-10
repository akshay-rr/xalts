// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12 <0.9.0;

import "./XaltsToken.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract XaltsSaleContract {

    uint256 public rate;
    XaltsToken public tokenContract;
    address payable beneficiary;

    constructor (uint256 _rate, XaltsToken _tokenContract, address _beneficiary) {
        rate = _rate;
        tokenContract = _tokenContract;
        beneficiary = payable(_beneficiary);
    }

    function buyToken(uint256 amount) public payable returns (bool) {
        require(msg.value >= SafeMath.mul(amount, rate), "Insufficient Funds Provided");
        require(tokenContract.transfer(msg.sender, amount), "Token Transfer Failed");
        return true;
    }

    function withdraw() public payable {
        require(msg.sender == beneficiary, "Not an approved beneficiary");
        beneficiary.transfer(address(this).balance);
    }

    receive() external payable {
        if (msg.value > 0) {
            uint256 amount = SafeMath.div(msg.value, rate);
            buyToken(amount);
        }
    }

}