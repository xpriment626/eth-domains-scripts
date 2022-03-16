// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import { StringUtils } from "./libraries/StringUtils.sol";
import { Base64 } from "./libraries/Base64.sol";

contract Domain is ERC721URIStorage {

  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  string public tld;
  address payable public owner;
  bool internal _locked;
  mapping(string => address) public domains;
  mapping(address => address) public domainRecord;

  string svgPartOne = '<svg xmlns="http://www.w3.org/2000/svg" width="270" height="270" fill="none"><path fill="url(#B)" d="M0 0h270v270H0z"/><defs><filter id="A" color-interpolation-filters="sRGB" filterUnits="userSpaceOnUse" height="270" width="270"><feDropShadow dx="0" dy="1" stdDeviation="2" flood-opacity=".225" width="200%" height="200%"/></filter></defs><path d="M72.863 42.949c-.668-.387-1.426-.59-2.197-.59s-1.529.204-2.197.59l-10.081 6.032-6.85 3.934-10.081 6.032c-.668.387-1.426.59-2.197.59s-1.529-.204-2.197-.59l-8.013-4.721a4.52 4.52 0 0 1-1.589-1.616c-.384-.665-.594-1.418-.608-2.187v-9.31c-.013-.775.185-1.538.572-2.208a4.25 4.25 0 0 1 1.625-1.595l7.884-4.59c.668-.387 1.426-.59 2.197-.59s1.529.204 2.197.59l7.884 4.59a4.52 4.52 0 0 1 1.589 1.616c.384.665.594 1.418.608 2.187v6.032l6.85-4.065v-6.032c.013-.775-.185-1.538-.572-2.208a4.25 4.25 0 0 0-1.625-1.595L41.456 24.59c-.668-.387-1.426-.59-2.197-.59s-1.529.204-2.197.59l-14.864 8.655a4.25 4.25 0 0 0-1.625 1.595c-.387.67-.585 1.434-.572 2.208v17.441c-.013.775.185 1.538.572 2.208a4.25 4.25 0 0 0 1.625 1.595l14.864 8.655c.668.387 1.426.59 2.197.59s1.529-.204 2.197-.59l10.081-5.901 6.85-4.065 10.081-5.901c.668-.387 1.426-.59 2.197-.59s1.529.204 2.197.59l7.884 4.59a4.52 4.52 0 0 1 1.589 1.616c.384.665.594 1.418.608 2.187v9.311c.013.775-.185 1.538-.572 2.208a4.25 4.25 0 0 1-1.625 1.595l-7.884 4.721c-.668.387-1.426.59-2.197.59s-1.529-.204-2.197-.59l-7.884-4.59a4.52 4.52 0 0 1-1.589-1.616c-.385-.665-.594-1.418-.608-2.187v-6.032l-6.85 4.065v6.032c-.013.775.185 1.538.572 2.208a4.25 4.25 0 0 0 1.625 1.595l14.864 8.655c.668.387 1.426.59 2.197.59s1.529-.204 2.197-.59l14.864-8.655c.657-.394 1.204-.95 1.589-1.616s.594-1.418.609-2.187V55.538c.013-.775-.185-1.538-.572-2.208a4.25 4.25 0 0 0-1.625-1.595l-14.993-8.786z" fill="#fff"/><defs><linearGradient id="B" x1="0" y1="0" x2="270" y2="270" gradientUnits="userSpaceOnUse"><stop stop-color="#cb5eee"/><stop offset="1" stop-color="#0cd7e4" stop-opacity=".99"/></linearGradient></defs><text x="32.5" y="231" font-size="27" fill="#fff" filter="url(#A)" font-family="Plus Jakarta Sans,DejaVu Sans,Noto Color Emoji,Apple Color Emoji,sans-serif" font-weight="bold">';
  string svgPartTwo = '</text></svg>';

  constructor(string memory _tld) payable ERC721("Creator Backed Domains", "CBD"){
    owner = payable(msg.sender);
    tld = _tld;
    console.log("%s name service ready!", _tld);
  }

  function price(string calldata _name) public pure returns(uint256) {
    uint256 len = StringUtils.strlen(_name);
    require(len > 0);
    if (len == 3) {
      return 5 * 10**17;
    } else if (len == 4) {
      return 3 * 10**17;
    } else {
      return 1 * 10**17;
    }
  }

  function register(string calldata _name) external payable {
    require(domains[_name] == address(0), "This domain name is taken");
    uint256 _price = this.price(_name);
    require(msg.value >= _price, "insufficient MATIC");

    string memory name = string(abi.encodePacked(_name, ".", tld));
    string memory finalSvg = string(abi.encodePacked(svgPartOne, name, svgPartTwo));

    uint256 newRecordId = _tokenIds.current();
    uint256 length = StringUtils.strlen(_name);
    string memory strLen = Strings.toString(length);

    console.log("Registering %s.%s on the contract with tokenID %d", name, tld, newRecordId);

    string memory json = Base64.encode(
      bytes(
        string(
          abi.encodePacked(
            '{"name": "',
            name,
            '", "description": "Fueling the Creator Economy", "image": "data:image/svg+xml;base64,',
            Base64.encode(bytes(finalSvg)),
            '","length":"',
            strLen,
            '"}'
          )
        )
      )
    );

    string memory finalTokenUri = string( abi.encodePacked("data:application/json;base64,", json));

		console.log("\n--------------------------------------------------------");
	  console.log("Final tokenURI", finalTokenUri);
	  console.log("--------------------------------------------------------\n");

    _safeMint(msg.sender, newRecordId);
    _setTokenURI(newRecordId, finalTokenUri);
    domains[_name] = msg.sender;

    _tokenIds.increment();
    }

  function _getBalance() internal view returns (uint256) {
    return address(this).balance;
  }

  function withdraw() public onlyOwner nonReentrant {
    (bool success,) = msg.sender.call{value: _getBalance()}("");
    require(success, "Withdrawal failed");
  }

  function getAddress(string calldata _name) external view returns(address) {
    return domains[_name];
  }

  function setRecord(string calldata _name,address _record) external {
    require(_record != address(0), "cannot set record to zero address");
    require(domains[_name] == msg.sender, "you must own a domain to set a record");
    domainRecord[msg.sender] = _record;
  }

  function getRecord(address _record) external view returns(address) {
    return domainRecord[_record];
  }

  receive() external payable {}

  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }

  modifier nonReentrant {
    require(!_locked);
    _locked = true;
    _;
    _locked = false;
  }
}
// 0x752f33F49F42908815f8592AFA1d5b50f3Fc429F
