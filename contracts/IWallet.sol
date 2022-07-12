// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

interface IWallet {
    //
    //  Allows admin to add new owner to the wallet
    //   owner Address of the new owner
    //  */
    function addOwner(address owner) external;

    //  Allows admin to remove owner from the wallet
    //  owner Address of the new owner
   
    function removeOwner(address owner) external;


    //  Allows admin to transfer owner from one wallet to  another
    //  _from Address of the old owner
    //  _to Address of the new owner

    function transferOwner(address _from, address _to) external;

   
    //  Allows an owner to confirm a transaction.
    //  transactionId Transaction ID.

    function confirmTransaction(uint256 transactionId) external;


    //  allows anyone to execute a confirmed transaction.
    //  transactionId Transaction ID.

    function executeTransaction(uint256 transactionId) external;


    //  Allows an owner to revoke a confirmation for a transaction.
    //  transactionId Transaction ID.

    function revokeTransaction(uint256 transactionId) external;
}
