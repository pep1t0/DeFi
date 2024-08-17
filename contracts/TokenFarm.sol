// Gestionara todas las acciones de los dos contratos relacionados
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./DanToken.sol";
import "./RewardToken.sol";

contract TokenFarm {

    string public name = "Reward Token Farm";
    address public owner;
    
    DanToken public danToken;
    RewardToken public rewardToken;
    uint public totalFarmEarned = 0; // Variable para almacenar el total de tokens que se han ganado por el token farm

    address[] public stakers;
    mapping(address => uint) public stakersAmounts; // Cuantos tokens tiene la persona haciendo staking
    mapping(address => bool) public hasStaked; // Si en algun momento ha hecho staking
    mapping(address => bool) public isStaking; // Si esta haciendo staking en este momento

    constructor(RewardToken _rewardToken, DanToken _danToken) {
        rewardToken = _rewardToken;
        danToken = _danToken;
        owner = msg.sender; // Almacena el owner del token farm en la variable owner
    }

    function stakeTokens(uint _amount) public {
        require(_amount > 0, "Amount must be greater than 0");
        danToken.transferFrom(msg.sender, address(this), _amount);
        stakersAmounts[msg.sender] += _amount;
        if(!hasStaked[msg.sender]) {
            stakers.push(msg.sender); // Almacena la persona en la lista stakers
        }
        isStaking[msg.sender] = true;
        hasStaked[msg.sender] = true; // Almacena que esta haciendo staking en la lista hasStaked
    }

    function unstakeTokens() public {
        require(isStaking[msg.sender], "You must be staking"); // Verifica que esta haciendo staking en la lista isStaking
        uint amountToUnstake = stakersAmounts[msg.sender]; // Almacena la cantidad que se va a deshacer staking en la variable amountToUnstake
        require(amountToUnstake > 0, "You don't have tokens staked");

        danToken.transfer(msg.sender, amountToUnstake); // Deshacer staking en el token farm
        stakersAmounts[msg.sender] = 0; // Almacena que se va a deshacer staking en la variable amountToUnstake
        isStaking[msg.sender] = false; // Almacena que ya no esta haciendo staking en la lista isStaking        
    }

    function issueTokens() public  {
        require(msg.sender == owner, "You're not the owner");
        for(uint i=0; i < stakers.length; i++) {
            address recipient = stakers[i];
            uint balance = stakersAmounts[recipient];
            if(balance > 0) {
                rewardToken.transfer(recipient, balance);
            }
        }
    }
}