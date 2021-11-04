#!/bin/bash -l
set -ex
VCC_DEV=`kubectl get deployment -n $NM_FO |awk 'NR>1{print $1}'`
VCC_QA=`kubectl get deployment -n $NM_TO |awk 'NR>1{print $1}'`
NM_TO="default"
NM_FO="test"

rm -rf qa dev qa.pods

for i in $VCC_DEV
do
DEV=`kubectl get deployment $i -n $NM_FO -o jsonpath='{..image}' `
QA=`kubectl get deployment $i -n $NM_TO -o jsonpath='{..image}'`
echo $i
echo $DEV
echo $QA
if [ $DEV = $QA ]
then
   echo $DEV >> qa
else
   echo $QA
   TAIL_CN_DEV=`echo $i |grep deployment`
   if [ -z $TAIL_CN_DEV ]
   then
         kubectl set image deployment/$i $TAIL_CN_DEV-container=$DEV --namespace=$NM_TO
         echo $QA >> dev
         echo $i >> qa.pods
   else
         CN_DEV=`echo $TAIL_CN_DEV |head -c-12`
         kubectl set image deployment/$i $CN_DEV-container=$DEV --namespace=$NM_TO
         echo $QA >> dev
         echo $i >> qa.pods
   fi
fi
done 