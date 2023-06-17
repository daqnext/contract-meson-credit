// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MesonCreditV1 is Initializable, ERC20Upgradeable, OwnableUpgradeable {

    // For Burn & Mint Equilibrium
    struct BMEPair {
        address ContractAddress;
        string Symbol;
        uint256 Multiplier;
        bool DivisionFlag; // do the division if it is setted as true
        bool Pause;
    } 

    uint256 public pairsIndex;
    mapping(uint256 => BMEPair) public pairs;
    mapping(string => uint256) public pairsSymbol2Index; // may have the risk to have same symbol name

    event BMEMint(address indexed _from, uint256 _amount, uint256 _pairIndex, string _symbol, address _contractAddress, uint256 _multiplier, bool _divisionFlag);


    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() initializer public {
        __ERC20_init("Meson Credit", "MC");
        __Ownable_init();
    }

    // Burn & Mint Equilibrium
    function BME(uint256 pairIndex, uint256 amount) public {
        BMEPair memory p = pairs[pairIndex];
        require(p.ContractAddress != address(0), "Has not set the pair address");
        require(p.Pause == false, "Pair has been paused");

        bool tx1 = IERC20(p.ContractAddress).transferFrom(msg.sender, address(this), amount);
        require(tx1 == true, "Failed to transfer token");

        // since Solidity 0.8, the overflow/underflow check is implemented on the language level - it adds the validation to the bytecode during compilation.
        // You don't need the SafeMath library for Solidity 0.8+. You're still free to use it in this version, it will just perform the same validation twice (one on the language level and one in the library).
        if (p.DivisionFlag== true) {
            amount /= p.Multiplier;
        } else {
            amount *= p.Multiplier;
        }

        _mint(msg.sender, amount);
        emit BMEMint(msg.sender, amount, pairIndex, p.Symbol, p.ContractAddress, p.Multiplier, p.DivisionFlag);
    }

    function createBMEPair(address contractAddress, string memory symbol, uint256 multiplier, bool divisionFlag) public onlyOwner() {
        BMEPair memory newone = BMEPair(contractAddress, symbol, multiplier, divisionFlag, false);
        pairsIndex += 1;
        pairs[pairsIndex] = newone;
        pairsSymbol2Index[symbol] = pairsIndex;
    }

    function updateBMEPair(uint256 pairIndex, address contractAddress, string memory symbol, uint256 multiplier, bool divisionFlag, bool pause) public onlyOwner() {
        BMEPair memory p = pairs[pairIndex];
        require(p.ContractAddress != address(0), "Has not set the pair address");

        BMEPair memory newone = BMEPair(contractAddress, symbol, multiplier, divisionFlag, pause);
        pairs[pairIndex] = newone;
        pairsSymbol2Index[symbol] = pairsIndex;
    }

    function claim(uint256 pairIndex, uint256 amount, address to) public onlyOwner() {
        BMEPair memory p = pairs[pairIndex];
        require(p.ContractAddress != address(0), "Has not set the pair address");

        IERC20(p.ContractAddress).transfer(to, amount);
    }
}
