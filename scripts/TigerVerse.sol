//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract TigerVerse is ERC721Enumerable, Ownable {
    using SafeMath for uint256;
    using Strings for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdTracker;

    bool isAllow;
    uint256 public constant MAX_SUPPLY = 3900;
    uint256 public PRICE = 0.001 ether;
    uint256 public constant MAX_PER_MINT = 10;

    string public baseTokenURI;

    constructor(string memory baseURI) ERC721("TigerVerse", "TGVS") {
        setBaseURI(baseURI);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function reserveNFTs(uint256 _amount) public onlyOwner {
        uint256 totalMinted = _tokenIdTracker.current();
        require(totalMinted.add(_amount) < MAX_SUPPLY, "Not enough NFTs");
        for (uint256 i = 0; i < _amount; i++) {
            _mintSingleNFT();
        }
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, tokenId.toString(), ".json"))
                : "";
    }

    function setIsAllow(bool _isAllow) public onlyOwner {
        isAllow = _isAllow;
    }

    function setBaseURI(string memory _baseTokenURI) public onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

    function mintNFTs(uint256 _count) public payable {
        uint256 totalMinted = _tokenIdTracker.current();
        require(totalMinted.add(_count) <= MAX_SUPPLY, "Not enough NFTs!");
        require(
            _count > 0 && _count <= MAX_PER_MINT,
            "Cannot mint specified number of NFTs."
        );
        require(
            msg.value >= PRICE.mul(_count),
            "Not enough ether to purchase NFTs."
        );

        for (uint256 i = 0; i < _count; i++) {
            _mintSingleNFT();
        }
    }

    function _mintSingleNFT() private {
        _tokenIdTracker.increment();
        uint256 newTokenID = _tokenIdTracker.current();
        _safeMint(msg.sender, newTokenID);
    }

    function tokensOfOwner(address _owner)
        external
        view
        returns (uint256[] memory)
    {
        uint256 tokenCount = balanceOf(_owner);
        uint256[] memory tokensId = new uint256[](tokenCount);
        for (uint256 i = 0; i < tokenCount; i++) {
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        }

        return tokensId;
    }

    function withdraw() public payable onlyOwner {
        require(
            isAllow == true,
            "Withdraw is not allowed since 39 nfts are sold out."
        );
        uint256 balance = address(this).balance;
        require(balance > 0, "No ether left to withdraw");
        (bool success, ) = (msg.sender).call{value: balance}("");
        require(success, "Transfer failed.");
    }

    function transferNFT(uint256 tokenId, address to) public {
        safeTransferFrom(msg.sender, to, tokenId);
    }

    function updatePrice(uint256 _newPrice) public onlyOwner {
        PRICE = _newPrice;
    }
}
