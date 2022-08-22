// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;
import "hardhat/console.sol";
import "../Interfaces/IOAMNFT.sol";
import "../../Libraries/Interfaces/IERC20.sol";
import "../../Libraries/Interfaces/IERC721.sol";
import "../../Libraries/Utils/Ownable.sol";
import "../Interfaces/IOAMUsersVerification.sol";
import "../Interfaces/IOAMarketManagement.sol";
import "../Interfaces/IOAMITOManagement.sol";
import "../Interfaces/IOAMNFT.sol";
import "../Interfaces/IOAMDAO.sol";
import "../Interfaces/IOAMNFTSales.sol";

contract OAMITOManagement is IOAMITOManagement, Ownable {
    //+-I.T.O. & Token Share Parameters:_
    mapping(address => uint256) public itoSharePrice;
    mapping(address => uint256) ITOSharesInitialSupply;
    mapping(address => bool) public InitialTokenSharesSetOnce;
    mapping(address => uint256) public NFTValue;
    mapping(address => uint256) public itoInitialAvailableShares;
    mapping(address => bool) public itoStarted;
    mapping(address => bool) public itoEnded;
    mapping(address => bool) public isFreezedAfterITO;
    mapping(address => address) public NFTDAOTfiatTokenAddress;
    mapping(address => uint256) public SharesSoldInITO;
    mapping(address => bool) CalledwithdrawItoUnSoldShares;

    address public OAMUsersVerificationAddress;
    IOAMUsersVerification OAMUVContract =
        IOAMUsersVerification(OAMUsersVerificationAddress);
    address public OAMarketManagementAddress;
    IOAMarketManagement OAMMContract =
        IOAMarketManagement(OAMarketManagementAddress);
    address public OAMDAOAddress;
    IOAMDAO OAMDAOContract = IOAMDAO(OAMDAOAddress);
    address public OAMNFTSalesAddress;
    IOAMNFTSales OAMNFTSalesContract = IOAMNFTSales(OAMNFTSalesAddress);

    /**
     * @dev Throws if called by any account other than the artwork collector.
     */
    modifier onlyCollector(address _nftAddress) {
        require(
            msg.sender == IOAMNFT(_nftAddress).getArtWorkOwner(),
            "Caller is not the ArtWork Owner."
        );
        _;
    }

    function setNewOAMUVAddress(address _addr) public onlyOwner {
        OAMUsersVerificationAddress = _addr;
        OAMUVContract = IOAMUsersVerification(OAMUsersVerificationAddress);
    }

    function setNewOAMMAddress(address _addr) public onlyOwner {
        OAMarketManagementAddress = _addr;
        OAMMContract = IOAMarketManagement(OAMarketManagementAddress);
    }

    function setNewOAMDAOAddress(address _addr) public onlyOwner {
        OAMDAOAddress = _addr;
        OAMDAOContract = IOAMDAO(OAMDAOAddress);
    }

    function setNewOAMNFTSalesAddress(address _addr) public onlyOwner {
        OAMNFTSalesAddress = _addr;
        OAMNFTSalesContract = IOAMNFTSales(OAMNFTSalesAddress);
    }

    //+-Get the Token Share Price of the ArtWork N.F.T. at the time of the I.T.O.:_
    function getItoSharePrice(address _nftAddress)
        public
        view
        override
        returns (uint256)
    {
        require(
            OAMUVContract.onlyPlatformNFTs(_nftAddress),
            "Not a Platform N.F.T."
        );
        return itoSharePrice[_nftAddress];
    }

    //+-Set the Token Share Price of the ArtWork N.F.T. at the time of the I.T.O.:_
    function setItoSharePrice(address _nftAddress, uint256 _value)
        public
    {
        require(OAMUVContract.onlyOwnerOrServer(msg.sender), 'Only Owner or Server can perform this function');
        require(
            OAMUVContract.onlyPlatformNFTs(_nftAddress),
            "Not a Platform N.F.T."
        );
        itoSharePrice[_nftAddress] = _value;
    }

    //+-Get the Token Shares of the ArtWork N.F.T. available at the I.T.O.:_
    function getItoInitialAvailableShares(address _nftAddress)
        public
        view
        override
        returns (uint256)
    {
        require(
            OAMUVContract.onlyPlatformNFTs(_nftAddress),
            "Not a Platform N.F.T."
        );
        return itoInitialAvailableShares[_nftAddress];
    }

    //+-Set the Token Shares of the ArtWork N.F.T. available at the I.T.O.:_
    function setItoInitialAvailableShares(
        address _nftAddress,
        uint256 _availableShares
    ) public {
        require(OAMUVContract.onlyOwnerOrServer(msg.sender), 'Only Owner or Server can perform this function');
        require(
            OAMUVContract.onlyPlatformNFTs(_nftAddress) == true,
            "Not a Platform N.F.T."
        );
        itoInitialAvailableShares[_nftAddress] = _availableShares;
    }

    //+-Get the Token Shares Total Supply of the ArtWork N.F.T.:_
    function getItoShareSupply(address _nftAddress)
        public
        view
        override
        returns (uint256)
    {
        require(
            OAMUVContract.onlyPlatformNFTs(_nftAddress),
            "Not a Platform N.F.T."
        );
        return ITOSharesInitialSupply[_nftAddress];
    }

    //+-Know if the I.T.O. of an ArtWork N.F.T. has already started or not:_
    function getItoStarted(address _nftAddress)
        public
        view
        override
        returns (bool)
    {
        require(
            OAMUVContract.onlyPlatformNFTs(_nftAddress),
            "Not a Platform N.F.T."
        );
        return itoStarted[_nftAddress];
    }

    //+-Know if the I.T.O. of an ArtWork N.F.T. has already ended or not:_
    function getItoEnded(address _nftAddress)
        public
        view
        override
        returns (bool)
    {
        require(
            OAMUVContract.onlyPlatformNFTs(_nftAddress),
            "Not a Platform N.F.T."
        );
        return itoEnded[_nftAddress];
    }

    //+-Know if the Transctions of an ArtWork N.F.T. Shares are Frozen or not:_
    function getIsFreezedAfterITO(address _nftAddress)
        public
        view
        override
        returns (bool)
    {
        require(
            OAMUVContract.onlyPlatformNFTs(_nftAddress),
            "Not a Platform N.F.T."
        );
        return isFreezedAfterITO[_nftAddress];
    }

    /**+-The ArtWork Owner can change the Initial Price in Fiat Tokens (Price + 2 decimals) of the N.F.T.
    and its Shares if the I.T.O/Normal Auction did not Started yet:_*/
    function setNFTInitialPrice(address _nftAddress, uint256 nftPrice)
        public
    {
        require(OAMUVContract.onlyOwnerOrServer(msg.sender), 'Only Owner or Server can perform this function');
        require(
            OAMUVContract.onlyPlatformNFTs(_nftAddress),
            "Not a Platform N.F.T."
        );
        require(
            itoStarted[_nftAddress] == false,
            "I.T.O. has already started."
        );
        NFTValue[_nftAddress] = nftPrice;
        /**+-After setting this Price, the N.F.T. BuyOut Price must be set Manually in the N.F.T. Sales S.C..
        The values can be set as long as a marketsale is not active.*/
        OAMNFTSalesContract.setNFTImpliedValueInOriginalDAOFiatToken(
            _nftAddress,
            NFTValue[_nftAddress]
        );
    }

    function getNFTValue(address _nftAddress)
        public
        view
        override
        returns (uint256)
    {
        return NFTValue[_nftAddress];
    }

    /**+-The ArtWork Owner can Set the Initial Amount of Token Shares
    if the I.T.O/Normal Auction did not Started yet:_*/
    function setNFTInitialTokenShares(
        address _nftAddress,
        uint256 tokenSharesAmount
    ) public {
        require(OAMUVContract.onlyOwnerOrServer(msg.sender), 'Only Owner or Server can perform this function');
        require(
            OAMUVContract.onlyPlatformNFTs(_nftAddress),
            "Not a Platform N.F.T."
        );
        require(NFTValue[_nftAddress] > 0, "Set the N.F.T.Value 1st");
        require(
            itoStarted[_nftAddress] == false,
            "I.T.O. has already started."
        );
        ITOSharesInitialSupply[_nftAddress] = tokenSharesAmount;
        itoSharePrice[_nftAddress] =
            NFTValue[_nftAddress] /
            ITOSharesInitialSupply[_nftAddress];
        InitialTokenSharesSetOnce[_nftAddress] = true;
    }

    /**+-When the ArtWork Owner wants to Start the I.T.O., We Transfer the N.F.T. from the Collector's Wallet to the O.A.M.I.T.O.
    Management Smart Contract, we Divide it in Shares and We sell it in an I.T.O:_*/
    function startIto(address _nftAddress) public {
        require(OAMUVContract.onlyOwnerOrServer(msg.sender), 'Only Owner or Server can perform this function');
        require(
            OAMUVContract.onlyPlatformNFTs(_nftAddress),
            "Not a Platform N.F.T."
        );
        require(itoStarted[_nftAddress] == false, "ITO already started");
        require(
            InitialTokenSharesSetOnce[_nftAddress] == true,
            "Need to set T.Shares Initial Supply 1st."
        );

        IERC721(_nftAddress).ERC721transferFrom(
            IOAMNFT(_nftAddress).getArtWorkOwner(),
            address(this),
            IOAMNFT(_nftAddress).getArtWorkId()
        );
        //+-All ERC-884 Token Shares gets Minted at the I.T.O., where a split between the ArtWorkOwner and O.A.M. is set - configurable, default 5% of tokens for O.A.M., rest for ArtWorkOwner.
        IERC20(_nftAddress)._ERC20mint(
            msg.sender,
            msg.sender,
            ((ITOSharesInitialSupply[_nftAddress] / 100) * 5)
        );
        if (OAMDAOContract.isShareholder(_nftAddress, msg.sender) == false) {
            OAMDAOContract.updateShareholders(_nftAddress, msg.sender);
        }
        SharesSoldInITO[_nftAddress] = ((ITOSharesInitialSupply[_nftAddress] /
            100) * 5);
        itoStarted[_nftAddress] = true;
        isFreezedAfterITO[_nftAddress] = false;
        emit StartITO(_nftAddress);
    }

    /**+-ArtWork Owner can Finish the I.T.O. whenever he/she wants:_*/
    function finishIto(address _nftAddress) public {
        require(OAMUVContract.onlyOwnerOrServer(msg.sender), 'Only Owner or Server can perform this function');
        require(
            OAMUVContract.onlyPlatformNFTs(_nftAddress),
            "Not a Platform N.F.T."
        );
        require(itoStarted[_nftAddress] == true, "I.T.O. has not started yet.");
        itoEnded[_nftAddress] = true;
        emit EndITO(_nftAddress);
    }

    /**+-ArtWork Owner can Finish the I.T.O. whenever he/she wants:_*/
    function setIsFreezedAfterITO(address _nftAddress, bool _isFreezed)
        public
    {
        require(OAMUVContract.onlyOwnerOrServer(msg.sender), 'Only Owner or Server can perform this function');
        require(
            OAMUVContract.onlyPlatformNFTs(_nftAddress),
            "Not a Platform N.F.T."
        );
        require(itoEnded[_nftAddress] == true, "I.T.O. has not ended yet.");
        isFreezedAfterITO[_nftAddress] = _isFreezed;
    }

    //+-The Users can Buy Shares of the N.F.T. at the I.T.O:_
    function buyShare(address _nftAddress, uint256 shareAmount) public {
        require(
            OAMUVContract.onlyPlatformNFTs(_nftAddress),
            "Not a Platform N.F.T."
        );
        require(OAMUVContract.isVerified(msg.sender), "Not a Verified User.");
        require(itoStarted[_nftAddress], "I.T.O. not started.");
        require(itoEnded[_nftAddress] == false, "I.T.O. has closed.");
        require(
            (IERC20(_nftAddress).ERC20totalSupply() -
                IERC20(_nftAddress).ERC20balanceOf(_owner)) +
                shareAmount <=
                itoInitialAvailableShares[_nftAddress],
            "Not Enough Shares left."
        );
        uint256 fiatTokenAmount = shareAmount * itoSharePrice[_nftAddress];
        address artworkOwnerAddress = IOAMNFT(_nftAddress).getArtWorkOwner();
        address fiatTokenAddress = IOAMNFT(_nftAddress)
            .getDAOFiatTokenAddress();

        IERC20(fiatTokenAddress).ERC20transferFrom(
            msg.sender,
            artworkOwnerAddress,
            fiatTokenAmount
        );
        if (OAMDAOContract.isShareholder(_nftAddress, msg.sender) == false) {
            OAMDAOContract.updateShareholders(_nftAddress, msg.sender);
        }
        IERC20(_nftAddress)._ERC20mint(_owner, msg.sender, shareAmount);
        SharesSoldInITO[_nftAddress] += shareAmount;
        emit Transfer(_nftAddress, msg.sender, shareAmount);
        if (
            msg.sender != IOAMNFT(_nftAddress).getArtWorkOwner() &&
            OAMDAOContract.allowListed(_nftAddress, msg.sender) == false
        ) {
            OAMDAOContract.addVoter(_nftAddress, msg.sender);
        }
    }

    //+-The ArtWork Owner can Withdraw the Shares of the N.F.T. that have not been Sold after the I.T.O finished:_
    function withdrawItoUnSoldShares(address _nftAddress)
        public
        onlyCollector(_nftAddress)
    {
        require(
            OAMUVContract.onlyPlatformNFTs(_nftAddress),
            "Not a Platform N.F.T."
        );
        require(
            CalledwithdrawItoUnSoldShares[msg.sender] == false,
            "You can Only Do this Once"
        );
        require(itoEnded[_nftAddress], "I.C.O. Not Finished yet.");

        CalledwithdrawItoUnSoldShares[msg.sender] = true;
        uint256 unsoldShareBalance = ITOSharesInitialSupply[_nftAddress] -
            SharesSoldInITO[_nftAddress];
        if (unsoldShareBalance > 0) {
            IERC20(_nftAddress)._ERC20mint(
                _owner,
                IOAMNFT(_nftAddress).getArtWorkOwner(),
                unsoldShareBalance
            );
        }
        OAMDAOContract.addVoter(
            _nftAddress,
            IOAMNFT(_nftAddress).getArtWorkOwner()
        );
        if (OAMDAOContract.isShareholder(_nftAddress, msg.sender) == false) {
            OAMDAOContract.updateShareholders(_nftAddress, msg.sender);
        }
    }
}
