#!/bin/bash
num=1
echo $num

while :    
    do
    kubectl run -it "a"$num"b" --rm --image=mcr.microsoft.com/windows/servercore:ltsc2019 --overrides='{"apiVersion":"v1","spec":{"Tolerations":[{"key":"windows", "operator":"Equal", "value":"true", "effect":"NoSchedule"}]}}' --generator=run-pod/v1 powershell.exe Resolve-DnsName www.microsoft.com >> result.txt
    #kubectl run -it "a"$num"b" --rm --image=mcr.microsoft.com/windows/servercore:ltsc2019 --overrides='{"apiVersion":"v1","spec":{"nodeSelector":{"beta.kubernetes.io/os":"windows"}}}' --generator=run-pod/v1 powershell.exe Resolve-DnsName www.microsoft.com >> result.txt
    (( num++ ))
done

kubectl run -it "a"$num"b" --rm --image=mcr.microsoft.com/windows/servercore:ltsc2019 --overrides='{"apiVersion":"v1","spec":{"Tolerations":[{"key":"windows", "operator":"Equal", "value":"true", "effect":"NoSchedule"}]}}' --generator=run-pod/v1 powershell.exe curl -s checkip.dyndns.org

kubectl run -it --rm --image=mcr.microsoft.com/windows/servercore:ltsc2019 --overrides='{"apiVersion":"v1","spec":{"Tolerations":[{"key":"windows", "operator":"Equal", "value":"true", "effect":"NoSchedule"}]}}' --generator=run-pod/v1 powershell.exe Start-Sleep 5; Resolve-DnsName www.microsoft.com