# Devops-test


# Architecture

A python application deployed on AWS using api gateway and Lambda function.

# Why lambda function
Lambda functions are efficient whenever you want to create a function that will only contain simple expressions, expressions that are usually a single line of a statement.
Also, the size of the code with its dependecies is very small 3.4 MB which ideal for Aws lambda.

# Api developement:

I used *Request* to fetch data from *https://carbonwatch.kayrros.com/files/data.csv* which return a dataset, then lambda handler return just the latest CO2 Emission in Europe.
# Package the app in a zip file
We must package the app in a zip file beacause it easier to be deployed on Aws lambda in that format

# Terraform main.tf manifest
Terraform will use the zip file then deploy it on aws