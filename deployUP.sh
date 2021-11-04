#!/bin/bash

FR_namespace="$1"
TO_namespace="$2"

edpkcli=`kubectl get endpoints -n$FR_namespace |awk '{print $(NF-2)}' |grep crm`

for i in `echo $edpkcli`
do
    dpys_kcli=`kubectl get deploy -n$TO_namespace |awk '{print $(NF-4)}' |grep $i`
    cnts_kcli=`echo "$dpys_kcli" |awk -F 'deployment' '{print $(NF-1)}'`
    
    Image_fr=`kubectl get pod -n$FR_namespace -o jsonpath="{..image}" |tr -s '[[:space:]]' '\n' |sort |uniq -c |awk '{print $(NF)}' |grep $i`
    echo "$Image_fr" |awk -F ':' '{print $NF}' > Image_fr
    Image_to=`kubectl get pod -n$TO_namespace -o jsonpath="{..image}" |tr -s '[[:space:]]' '\n' |sort |uniq -c |awk '{print $(NF)}' |grep $i`
    echo "$Image_tg" |awk -F ':' '{print $NF}' > Image_to
    
    if [ -z `diff Image_fr Image_to` ]
    then
        echo "Code Images identical !!!"
    else
        echo "Code Images SYNC !!!"
        echo "------------ $i sync start ---"
        echo "kubectl set image deployment/$dpys_kcli ${cnts_kcli}container=$Image_fr --record --namespace=$TO_namespace"
        kubectl set image deployment/$dpys_kcli ${cnts_kcli}container=$Image_fr --record --namespace=$TO_namespace
        if [ $? -ne 0 ]
        then
            echo "............. $i sync failed ..."
            exit 1
        else
            echo "============= $i sync complete ==="
        fi
    fi
done