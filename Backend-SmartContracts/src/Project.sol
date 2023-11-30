// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Project is ERC721, Ownable {
    uint256 private nextTokenId;
    mapping(address => uint256) public memberToTokenId;
    mapping(address => Member) public members;
    string private baseURI;

    struct Member {
        address memberAddr;
        bool proofSubmittedForMilestone;
    }

    event BaseURISet(string indexed newBaseURI);
    event MemberAdded(address indexed member, uint256 indexed tokenId);
    event MemberRemoved(address indexed member);
    event MilestoneProofSubmitted(address indexed memberAddress);
    event MilestoneProofVerified(address indexed memberAddress);

    constructor(
        string memory projectName,
        string memory projectCode,
        address orgContractAddress,
        string memory baseUri
    ) ERC721(projectName, projectCode) Ownable(orgContractAddress) {
        baseURI = baseUri;
    }

    function setBaseURI(string memory newBaseURI) public onlyOwner {
        baseURI = newBaseURI;
        emit BaseURISet(newBaseURI);
    }

    function addMember(address member) public onlyOwner {
        uint256 tokenId = nextTokenId++;
        _safeMint(member, tokenId);
        memberToTokenId[member] = tokenId;
        emit MemberAdded(member, tokenId);
    }

    function removeMember(address member) public onlyOwner {
        uint256 tokenId = memberToTokenId[member];
        _burn(tokenId);
        delete memberToTokenId[member];
        emit MemberRemoved(member);
    }

    function submitMilestoneProof(address memberAddress) public onlyOwner {
        require(
            !members[memberAddress].proofSubmittedForMilestone,
            "Proof already submitted for the most recent milestone"
        );
        members[memberAddress].proofSubmittedForMilestone = true;
        emit MilestoneProofSubmitted(memberAddress);
    }

    function verifyMilestoneProof(address memberAddress) public onlyOwner {
        require(
            members[memberAddress].proofSubmittedForMilestone,
            "No proof submitted"
        );
        members[memberAddress].proofSubmittedForMilestone = false;
        emit MilestoneProofVerified(memberAddress);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        require(ownerOf(tokenId) != address(0), "Token does not exist");
        return string(abi.encodePacked(baseURI, Strings.toString(tokenId)));
    }

    /*function assignMilestone(
        address member,
        string memory mileStoneURI
    ) public onlyOwner returns(uint) {
        require(member != address(0), "No tokens are allowed to zero address");
        updateMetadata(member, mileStoneURI);
    }*/
}
