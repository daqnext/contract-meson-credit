// scripts/deploy_upgradeable_box.js
const { ethers, upgrades } = require('hardhat');

async function main () {
  const MC1 = await ethers.getContractFactory('MesonCreditV1');
  console.log('Deploying MesonCreditV1...');
  const mc1 = await upgrades.deployProxy(MC1, [], { kind: 'transparent'});
  await mc1.deployed();
  console.log('Meson Credit V1 deployed to:', mc1.address);
}

main();