// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./IWallet.sol";
import "./AccessControl.sol";

contract AccessControlWallet is AccessControl {
    using SafeMath for uint256;

    IWallet _walletInterface;

   
    //  Contract constructor instantiates wallet interface and sets msg.sender to admin
  
    constructor(IWallet wallet_, address[] memory _owners) AccessControl(_owners){
        _walletInterface = IWallet(wallet_);
        admin = msg.sender;
    }

    
      //Blockchain get functions
     

    function getOwners() external view returns (address[] memory) {
        return owners;
    }

    function getAdmin() external view returns (address) {
        return admin;
    }
}
