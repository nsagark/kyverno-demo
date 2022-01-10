#!/usr/bin/bash

RESOURCE_YAMLS=$(ls resources)
POLICY_YAMLS=$(ls policies)
TEMP_FILE=/tmp/temp.txt

echo -e "RESOURCE\tPOLICY\tRULE_NAME\tSTATUS\tMESSAGE" > /tmp/temp.txt

for i in $POLICY_YAMLS
do
        for j in $RESOURCE_YAMLS
        do
                kyverno apply policies/$i --resource resources/$j | grep "failed" > tempvar.txt
                line1=""
                line2=""
                line1=$(cat tempvar.txt | head -1)
                line2=$(cat tempvar.txt | tail -1)
                if [[ ! -z $line1 ]] && [[ ! -z $line2 ]]; then

                        POLICY=$(echo $line1 | awk '{print $2}')
                        RESOURCE=$(echo $line1 | awk '{print $5}')
                        STATUS=FAIL
                        RULE_NAME=$(echo $line2 | awk '{print $2}' | sed 's/://g')
                        MESSAGE=$(echo $line2 | cut -d " " -f 3-)
                        echo -e "$RESOURCE\t$POLICY\t$RULE_NAME\t$STATUS\t$MESSAGE" >> /tmp/temp.txt
                fi
        done
done

sed -i 's/\t/,/g' /tmp/temp.txt

nawk 'BEGIN{
FS=","
print  "MIME-Version: 1.0"
print  "Content-Type: text/html"
print  "Content-Disposition: inline"
print  "<HTML>""<TABLE border="1">"
}
 {
printf "<TR>"
for(i=1;i<=NF;i++)
printf "<TD>%s</TD>", $i
print "</TR>"
 }
END{
print "</TABLE></BODY></HTML>"
 }
' /tmp/temp.txt > file.html

sed -i "5s:TR:TR bgcolor=\"lightblue\":" file.html
