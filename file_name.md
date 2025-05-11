## backend.tf

terraform의 state를 관리 <br/> 
aws의 S3, DynamoDB 같은 것들을 사용

## main.tf
모든 리소스, data source 블럭이 포함 된 파일

한 파일에 너무 많은 내용을 집어 넣으면 가독성에 문제가 생길 수 있어 <br/>
network.tf, storage.tf, compute.tf 와 같은 파일 들로 논리적인 목적에 맞는 파일들로 구분 하여 저장할 수도 있음

## outputs.tf
리소스를 생성 하고 나오는 결과들을 출력할 때 사용함

## providers.tf
aws, gcp, azure, ncp와 같은 서비스 프로바이더에 대한 것들을 정의

## terraform.tf
terraform block 으로 되어 있는 것들</br>
provider의 버전 같은 것들을 정의할 때 사용함

## variables.tf
변수를 block화 할 때 사용함

## locals.tf
특정 파일 안에서 지역 변수로 사용할 때 사용함


