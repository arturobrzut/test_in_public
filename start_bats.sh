#!/bin/bash
#
# Copyright 2020 IBM Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http:#www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

mkdir ./lib
cd lib
wget https://raw.githubusercontent.com/bats-core/bats-detik/master/lib/detik.bash
wget https://raw.githubusercontent.com/bats-core/bats-detik/master/lib/linter.bash
wget https://raw.githubusercontent.com/bats-core/bats-detik/master/lib/utils.bash
chmod +x *.bash
cd ..
chmod +x *.bats
bats ./tests.bats > ./bats_logs.txt
