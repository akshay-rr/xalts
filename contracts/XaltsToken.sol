// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetFixedSupply.sol";

contract XaltsToken is ERC20PresetFixedSupply, Ownable {

    address tokenContractOwner;

    mapping(address => bool) whiteList;

    mapping(address => mapping(address => bool)) associated;

    mapping(address => address[]) associates;

    constructor (
        string memory _name,
        string memory _symbol,
        uint256 _initialSupply,
        address _owner,
        address[] memory _whiteList
    ) ERC20PresetFixedSupply (_name, _symbol, _initialSupply, _owner) Ownable () {

        for(uint i=0; i < _whiteList.length; i++) {
            whiteList[_whiteList[i]] = true;
        }

        tokenContractOwner = _owner;

    }

    function whiteListAddress(address _whiteListedAddress) public virtual onlyOwner {
        whiteList[_whiteListedAddress] = true;

        address[] memory associatedAddresses = associates[_whiteListedAddress];

        for(uint i = 0; i < associatedAddresses.length; i++) {
            whiteList[associatedAddresses[i]] = true;
        }
    }

    function blackListAddress(address _whiteListedAddress) public virtual onlyOwner {
        whiteList[_whiteListedAddress] = false;

        address[] memory associatedAddresses = associates[_whiteListedAddress];

        for(uint i = 0; i < associatedAddresses.length; i++) {
            whiteList[associatedAddresses[i]] = false;
        }
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        require(whiteList[to], "Recepient is not approved");
        require(whiteList[msg.sender], "You are not approved");
        
        _transfer(msg.sender, to, amount);

        if(!addressesAreAssociated(msg.sender, to)) {
            associated[msg.sender][to] = true;
            associated[to][msg.sender] = true;
            associates[msg.sender].push(to);
            associates[to].push(msg.sender);
        }

        return true;
    }

    function addressesAreAssociated(address a, address b) internal view returns (bool) {
        return associated[a][b] || associated[b][a];
    }

}