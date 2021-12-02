/*
String pepegui = [SELECT Id, CaseNumber, SourceId FROM Case WHERE CaseNumber = '00001145' LIMIT 1].SourceId;
String li = [SELECT Id, ParentId, ToAddress, FromAddress  FROM EmailMessage WHERE Id = :pepegui LIMIT 1].ToAddress;

Id li = [SELECT Id, ParentId, ToAddress, FromAddress  FROM EmailMessage WHERE Id = '02s21000002a4nTAAQ' LIMIT 1].Id;
Case pepegui = [SELECT FIELDS(ALL) FROM Case LIMIT 1];
System.debug(pepegui);

// getValuesFromPicklist
public List<String> getValuesFromPicklist(SObjectField field){
    List<Schema.PicklistEntry> field_Options = field.getDescribe().getPicklistValues();
    List<String> temp = new List<String>();
    for (Schema.PicklistEntry s : field_Options) {
        temp.add(s.getValue());
    }
    return temp;
}


List<String> test = getValuesFromPicklist(Case.Severity__c);

System.debug(test.contains('1'));
*/
