# build-and-push-ecr.ps1
# Builds the three MERN images and pushes them to Amazon ECR.
# Prereqs: aws configure done, Docker running.
#
# Usage:
#   .\build-and-push-ecr.ps1 -AccountId 123456789012 -Region ap-south-1 -Tag latest

param(
    [Parameter(Mandatory=$true)][string]$AccountId,
    [string]$Region = "ap-south-1",
    [string]$Tag = "latest"
)

$ErrorActionPreference = "Stop"
$registry = "$AccountId.dkr.ecr.$Region.amazonaws.com"
$repos = @("mern-hello", "mern-profile", "mern-frontend")
$contexts = @{
    "mern-hello"    = "./backend/helloService"
    "mern-profile"  = "./backend/profileService"
    "mern-frontend" = "./frontend"
}

Write-Host "==> Creating ECR repositories (ignore 'already exists')..." -ForegroundColor Cyan
foreach ($r in $repos) {
    aws ecr create-repository --repository-name $r --region $Region 2>$null | Out-Null
}

Write-Host "==> Logging Docker in to ECR..." -ForegroundColor Cyan
aws ecr get-login-password --region $Region | docker login --username AWS --password-stdin $registry

foreach ($r in $repos) {
    $img = "$registry/${r}:$Tag"
    Write-Host "==> Building and pushing $img" -ForegroundColor Green
    docker build -t $img $contexts[$r]
    docker push $img
}

Write-Host "==> Done. Images in ECR:" -ForegroundColor Cyan
foreach ($r in $repos) { aws ecr describe-images --repository-name $r --region $Region --query 'imageDetails[].imageTags' 2>$null }
