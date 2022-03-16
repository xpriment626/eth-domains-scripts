const main = async () => {
  const [owner, user, testRecord] = await hre.ethers.getSigners();
  const Domain = await hre.ethers.getContractFactory("Domain");
  const contract = await Domain.deploy("nft");
  await contract.deployed();
  console.log("Contract deployed to:", contract.address);
  console.log("Contract deployed by:", owner.address);

  const domain = "joemama";
  const newDomain = await contract
    .connect(user)
    .register(domain, { value: hre.ethers.utils.parseEther("0.1") });
  await newDomain.wait();
  const newRecord = await contract
    .connect(user)
    .setRecord(domain, testRecord.address);
  await newRecord.wait();
  const record = await contract.getRecord(user.address);
  console.log(`User has set their record to ${record.toString()}`);
  console.log(`${user.address} has registered the domain: ${domain}`);

  const domainOwner = await contract.getAddress(domain);
  const balance = await hre.ethers.provider.getBalance(contract.address);
  console.log("Domain is Owned By:", domainOwner);
  console.log("Contract Balance:", balance.toString());
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
