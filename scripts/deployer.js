const main = async () => {
    const Domain = await hre.ethers.getContractFactory("Domain");
    const contract = await Domain.deploy("nft");
    await contract.deployed();

    console.log("Contract deployed to:", contract.address);

    // CHANGE THIS DOMAIN TO SOMETHING ELSE! I don't want to see OpenSea full of bananas lol
    const domain = "zero";
    let txn = await contract.register(domain, {
        value: hre.ethers.utils.parseEther("0.3"),
    });
    await txn.wait();
    console.log("Minted domain zero.nft");

    txn = await contract.setRecord(
        domain,
        "0x48936cf56a6cc74535c72430f22f54da12ae058e"
    );
    await txn.wait();
    console.log("Set record for zero.nft");

    const address = await contract.getAddress(domain);
    console.log("Owner of domain zero:", address);

    const balance = await hre.ethers.provider.getBalance(contract.address);
    console.log("Contract balance:", hre.ethers.utils.formatEther(balance));
};

const runMain = async () => {
    try {
        await main();
        process.exit(0);
    } catch (error) {
        console.log(error);
        process.exit(1);
    }
};

runMain();
