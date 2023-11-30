// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Project.sol";

contract OrganizationContract is Ownable {
    enum MemberStatus {
        Pending,
        Accepted
    }

    struct Member {
        uint id;
        string uname;
        MemberStatus status;
        bool isRegistered;
    }

    struct ProjectStr {
        string name;
        address projectContractAddress;
    }

    mapping(uint256 => ProjectStr) public projects;
    mapping(address => Member) public members;
    uint256 public projectCount;
    uint256 public memberCount;

    event ProjectCreated(
        uint256 indexed projectId,
        string projectName,
        address projectContractAddress
    );
    event MemberRegistrationRequested(address indexed memberAddr, string uname);
    event MemberAccepted(address indexed memberAddr);
    event MemberRejected(address indexed memberAddr);
    event MemberAddedToProject(
        uint256 indexed projectId,
        address indexed memberAddr
    );
    event MemberRemovedFromProject(
        uint256 indexed projectId,
        address indexed member
    );
    event MilestoneProofSubmitted(
        uint256 indexed projectId,
        address indexed memberAddr
    );
    event MilestoneProofVerified(
        uint256 indexed projectId,
        address indexed memberAddr
    );

    constructor() Ownable(msg.sender) {}

    function requestToJoin(string memory uname) public {
        uint256 memberId = memberCount++;
        members[msg.sender] = Member(
            memberId,
            uname,
            MemberStatus.Pending,
            false
        );
        emit MemberRegistrationRequested(msg.sender, uname);
    }

    function acceptMember(address memberAddr) public onlyOwner {
        require(
            members[memberAddr].status == MemberStatus.Pending,
            "Member not pending"
        );
        require(!members[memberAddr].isRegistered, "Member already registered");
        members[memberAddr].status = MemberStatus.Accepted;
        members[memberAddr].isRegistered = true;
        emit MemberAccepted(memberAddr);
    }

    function rejectMember(address memberAddr) public onlyOwner {
        require(
            members[memberAddr].status == MemberStatus.Pending,
            "Member not pending"
        );
        require(!members[memberAddr].isRegistered, "Member already registered");
        delete members[memberAddr];
        emit MemberRejected(memberAddr);
    }

    function createProject(
        string memory projectName,
        string memory projectCode,
        string memory baseUri
    ) public onlyOwner {
        uint256 projectId = projectCount++;
        Project newProject = new Project(
            projectName,
            projectCode,
            address(this),
            baseUri
        );
        projects[projectId] = ProjectStr(projectName, address(newProject));
        emit ProjectCreated(projectId, projectName, address(newProject));
    }

    function addMemberToProject(
        uint256 projectId,
        address memberAddr
    ) public onlyOwner {
        require(members[memberAddr].isRegistered, "Member not registered");
        Project project = Project(projects[projectId].projectContractAddress);
        project.addMember(memberAddr);
        emit MemberAddedToProject(projectId, memberAddr);
    }

    function removeMemberFromProject(
        uint256 projectId,
        address member
    ) public onlyOwner {
        Project project = Project(projects[projectId].projectContractAddress);
        project.removeMember(member);
        emit MemberRemovedFromProject(projectId, member);
    }

    function submitMilestoneProof(uint256 projectId) public {
        require(members[msg.sender].isRegistered, "Member not registered");
        Project project = Project(projects[projectId].projectContractAddress);
        project.submitMilestoneProof(msg.sender);
        emit MilestoneProofSubmitted(projectId, msg.sender);
    }

    function verifyMilestone(
        uint256 projectId,
        address memberAddress
    ) public onlyOwner {
        Project project = Project(projects[projectId].projectContractAddress);
        project.verifyMilestoneProof(memberAddress);
        emit MilestoneProofVerified(projectId, memberAddress);
    }
    /**
     *     function assignAndUpdateMilestoneToMember(
        uint256 projectId,
        address member,
        string memory milestoneURI
    ) public onlyOwner {
        Project project = Project(projects[projectId].projectContractAddress);
        project.assignMilestone(member, milestoneURI);
    }
     */
}
