// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./IWallet.sol";
import "./AccessControl.sol";

contract MultiSigWallet is AccessControl {
    using SafeMath for uint256;
    
    // For Storage
     
    struct Transaction {
        bool executed;
        address destination;
        uint256 value;
        bytes data;
    }

    // track transaction ID and keep a mapping of the same
    uint256 public transactionCount;
    mapping(uint256 => Transaction) public transactions;
    Transaction[] public _validTransactions;

    // track transactions ID to which owner addresses have confirmed
    mapping(uint256 => mapping(address => bool)) public confirmations;

    
     // Fallback function allows to deposit ether.
     
    fallback() external payable {
        if (msg.value > 0) {
            emit Deposit(msg.sender, msg.value);
        }
    }

    receive() external payable {
        if (msg.value > 0) {
            emit Deposit(msg.sender, msg.value);
        }
    }

    
    //Modifiers
     
    modifier isOwnerMod(address owner) {
        require(
            isOwner[owner] == true,
            "You are not authorized for this action."
        );
        _;
    }

    modifier isConfirmedMod(uint256 transactionId, address owner) {
        require(
            confirmations[transactionId][owner] == false,
            "You have already confirmed this transaction."
        );
        _;
    }

    modifier isExecutedMod(uint256 transactionId) {
        require(
            transactions[transactionId].executed == false,
            "This transaction has already been executed."
        );
        _;
    }


    //    Contract constructor sets initial owners
    //   _owners List of initial owners.

    constructor(address[] memory _owners) AccessControl(_owners) {}

    
    //Public Functions
    
    //  Allows an owner to submit and confirm a transaction.
    //  destination Transaction target address.
    //  value Transaction ether value.
    //  data Transaction data payload.
    //  return transactionId Transaction ID.

    function submitTransaction(
        address destination,
        uint256 value,
        bytes memory data
    ) public isOwnerMod(msg.sender) returns (uint256 transactionId) {
        // assign ID to count
        transactionId = transactionCount;

        // update transactions mapping with the transaction struct
        transactions[transactionId] = Transaction({
            destination: destination,
            value: value,
            data: data,
            executed: false
        });

        // update new count
        transactionCount += 1;

        // emit event
        emit Submission(transactionId);

        // transactionId = addTransaction(destination, value, data);
        confirmTransaction(transactionId);
    }

   
    // Allows an owner to confirm a transaction.
    // transactionId Transaction ID.
  
    function confirmTransaction(uint256 transactionId)
        public
        isOwnerMod(msg.sender)
        isConfirmedMod(transactionId, msg.sender)
        notNull(transactions[transactionId].destination)
    {
        // update confirmation
        confirmations[transactionId][msg.sender] = true;
        emit Confirmation(msg.sender, transactionId);

        // on confirmation, execute transaction
        executeTransaction(transactionId);
    }

    
    //  Allows anyone to execute a confirmed transaction.
    //  transactionId Transaction ID.

    function executeTransaction(uint256 transactionId)
        public
        isOwnerMod(msg.sender)
        isExecutedMod(transactionId)
    {
        uint256 count = 0;
        bool quorumReached;

        // iterate over the array of owners
        for (uint256 i = 0; i < owners.length; i++) {
            // if owner has confirmed the transaction
            if (confirmations[transactionId][owners[i]]) count += 1;
            // if count reached the quorum specification then return true
            if (count >= quorum) quorumReached = true;
        }

        if (quorumReached) {
            // extrapolate struct to a variable
            Transaction storage txn = transactions[transactionId];
            // update variable executed state
            txn.executed = true;

            // transfer the value to the destination address, and get boolean of success/fail
            (bool success, ) = txn.destination.call{value: txn.value}(txn.data);

            if (success) {
                _validTransactions.push(txn);
                emit Execution(transactionId);
            } else {
                emit ExecutionFailure(transactionId);
                txn.executed = false;
            }
        }
    }

    // 
    // Allows an owner to revoke a confirmation for a transaction.
    // transactionId Transaction ID.
    // 
    function revokeTransaction(uint256 transactionId)
        external
        isOwnerMod(msg.sender)
        isConfirmedMod(transactionId, msg.sender)
        isExecutedMod(transactionId)
        notNull(transactions[transactionId].destination)
    {
        confirmations[transactionId][msg.sender] = false;
        emit Revocation(msg.sender, transactionId);
    }

    
     //Blockchain get functions
     
    function getOwners() external view returns (address[] memory) {
        return owners;
    }

    function getValidTransactions()
        external
        view
        returns (Transaction[] memory)
    {
        return _validTransactions;
    }

    function getQuorum() external view returns (uint256) {
        return quorum;
    }
}

//contract address(multisig): 0x4BD958aB67Ab75347317B02f1C3fd70019BF9312
//contract address(accesscontrolwallet): 0x193aBE8e2DB41B1a36476A1a8A3f4D859adA955d