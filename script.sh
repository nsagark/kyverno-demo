#!/usr/bin/bash

RESOURCE_YAMLS=$(ls resources)
POLICY_YAMLS=$(ls policies)
TEMP_FILE=/tmp/temp.txt
OUTPUT_FILE=/tmp/output.txt
E_DISTRO=sagar@nirmata.com
#echo $RESOURCE_YAMLS
#echo $POLICY_YAMLS
rm -f /tmp/temp.txt

# Install kyverno CLI
./install-kycli.sh

printf "%-50s %-30s %-30s\n" "RESOURCE" "POLICY_YAML_FILE" "RESOURCE_YAML_FILE" > $OUTPUT_FILE
seq -s- 100|tr -d '[:digit:]' >> $OUTPUT_FILE

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

#printf "%-50s %-20s %-20s %-20s %-20s %-20s\n" "RESOURCE_NAME" "KIND" "NAMESPACE" "POLICY_YAML_FILE" "RESOURCE_YAML_FILE"

echo -e "The resources that have failed the kyverno policies are listed below along with the policy and resource YAML files.\nNOTE: The RESOURCE below has the following format: NAMESPACE/KIND/RESOURCE_NAME\n\n"

if [[ -s $TEMP_FILE ]]; then
        while read -r line
        do
                #set -x
                POLICY=$(echo $line | awk '{print $2}')
                RESOURCE=$(echo $line | awk '{ print $NF}')
                NAMESPACE=$(echo $RESOURCE | awk -F/ '{ print $1}')
                KIND=$(echo $RESOURCE | awk -F/ '{ print $2}')
                RESOURCE_NAME=$(echo $RESOURCE | awk -F/ '{ print $NF}')
                POLICY_YAML_FILE=$(grep -l $POLICY policies/*.yaml | awk -F/ '{ print $NF}')
                RESOURCE_YAML_FILE=$(grep -l $RESOURCE_NAME resources/*.yaml | awk -F/ '{ print $NF}')
                #printf "${GREEN}%-40s %-10s${NC}\n" "$3" "PASS"
                #printf "%-50s %-20s %-30s %-30s %-30s %-30s\n" "$RESOURCE_NAME" "$KIND" "$NAMESPACE" "$POLICY_YAML_FILE" "$RESOURCE_YAML_FILE"
                printf "%-50s %-30s %-30s\n" "$RESOURCE" "$POLICY_YAML_FILE" "$RESOURCE_YAML_FILE" >> $OUTPUT_FILE
        done < $TEMP_FILE
        cat $OUTPUT_FILE
        EMAIL_BODY="The resource YAML files that have failed to validate against the kyverno policies are included in the attachment. Please take appropriate actions to update the YAML files"
        mutt -s "Pipeline job has failed" -a $OUTPUT_FILE -- $E_DISTRO <<< "$EMAIL_BODY"
        echo 
        echo
        exit 1
fi
