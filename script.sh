#!/usr/bin/bash

RESOURCE_YAMLS=$(ls resources)
POLICY_YAMLS=$(ls policies)
TEMP_FILE=/tmp/temp.txt
#echo $RESOURCE_YAMLS
#echo $POLICY_YAMLS
rm -f /tmp/temp.txt

for i in $POLICY_YAMLS
do
        for j in $RESOURCE_YAMLS
        do
#               echo -e "Running $i against $j"
                kyverno apply policies/$i --resource resources/$j | grep "failed:" | sed 's/failed://g' >> $TEMP_FILE
        done
done

echo
echo

printf "%-50s %-20s %-30s %-30s %-30s %-30s\n" "RESOURCE_NAME" "KIND" "NAMESPACE" "POLICY_YAML_FILE" "RESOURCE_YAML_FILE"
seq -s- 150|tr -d '[:digit:]'

if [[ -s $TEMP_FILE ]]; then
        while read -r line
        do
                POLICY=$(echo $line | awk '{print $2}')
                RESOURCE=$(echo $line | awk '{ print $NF}')
                NAMESPACE=$(echo $RESOURCE | awk -F/ '{ print $1}')
                KIND=$(echo $RESOURCE | awk -F/ '{ print $2}')
                RESOURCE_NAME=$(echo $RESOURCE | awk -F/ '{ print $NF}')
                POLICY_YAML_FILE=$(grep -l $POLICY policies/*.yaml | awk -F/ '{ print $NF}')
                RESOURCE_YAML_FILE=$(grep -l $RESOURCE_NAME resources/*.yaml | awk -F/ '{ print $NF}')
                #printf "${GREEN}%-40s %-10s${NC}\n" "$3" "PASS"
                printf "%-50s %-20s %-30s %-30s %-30s %-30s\n" "$RESOURCE_NAME" "$KIND" "$NAMESPACE" "$POLICY_YAML_FILE" "$RESOURCE_YAML_FILE"
                #echo -e "$POLICY\t$NAMESPACE\t$KIND\t$RESOURCE_NAME\t$POLICY_YAML_FILE\t$RESOURCE_YAML_FILE"
        done < $TEMP_FILE
fi

echo
echo
