#!/bin/sh
##
##   Copyright 2015 Dmitry Kolesnikov, All Rights Reserved
##
##   Licensed under the Apache License, Version 2.0 (the "License");
##   you may not use this file except in compliance with the License.
##   You may obtain a copy of the License at
##
##       http://www.apache.org/licenses/LICENSE-2.0
##
##   Unless required by applicable law or agreed to in writing, software
##   distributed under the License is distributed on an "AS IS" BASIS,
##   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
##   See the License for the specific language governing permissions and
##   limitations under the License.
##
## @doc
##   discover and seed Erlang cluster using security group 
set -u
set -e

API=http://169.254.169.254/latest/meta-data
SG=$(curl -s --connect-timeout 1 ${API}/security-groups || echo "none")
AZ=$(curl -s --connect-timeout 1 ${API}/placement/availability-zone || echo "none")

if [[ "${SG}" != "none" ]] ;
then
   aws ec2 \
      describe-instances \
      --region ${AZ:0:${#AZ}-1} \
      --filters "Name=instance.group-name,Values=${SG}" \
      --query 'Reservations[*].Instances[*].PrivateIpAddress' \
      --output text
fi
