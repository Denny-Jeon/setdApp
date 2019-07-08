## Hyperledger Fabric을 이용한 블록체인 기반 실시간 기업 간 정산 시스템 프로젝트 (Settlement Business Network)

[![Build Status](https://jenkins.hyperledger.org/buildStatus/icon?job=fabric-merge-x86_64)](https://jenkins.hyperledger.org/view/fabric/job/fabric-merge-x86_64/)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/955/badge)](https://bestpractices.coreinfrastructure.org/projects/955)
[![Go Report Card](https://goreportcard.com/badge/github.com/hyperledger/fabric)](https://goreportcard.com/report/github.com/hyperledger/fabric)
[![GoDoc](https://godoc.org/github.com/hyperledger/fabric?status.svg)](https://godoc.org/github.com/hyperledger/fabric)
[![Documentation Status](https://readthedocs.org/projects/hyperledger-fabric/badge/?version=release-1.4)](http://hyperledger-fabric.readthedocs.io/en/release-1.4/?badge=release-1.4)

본 프로젝트는 블록체인 놀이터 교육장에서 제공하는 교육 프로그램인 하이퍼레저 패브릭을 활용한 블록체인 앱(dApp) 개발에서 수행한 개인 프로젝트로 기업 간 거래에서 발생하는 거래 데이터 중 정산 데이터를 블록체인으로 연동하여 처리하는 ["블록체인 기반 실시간 기업 간 정산 시스템 기술"]() 개발을 목표로 한다. 


## Hyperledger Fabric Releases

- [v1.4.1 - April 11, 2019](https://github.com/hyperledger/fabric/releases/tag/v1.4.1)


## 디렉토리 구성

 ["블록체인 기반 실시간 기업 간 정산 시스템 기술"]() 의 디렉토리는 총 4개로 구성된다.
 
- chaincode: 블록체인 비즈니스 네트워크에 배포될 실시간 정산을 위한 체인코드 소스 디렉토리 (javascript로 작성)
- gateway: 블록체인 비즈니스 네트워크에 배포된 실시간 정산 체인코드와 연동하여 사용자의 요청에 의해 데이터를 전달하는 HTTP 기반 실시간 정산을 위한 API 서버 소스
- network: 실시간 정산 비즈니스 네트워크를 구성하는 하이퍼레저 기반 실시간 정산 비즈니스 네트워크 구성 소스 
- ui: 사용자 UI

## 구동 절차

export SETDAPPHOME=/home/aaa/setdApp

1. 블록체인 비즈니스 네트워크 구동
    1. Org1 인증서 생성
    2. Org2 인증서 생성
    3. Channel-Artifacts 생성: 6개의 프로파일을 생성한다.이 중 Org1OrdererGenesis, Org1Channel를 사용한다.
        1. Org1OrdererGenesis
        2. Org1Channel
        3. Org2OrdererGenesis
        4. Org2Channel
        5. Org12OrdererGenesis
        6. Org12Channel
    4. 블록체인 네트워크를 구동
    5. Settlement Business Network 구동 (체인코드 1.0 배포)
    6. Org2  추가 (체인코드 2.0 배포)
```sh
    cd ${SETDAPPHOME}/network
    ./start.sh
```

2. hosts 파일 수정
```node    
    아래 정보를 추가한다. 이유는 인증서를 내려받기 위해서 ca에 접속하는데
    도메인 이름으로 접속하기 때문에 아래와 같이 hosts 파일에 ca 정보를 추가한다.
    sudo vi /etc/hosts
    127.0.0.1 ca.org1.biz1.com
    127.0.0.1 ca.org2.biz2.com
```   

3. 게이트웨이 구동
```node
    cd ${SETDAPPHOME}/gateway/test/javascript/org1
    npm install
    rm -rf ${SETDAPPHOME}/gateway/wallet/org1
    node enrollAdmin.js
    node registerUser.js
    node createRate.js
    cd ${SETDAPPHOME}/gateway
    yarn
    PORT=3002 ORG=org1 yarn start
```
4. UI 구동
```node
    cd ${SETDAPPHOME}/ui
    yarn
    yarn start
```

5. 블록체인 비즈니스 네트워크 종료
```sh
    cd ${SETDAPPHOME}/network
    ./stop.sh


