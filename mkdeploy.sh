#/bin/bash
echo "  personal.unlockAccount(eth.accounts[0]);" > dodeploy.js

echo -n " var creator_abi = "`solc --optimize --abi immediate_tsting_dao.sol | grep DAO_Creator -A 3 | grep constant` >> dodeploy.js
echo ";" >> dodeploy.js
echo -n " var creator_bin = '"`solc --optimize --bin immediate_tsting_dao.sol | grep DAO_Creator -A 3 | grep 6060` >> dodeploy.js
echo "';" >> dodeploy.js


echo -n " var dao_abi = "`solc --optimize --abi immediate_tsting_dao.sol | grep "======= DAO =======" -A 3 | grep constant` >> dodeploy.js
echo ";" >> dodeploy.js
echo -n " var dao_bin = '"`solc --optimize --bin immediate_tsting_dao.sol | grep DAO_Creator -A 3 | grep 6060` >> dodeploy.js
echo "';" >> dodeploy.js
echo "" >> dodeploy.js
echo "var creatorContract = web3.eth.contract(creator_abi);" >> dodeploy.js
echo "var daoCreatorContract = creatorContract.new({from: web3.eth.accounts[0], data: creator_bin, gas: 4000000});" >> dodeploy.js


echo " var daoContract = web3.eth.contract(dao_abi); " >> dodeploy.js

echo " var dao = daoContract.new('', '', web3.toWei(0, 'ether'), web3.toWei(1, 'ether'), 1467344365, 0, {from: eth.accounts[0], data: dao_bin, gas: 4000000}); " >>dodeploy.js
