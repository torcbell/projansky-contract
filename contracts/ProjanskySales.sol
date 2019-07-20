pragma solidity ^0.5.3;

contract ProjanskySales {
    event Received(address indexed payer, uint tokenId, uint256 amount, uint256 balance);

    mapping (uint256 => uint256) public firstSalePrices; // tokenId -> price mapping
    mapping (uint256 => uint256) public tokenPrices; // tokenId -> price mapping
    ERC721 public nftContract; // the address of the non-fungible token contract
    uint public royaltyPercentage;

    constructor(uint _royaltyPercentage, address _nftAddress) public {
        royaltyPercentage = _royaltyPercentage;
        nftContract = ERC721(_nftAddress);
    }

    function purchase(uint256 _tokenId) public payable {
        require(msg.sender != address(0) && msg.sender != address(this));
        require(msg.value >= tokenPrices[_tokenId]);
        require(nftContract.exists(_tokenId));

        address tokenSeller = nftContract.ownerOf(_tokenId);
        /*
        if (tokenSeller != creator) {
          uint amount = msg.value;
          uint royaltyFee = (msg.value-initalPrice)*(royaltyPercentage/100);
          amount = amount - royaltyFee;
          creator.transfer(royaltyFee);
          currentOwner.transfer(amount);
          owner= msg.sender;
        }
        */
        /*
        if (!firstSalePrices[_tokenId]) {
          firstSalePrices[_tokenId] = msg.value
        }
        */
        nftContract.safeTransferFrom(tokenSeller, msg.sender, _tokenId);
        tokenSeller.transfer(msg.value);
        emit Received(msg.sender, _tokenId, msg.value, address(this).balance);
    }

    function setTokenPrice(uint256 _tokenId, uint256 _price) public {
      require(_currentPrice > 0);
      require(nftContract.exists(_tokenId));
      address tokenOwner = nftContract.ownerOf(_tokenId);
      require(msg.sender == tokenOwner); // ensure only token owner can set
      tokenPrices[_tokenId] = _price;
    }
  }
