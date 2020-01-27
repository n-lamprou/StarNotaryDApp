pragma solidity >=0.4.24;

//Importing openzeppelin-solidity ERC-721 implemented Standard
import "../node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";

// StarNotary Contract declaration inheritance the ERC721 openzeppelin implementation
contract StarNotary is ERC721 {

    // Star data
    struct Star {
        string name;
    }

    // Token name
    string public name = 'CryptoStars';
    // Token symbol
    string public symbol = 'STR';

    // mapping the Star with the Owner Address
    mapping(uint256 => Star) public tokenIdToStarInfo;
    // mapping the TokenId and price
    mapping(uint256 => uint256) public starsForSale;


    // Create Star using the Struct
    function createStar(string memory _name, uint256 _tokenId) public { // Passing the name and tokenId as a parameters
        Star memory newStar = Star(_name); // Create new Star object
        tokenIdToStarInfo[_tokenId] = newStar; // Creating in memory the Star -> tokenId mapping
        _mint(msg.sender, _tokenId); // _mint assign the the star with _tokenId to the sender address (ownership)
    }

    // Putting an Star for sale (Adding the star tokenid into the mapping starsForSale, first verify that the sender is the owner)
    function putStarUpForSale(uint256 _tokenId, uint256 _price) public {
        require(ownerOf(_tokenId) == msg.sender, "You can't sale the Star you don't own");
        starsForSale[_tokenId] = _price;
    }


    // Function that allows you to convert an address into a payable address
    function _make_payable(address x) internal pure returns (address payable) {
        return address(uint160(x));
    }

    function buyStar(uint256 _tokenId) public  payable {
        require(starsForSale[_tokenId] > 0, "The Star should be up for sale");
        uint256 starCost = starsForSale[_tokenId];
        address ownerAddress = ownerOf(_tokenId);
        require(msg.value > starCost, "You need to have enough Ether");
        _transferFrom(ownerAddress, msg.sender, _tokenId);
        // Convert to payable to be able to use transfer() function to transfer ether
        address payable ownerAddressPayable = _make_payable(ownerAddress);
        ownerAddressPayable.transfer(starCost);
        if(msg.value > starCost) {
            msg.sender.transfer(msg.value - starCost);
        }
    }

    // Look-Up Token Id To Star Info
    function lookUptokenIdToStarInfo (uint _tokenId) public view returns (string memory) {
        //Return the Star saved in tokenIdToStarInfo mapping
        Star memory desiredStar = tokenIdToStarInfo[_tokenId];
        string memory starName = desiredStar.name;
        return starName;
    }

    // Exchange Stars function
    function exchangeStars(uint256 _tokenId1, uint256 _tokenId2) public {
        //Check if the owner of _tokenId1 or _tokenId2 is the sender
        require((ownerOf(_tokenId1) == msg.sender) || (ownerOf(_tokenId2) == msg.sender), "You need to own one of the Stars exchanged");
        //Get the owner of the two tokens (no need to check for price)
        address ownerToken1 = ownerOf(_tokenId1);
        address ownerToken2 = ownerOf(_tokenId2);
        //Exchange token ownership.
        _transferFrom(ownerToken1, ownerToken2, _tokenId1);
        _transferFrom(ownerToken2, ownerToken1, _tokenId2);
    }

    // Transfer Stars
    function transferStar(address _to1, uint256 _tokenId) public {
        //Check if the sender is the owner of Star
        require(ownerOf(_tokenId) == msg.sender, "You can't transfer a Star you don't own");
        //Transfer the Star
        _transferFrom(msg.sender, _to1, _tokenId);
    }

}