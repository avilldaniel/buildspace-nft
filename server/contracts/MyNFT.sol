// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import 'hardhat/console.sol';

// since we "npm installed" OpenZeppelin,
// we can import some of its contracts
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol';
import '@openzeppelin/contracts/utils/Counters.sol';

// import helper functions
import { Base64 } from './libraries/Base64.sol';

// MyNFT will inherit ERC721 contract's methods
contract MyNFT is ERC721URIStorage {
  // array of words
  string[] firstWords = ['one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten', 'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen'];
  string[] secondWords = ['feelin', "I'm", 'and', 'around', 'not', "you're", 'when', 'go', 'can', 'I', 'where', 'know', 'to', 'want', 'I'];
  string[] thirdWords = ['of', 'cup', 'a', 'make', "i'll", 'bed', 'to', 'go', "don't", 'long', 'too', 'for', 'awake', 'stay', "don't"];

  event NewNFTMinted(address sender, uint256 tokedId);

  string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

  // some OpenZeppelin magic to keep track of tokenIds
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;
  
  // pass NFT name, then NFT symbol
  constructor() ERC721 ("Kisses", "KSSs") {
    console.log('This is my NFT contract');
  }

  // function to randomly pick a word from each array
  function random(string memory input) internal pure returns (uint256) {
    return uint256(keccak256(abi.encodePacked(input)));
  }

  // function for random first word
  function pickRandomFirstWord(uint256 tokenId) public view returns (string memory) {
    // seed the "random" generator
    uint256 rand = random(string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId))));

    // modulus the # between 0 and length of array, to avoid going out of bounds
    rand = rand % firstWords.length;
    return firstWords[rand];
  }

  // function for random second word
  function pickRandomSecondWord(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId))));
    rand = rand % secondWords.length;
    return secondWords[rand];
  }

  // function for random third word
  function pickRandomThirdWord(uint256 tokenId) public view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId))));
    rand = rand % thirdWords.length;
    return thirdWords[rand];
  }

  // function so user can get their NFT
  function makeAnNFT() public {
    // verify _tokenIds.current (counter) <= 50
    require(_tokenIds.current() <= 50, "Maximum number of NFTs reached! (50)");

    // get current tokenId, which starts at 0
    uint256 newItemId = _tokenIds.current();

    // randomly get each word from our three arrays
    string memory first = pickRandomFirstWord(newItemId);
    string memory second = pickRandomSecondWord(newItemId);
    string memory third = pickRandomThirdWord(newItemId);
    string memory combinedWord = string(abi.encodePacked(first, second, third));

    // concatenate all three words together, then close with ending tags
    string memory finalSvg = string(abi.encodePacked(baseSvg, combinedWord, "</text></svg>"));

    // Get all the JSON metadata in place and base64 encode it.
    string memory json = Base64.encode(
        bytes(
            string(
                abi.encodePacked(
                    '{"name": "',
                    // We set the title of our NFT as the generated word.
                    combinedWord,
                    '", "description": "A highly acclaimed collection of squares.", "image": "data:image/svg+xml;base64,',
                    // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                    Base64.encode(bytes(finalSvg)),
                    '"}'
                )
            )
        )
    );

    // prepend data:application/json;base64, to our data
    string memory finalTokenUri = string(
      abi.encodePacked("data:application/json;base64,", json)
    );

    console.log("\n--------------------");
    // console.log(finalTokenUri);
    console.log(
      string(
          abi.encodePacked(
              "https://nftpreview.0xdev.codes/?code=",
              finalTokenUri
          )
      )
    );
    console.log("--------------------\n");

    // here is where we mint NFT to msg.sender
    _safeMint(msg.sender, newItemId);

    // set NFT's data
    // _setTokenURI(newItemId, 'data:application/json;base64,ewogICAgIm5hbWUiOiAiWW91QXJlSG93IiwKICAgICJkZXNjcmlwdGlvbiI6ICJib2R5IGFjaGVzIHdoZW4iLAogICAgImltYWdlIjogImRhdGE6aW1hZ2Uvc3ZnK3htbDtiYXNlNjQsUEhOMlp5QjRiV3h1Y3owaWFIUjBjRG92TDNkM2R5NTNNeTV2Y21jdk1qQXdNQzl6ZG1jaUlIQnlaWE5sY25abFFYTndaV04wVW1GMGFXODlJbmhOYVc1WlRXbHVJRzFsWlhRaUlIWnBaWGRDYjNnOUlqQWdNQ0F6TlRBZ016VXdJajRLSUNBZ0lEeHpkSGxzWlQ0dVltRnpaU0I3SUdacGJHdzZJR2R5WldWdU95Qm1iMjUwTFdaaGJXbHNlVG9nYzJWeWFXWTdJR1p2Ym5RdGMybDZaVG9nTVRWd2VEc2dmVHd2YzNSNWJHVStDaUFnSUNBOGNtVmpkQ0IzYVdSMGFEMGlNVEF3SlNJZ2FHVnBaMmgwUFNJeE1EQWxJaUJtYVd4c1BTSndhVzVySWlBdlBnb2dJQ0FnUEhSbGVIUWdlRDBpTlRBbElpQjVQU0kxTUNVaUlHTnNZWE56UFNKaVlYTmxJaUJrYjIxcGJtRnVkQzFpWVhObGJHbHVaVDBpYldsa1pHeGxJaUIwWlhoMExXRnVZMmh2Y2owaWJXbGtaR3hsSWo1WmIzVkJjbVZJYjNjOEwzUmxlSFErQ2p3dmMzWm5QZz09Igp9');
    _setTokenURI(newItemId, finalTokenUri);

    // increment tokenId for next mint of NFT
    _tokenIds.increment();

    console.log('An NFT w/ ID %s has been minted to %s', newItemId, msg.sender);

    emit NewNFTMinted(msg.sender, newItemId);
  }

  // function to get total number of NFTs minted so far
  function getTotalNfts() public view returns (uint256){
    console.log('So far total of', _tokenIds.current());
    return _tokenIds.current();
  }
}