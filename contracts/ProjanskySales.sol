pragma solidity ^0.5.3;
import "./openzeppelin/token/ERC721/ERC721Full.sol";

contract ProjanskySales {
    event Received(address indexed payer, uint tokenId, uint256 amount, uint256 balance);

    mapping (uint256 => uint256) public firstSalePrices; // tokenId -> price mapping
    mapping (uint256 => uint256) public tokenPrices; // tokenId -> price mapping
    mapping (uint256 => address payable) public tokenCreators;
    ERC721 public nftContract; // the non-fungible token contract
    uint public royaltyPercentage;

    constructor(address _nftAddress, uint _royaltyPercentage) public {
        nftContract = ERC721(_nftAddress);
        royaltyPercentage = _royaltyPercentage;

    }

    function purchase(uint256 _tokenId) public payable {
        require(msg.sender != address(0) && msg.sender != address(this));
        require(msg.value >= tokenPrices[_tokenId]);
        

        address payable tokenSeller =
          address(uint160(nftContract.ownerOf(_tokenId)));



         if (tokenCreators[_tokenId] !=tokenSeller) {
          if(msg.value>firstSalePrices[_tokenId]){//if sale price is greater than initial sale price
          uint amount = msg.value;
          uint royaltyFee = (msg.value-firstSalePrices[_tokenId])*(royaltyPercentage/100);
          amount = amount - royaltyFee;
          tokenCreators[_tokenId].transfer(royaltyFee);
          tokenSeller.transfer(amount);
            }
        }

        if (firstSalePrices[_tokenId]==0) {
          firstSalePrices[_tokenId] = msg.value;
          tokenCreators[_tokenId] =tokenSeller;
        }

        nftContract.safeTransferFrom(tokenSeller, msg.sender, _tokenId);
        tokenSeller.transfer(msg.value);
        emit Received(msg.sender, _tokenId, msg.value, address(this).balance);
    }

    function setTokenPrice(uint256 _tokenId, uint256 _price) public {
      require(_price > 0);
      address tokenOwner = nftContract.ownerOf(_tokenId);
      require(msg.sender == tokenOwner); // ensure only token owner can set
      tokenPrices[_tokenId] = _price;
    }
  }
