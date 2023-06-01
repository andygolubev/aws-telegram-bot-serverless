#!/bin/bash
python3 --version

poetry export --output requirements.txt --without-hashes

mkdir -p ./packages
pip3 install --target="./packages" -r ./requirements.txt

cd ./packages
zip -r ../my-deployment-package.zip .
cd ..
zip ./my-deployment-package.zip *.py


aws lambda get-function --function-name my-function-1 --no-cli-pager 

if [ $? -eq 0 ]; then

echo "### UPDATE ###"
aws lambda update-function-code --function-name my-function-1 --zip-file fileb://my-deployment-package.zip --no-cli-pager 

else

echo "### CREATE ###"

aws lambda create-function \
    --function-name my-function-1 \
    --runtime python3.10 \
    --zip-file fileb://my-deployment-package.zip \
    --handler lambda_function.lambda_handler \
    --role arn:aws:iam::079447172711:role/lambdaRole \
    --output table \
    --timeout 30 \
    --no-cli-pager 

fi


rm ./my-deployment-package.zip