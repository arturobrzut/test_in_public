mkdir ./lib
cd lib
wget https://raw.githubusercontent.com/bats-core/bats-detik/master/lib/detik.bash
wget https://raw.githubusercontent.com/bats-core/bats-detik/master/lib/linter.bash
wget https://raw.githubusercontent.com/bats-core/bats-detik/master/lib/utils.bash
chmod +x *.bash
cd ..
chmod +x *.bats
bats ./tests.bats
