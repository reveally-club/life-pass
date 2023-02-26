// SPDX-License-Identifier: MIT

pragma solidity >=0.8.17;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import "./PassToken.sol";

contract PassFactory is Ownable {
    address public adminAddress;

    event PassTokenCreated(address indexed tokenAddress);
    event UpdateAdmin(address indexed adminAddress);

    constructor(address _adminAddress) {
        require(
            _adminAddress != address(0),
            "Operations: Admin address cannot be zero"
        );
        adminAddress = _adminAddress;
    }

    modifier onlyAdmin() {
        require(msg.sender == adminAddress, "Management: Not admin");
        _;
    }

    function newPassToken(
        string memory _name,
        string memory _symbol,
        uint256 _maxSupply,
        uint256 _mintFee,
        address _adminAddress
    ) external onlyAdmin returns (address) {
        PassToken pass = new PassToken(
            _name,
            _symbol,
            _maxSupply,
            _mintFee,
            _adminAddress
        );
        emit PassTokenCreated(address(pass));
        return address(pass);
    }

    function updateAdmin(address _adminAddress) external onlyOwner {
        require(
            _adminAddress != address(0),
            "Operations: Admin address cannot be zero"
        );
        adminAddress = _adminAddress;
        emit UpdateAdmin(_adminAddress);
    }
}
