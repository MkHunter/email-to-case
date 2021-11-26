trigger uniqueSeverity on Case (before insert) {
    List<Case> openCases = [SELECT Id, AccountId, Severity__c FROM Case WHERE Status <> 'Closed' AND AccountID = :Trigger.new[0].AccountId];
    List<String> useSev = new List<String>();
    List<String> avSev = new List<String>();
    Schema.DescribeFieldResult objSeverities = Case.Severity__c.getDescribe();
    List<Schema.PicklistEntry> listOfSeverities = objSeverities.getPicklistValues();

    for(Case cs: openCases){
        useSev.add(cs.Severity__c);
    }
    for(Schema.PicklistEntry severity: listOfSeverities){
        if(!useSev.contains(severity.value)){
            avSev.add(severity.value);
        }
    }
    /*for(Integer i=1; i<6;i++){
        if(!useSev.contains(String.valueOf(i))){
            avSev.add(String.valueOf(i));
        }
    }*/
    if(useSev.contains(Trigger.new[0].Severity__c)){
        if(avSev.size()>1){
            Trigger.new[0].addError('Severity already used, the severities availables are ' + avSev.toString());
        }
        else{
            Trigger.new[0].addError('You have reached the maximum number of open cases (5 cases)');
        }
    }
}