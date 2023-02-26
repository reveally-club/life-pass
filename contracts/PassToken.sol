// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract PassToken is ERC721Enumerable, Ownable {
    using Strings for uint256;
    address public adminAddress;

    uint256 public immutable maxSupply;
    uint256 public immutable mintFee;

    string public baseURI;

    SaleStatus public currentStatus;

    enum SaleStatus {
        Pending,
        Open,
        Close
    }

    event Mint(address indexed to, uint256 tokenId);
    event SetBaseURI(string uri);
    event UpdateAdmin(address indexed adminAddress);
    event SaleStatusUpdate(SaleStatus newStatus);
    event WithdrawFungibleToken(address indexed token, uint256 tokenId);

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _maxSupply,
        uint256 _mintFee,
        address _adminAddress
    ) ERC721(_name, _symbol) {
        maxSupply = _maxSupply;
        mintFee = _mintFee;
        adminAddress = _adminAddress;
    }

    modifier onlyAdmin() {
        require(msg.sender == adminAddress, "Management: Not admin");
        _;
    }

    function mint(address _to, uint256 _tokenId) public payable {
        require(currentStatus == SaleStatus.Open, "Status: Must be in Open");
        require(totalSupply() < maxSupply, "Nft: Total supply reached");

        require(msg.value == mintFee, "Nft: Need to pay the price");
        payable(address(this)).transfer(msg.value);

        _safeMint(_to, _tokenId);

        emit Mint(_to, _tokenId);
    }

    function setBaseURI(string memory _uri) external onlyAdmin {
        baseURI = _uri;

        emit SetBaseURI(_uri);
    }

    function tokenURI(
        uint256 _tokenId
    ) public view override returns (string memory) {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        return
            bytes(baseURI).length > 0
                ? string(
                    abi.encodePacked(baseURI, _tokenId.toString(), ".json")
                )
                : "";
    }

    function updateAdmin(address _adminAddress) external onlyAdmin {
        require(
            _adminAddress != address(0),
            "Operations: Admin address cannot be zero"
        );

        adminAddress = _adminAddress;

        emit UpdateAdmin(_adminAddress);
    }

    function updateSaleStatus(SaleStatus _status) external onlyAdmin {
        currentStatus = _status;

        emit SaleStatusUpdate(_status);
    }

    function withdrawFungibleToken(address _token) external onlyAdmin {
        uint256 amount = IERC20(_token).balanceOf(address(this));
        require(amount != 0, "Operations: No token amount");

        payable(address(msg.sender)).transfer(amount);

        emit WithdrawFungibleToken(_token, amount);
    }
}
