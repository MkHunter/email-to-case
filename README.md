# Installation

# Fill the playground with testing data & users
```
sfdx force:apex:execute -f scripts/apex/testData.apex

sfdx force:apex:execute -f scripts/soql/query.soql

sfdx force:apex:log:tail --color | grep USER_DEBUG 
```