#!/bin/bash -ex
yum update
yum upgrade -y
yum install -y docker
service docker start
gpasswd -a ec2-user docker
docker run -d -p 80:80 iainj027/vatcal:latest
