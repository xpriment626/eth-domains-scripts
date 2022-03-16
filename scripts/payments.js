const main = async () => {
    const [owner, user, theft] = await hre.ethers.getSigners();
    const Domain = await hre.ethers.getContractFactory("Domain");
    const contract = await Domain.deploy("nft");
    await contract.deployed();
    console.log("Contract deployed to:", contract.address);
    console.log("Contract deployed by:", owner.address);

    const domain = "joemama";
    const domain_2 = "gsp";
    const newDomain = await contract
        .connect(user)
        .register(domain, { value: hre.ethers.utils.parseEther("0.1") });
    await newDomain.wait();

    const newDomain_2 = await contract
        .connect(user)
        .register(domain_2, { value: hre.ethers.utils.parseEther("0.5") });
    await newDomain_2.wait();

    let balance = await hre.ethers.provider.getBalance(contract.address);
    console.log("Contract Balance:", balance.toString());

    try {
        malicious = await contract.connect(theft).withdraw();
        await malicious.wait();
    } catch (error) {
        console.log("-----------------------------------");
        console.log("Transaction reverted successfully");
        console.log(`Malicious Withdrawal Attempt: ${theft.address}`);
        console.log(`Contract Balance Log: ${balance}`);
        console.log("-----------------------------------");
    }

    let ownerBalance = await hre.ethers.provider.getBalance(owner.address);
    console.log("-------------------------------------------------------");
    console.log(`Owner Balance: ${ownerBalance.toString()}`);

    tx = await contract.connect(owner).withdraw();
    await tx.wait();
    balance = await hre.ethers.provider.getBalance(contract.address);
    ownerBalance = await hre.ethers.provider.getBalance(owner.address);
    console.log(`Contract Balance Log: ${balance.toString()}`);
    console.log(`Owner Balance Log: ${ownerBalance.toString()}`);
    console.log("-------------------------------------------------------");
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
