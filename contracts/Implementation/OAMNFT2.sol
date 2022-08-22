// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

import "hardhat/console.sol";
import "../Libraries/TokenContracts/ERC721Enumerable.sol";
import "../Libraries/TokenContracts/ERC20.sol";
import "../Libraries/Utils/Strings.sol";
import "../SubContracts/Interfaces/IOAMNFT.sol";
import "../SubContracts/Interfaces/IOAMUsersVerification.sol";
import "../SubContracts/Interfaces/IOAMarketManagement.sol";
import "../SubContracts/Interfaces/IOAMDAO.sol";
import "../SubContracts/Interfaces/IOAMITOManagement.sol";
import "../SubContracts/Interfaces/IOAMNFTSales.sol";
import "../SubContracts/Interfaces/IOAMEnglishAuctions.sol";
import "../SubContracts/Interfaces/IOAMDutchAuctions.sol";

/**
 *  +-An ERC884 Token is an `ERC20` Compatible Token that conforms to Delaware State Senate,
 *  149th General Assembly, Senate Bill No. 69: An act to Amend Title 8
 *  of the Delaware Code Relating to the General Corporation Law.
 *  +-The ERC884 Token is a derivative of the ERC20 Token.
 *
 *  `decimals` — MUST return `0` as each token represents a single Share and Shares are non-divisible.
 *
 *  @dev Ref https://github.com/ethereum/EIPs/blob/master/EIPS/eip-884.md
 */
/**, IOAMUsersVerification*/
contract OAMNFT2 is ERC721Enumerable, ERC20, IOAMNFT {
    using Strings for uint256;

    //+-N.F.T. Parameters:_
    address public artWorkOwner; //(Here you need to Set the Real ArtWork Owner Wallet Address).
    string public artWorkName = "Artwork 2022 02";
    string public artWorkSymbol = "OAM2202";
    uint256 public artWorkId = 2; //+-INSTERT TOKEN I.D. Number HERE.
    string public baseURI = "https://openartmarket.com/contract/OAM2202";
    string public baseExtension = ".json";

    string public artShareName = "OAM 2022 02";
    string public artShareSymbol = "OAM2202";
    address public DAOFiatTokenAddress;

    address public OAMUsersVerificationAddress;
    IOAMUsersVerification OAMUVContract =
        IOAMUsersVerification(OAMUsersVerificationAddress);
    address public OAMarketManagementAddress;
    IOAMarketManagement OAMMContract =
        IOAMarketManagement(OAMarketManagementAddress);
    address public OAMITOManagementAddress;
    IOAMITOManagement OAMITOManagementContract =
        IOAMITOManagement(OAMITOManagementAddress);
    address public OAMDAOAddress;
    IOAMDAO OAMDAOContract = IOAMDAO(OAMDAOAddress);
    address public OAMNFTSalesAddress;
    IOAMNFTSales OAMNFTSalesContract = IOAMNFTSales(OAMNFTSalesAddress);
    address public OAMEnglishAuctionsAddress;
    IOAMEnglishAuctions OAMEnglishAuctionsContract =
        IOAMEnglishAuctions(OAMEnglishAuctionsAddress);
    address public OAMDutchAuctionsAddress;
    IOAMDutchAuctions OAMDutchAuctionsContract =
        IOAMDutchAuctions(OAMDutchAuctionsAddress);

    mapping(address => bool) public isPlatformSmartContract;

    constructor()
        ERC721(artWorkName, artWorkSymbol)
        ERC20(artShareName, artShareSymbol)
    {}

    function decimals() public view virtual override returns (uint16) {
        return 0;
    }

    function setNewOAMUVAddress(address _addr) public onlyOwner {
        isPlatformSmartContract[OAMUsersVerificationAddress] = false;
        OAMUsersVerificationAddress = _addr;
        isPlatformSmartContract[_addr] = true;
        OAMUVContract = IOAMUsersVerification(OAMUsersVerificationAddress);
    }

    function setNewOAMMAddress(address _addr) public onlyOwner {
        isPlatformSmartContract[OAMarketManagementAddress] = false;
        OAMarketManagementAddress = _addr;
        isPlatformSmartContract[_addr] = true;
        OAMMContract = IOAMarketManagement(OAMarketManagementAddress);
    }

    function setNewOAMITOManagementAddress(address _addr) public onlyOwner {
        isPlatformSmartContract[OAMITOManagementAddress] = false;
        OAMITOManagementAddress = _addr;
        isPlatformSmartContract[_addr] = true;
        OAMITOManagementContract = IOAMITOManagement(OAMITOManagementAddress);
    }

    function setNewOAMDAOAddress(address _addr) public onlyOwner {
        isPlatformSmartContract[OAMDAOAddress] = false;
        OAMDAOAddress = _addr;
        isPlatformSmartContract[_addr] = true;
        OAMDAOContract = IOAMDAO(OAMDAOAddress);
    }

    function setNewOAMNFTSalesAddress(address _addr) public onlyOwner {
        isPlatformSmartContract[OAMNFTSalesAddress] = false;
        OAMNFTSalesAddress = _addr;
        isPlatformSmartContract[_addr] = true;
        OAMNFTSalesContract = IOAMNFTSales(OAMNFTSalesAddress);
    }

    function setNewOAMEnglishAuctionsAddress(address _addr) public onlyOwner {
        isPlatformSmartContract[OAMEnglishAuctionsAddress] = false;
        OAMEnglishAuctionsAddress = _addr;
        isPlatformSmartContract[_addr] = true;
        OAMEnglishAuctionsContract = IOAMEnglishAuctions(
            OAMEnglishAuctionsAddress
        );
    }

    function setNewOAMDutchAuctionsAddress(address _addr) public onlyOwner {
        isPlatformSmartContract[OAMDutchAuctionsAddress] = false;
        OAMDutchAuctionsAddress = _addr;
        isPlatformSmartContract[_addr] = true;
        OAMDutchAuctionsContract = IOAMDutchAuctions(OAMDutchAuctionsAddress);
    }

    function setApprovAllPlatformContracts() public onlyOwner {
        setApprovalForAll(OAMUsersVerificationAddress, true);
        setApprovalForAll(OAMarketManagementAddress, true);
        setApprovalForAll(OAMDAOAddress, true);
        setApprovalForAll(OAMITOManagementAddress, true);
        setApprovalForAll(OAMNFTSalesAddress, true);
        setApprovalForAll(OAMEnglishAuctionsAddress, true);
        setApprovalForAll(OAMDutchAuctionsAddress, true);
    }

    /**
     * @dev Transfers Power of the contract to a new account (`newCollector`).
     * Can only be called by the S.C..
     */
    function transferPower(address newCollector) internal {
        require(newCollector != address(0), "New owner is the zero address");
        artWorkOwner = newCollector;
    }

    //+-We require the Value "tokenId" that is useless for the NFT just for Replacing the ERC721transferFrom Function.
    function ERC721transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        //solhint-disable-next-line max-line-length
        //+-If the N.F.T. have NOT been Tokenized into Shares yet, it can be transferred between artWorkOwner and OAM S.C.s Normally:_
        if (
            (OAMITOManagementContract.getItoStarted(address(this)) == false &&
                from == artWorkOwner &&
                isPlatformSmartContract[to]) ||
            (OAMITOManagementContract.getItoStarted(address(this)) == false &&
                isPlatformSmartContract[from] &&
                to == artWorkOwner)
        ) {
            _ERC721transfer(from, to, artWorkId);
        }
        //+-If the I.T.O. did not Started yet and the N.F.T. is transferred from the artWorkOwner or the OAMarketplace S.C. to another User, the last one will become the Owner of the D.A.O.:_
        if (
            OAMITOManagementContract.getItoStarted(address(this)) == false &&
            isPlatformSmartContract[to] == false
        ) {
            transferPower(to);
            _ERC721transfer(from, to, artWorkId);
        }
        /**+-If the N.F.T. have already been Tokenized into Shares and therefore is in possession of OAM, it can ONLY be transferred
        to the User who bought the ArtWork by Buyout from the O.A.M. S.C.:_*/
        if (OAMITOManagementContract.getItoStarted(address(this)) == true) {
            require(
                OAMUVContract.onlyOwnerOrNFT(msg.sender) ||
                    OAMMContract.onlyPlatformSCs(msg.sender),
                "Only Platform S.C./Owner can do this."
            );
            _ERC721transfer(from, to, artWorkId);
        }
    }

    //+-Returns the MetaData U.R.I. of the ArtWork:_
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    //+-Returns the MetaData U.R.I. of the ArtWork:_
    function tokenURI() public view virtual override returns (string memory) {
        require(_exists(1), "ERC721Metadata: URI query for nonexistent token");

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(abi.encodePacked(currentBaseURI, "1", baseExtension))
                : "";
    }

    //+-Change the MetaData U.R.I. of the ArtWork:_
    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension)
        public
        onlyOwner
    {
        baseExtension = _newBaseExtension;
    }

    //+-Implementation of the ERC-884 Standard Transfer for the Token Shares:_

    function _ERC20mint(
        address origin,
        address account,
        uint256 amount
    ) public virtual override {
        require(
            OAMUVContract.onlyOwnerOrNFT(msg.sender) ||
                OAMMContract.onlyPlatformSCs(msg.sender),
            "Only Platform S.C./Owner can do this."
        );
        require(origin == _owner, "Only owner can mint new tokens");
        require(account != address(0), "ERC20: mint to the zero address");

        _ERC20beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit ERC20Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, amount);
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        require(OAMUVContract.isVerified(msg.sender), "Not a Verified User.");
        //+-Token Shares Post-I.T.O. Freezing Feature:_
        if (
            OAMITOManagementContract.getItoStarted(address(this)) == true &&
            OAMITOManagementContract.getItoEnded(address(this)) == true
        ) {
            require(
                OAMITOManagementContract.getIsFreezedAfterITO(address(this)) ==
                    false,
                "Tokens are Frozen During Post-I.T.O. Period."
            );
            return false;
        }
        if (ERC20balanceOf(recipient) <= 0) {
            OAMDAOContract.updateShareholders(address(this), recipient);
        }
        _ERC20transfer(msg.sender, recipient, amount);
        if (ERC20balanceOf(msg.sender) <= 0) {
            OAMDAOContract.pruneShareholders(address(this), msg.sender);
        }
        return true;
    }

    //+-Implementation of the ERC-884 Standard Transfer for the Token Shares:_
    function ERC20transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external virtual override returns (bool) {
        require(OAMUVContract.isVerified(sender), "Not a Verified Sender.");
        require(
            OAMUVContract.isVerified(recipient),
            "Not a Verified Recipient."
        );
        if (ERC20balanceOf(recipient) <= 0) {
            OAMDAOContract.updateShareholders(address(this), recipient);
        }
        _ERC20transfer(sender, recipient, amount);
        if (ERC20balanceOf(sender) <= 0) {
            OAMDAOContract.pruneShareholders(address(this), sender);
        }

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    //+-Get the Collector's Address of the ArtWork N.F.T.:_
    function getArtWorkOwner() public view override returns (address) {
        return artWorkOwner;
    }

    //+-Set the Collector's Address of the ArtWork N.F.T.:_
    function setArtWorkOwner(address _newAddr) public {
        require(OAMUVContract.onlyOwnerOrServer(msg.sender), 'Only Owner or Server can perform this function');
        artWorkOwner = _newAddr;
    }

    /**+-When the Contract is Deployed from O.A.M.'s Wallet and after
    the ArtWork Owner is Set, the Only ERC-721 N.F.T. of the ArtWork needs
    to be Minted Minted with a TokenID = 1 and Transferred to the ArtWork Owner.*/
    function createAndSendNFT() public {
        require(OAMUVContract.onlyOwnerOrServer(msg.sender), 'Only Owner or Server can perform this function');
        _ERC721mint(artWorkOwner, artWorkId);
    }

    //+-The MarketPlace S.C. can know which is the Default Fiat Currency Token of the D.A.O.:_
    function getDAOFiatTokenAddress() public view override returns (address) {
        return DAOFiatTokenAddress;
    }

    //+-Set the D.A.O. Fiat Token of the ArtWork N.F.T.:
    function setDAOFiatToken(address _newToken) public {
        require(OAMUVContract.onlyOwnerOrServer(msg.sender), 'Only Owner or Server can perform this function');
        DAOFiatTokenAddress = _newToken;
    }

    //+-Get the Id of the ArtWork N.F.T.:_
    function getArtWorkId() public view override returns (uint256) {
        return artWorkId;
    }
}
