/*
Map<Id, EmailToCaseKnowledgeBase__mdt> fieldsMetadata = new Map<Id, EmailToCaseKnowledgeBase__mdt>([SELECT Id, MasterLabel, FieldTokenName__c FROM EmailToCaseKnowledgeBase__mdt]);
for (EmailToCaseKnowledgeBase__mdt fieldMetadata:fieldsMetadata.values()) {
    String token = fieldMetadata.FieldTokenName__c;
    String variation = 
}

Integer nFieldsFound = (Integer) Collection.of(fieldsMetadata)
                                        .filter(EmailToCaseKnowledgeBase__mdt.FieldTokenName__c).contains('Severity')
                                        .filter(EmailToCaseKnowledgeBase__mdt.MasterLabel).equals('sev')
                                        .listOf(EmailToCaseKnowledgeBase__mdt.MasterLabel).size();
*/
    private List<String> getValuesFromPicklist(SObjectField field){
        List<Schema.PicklistEntry> fieldOptions = field.getDescribe().getPicklistValues();
        List<String> options = new List<String>();
        for (Schema.PicklistEntry opt : fieldOptions) {
            options.add(opt.getValue()); // Turns it into String
        }
        return options;
    }
    
    private String isA(List<EmailToCaseKnowledgeBase__mdt> fieldsMetadata, List<String> fieldTokens, String value){
        List<String> nFieldsFound = (List<String>) Collection.of(fieldsMetadata)
                                        .filter(EmailToCaseKnowledgeBase__mdt.FieldTokenName__c).isIn(fieldTokens)
                                        .filter(EmailToCaseKnowledgeBase__mdt.MasterLabel).equals(value)
                                        .listOf(EmailToCaseKnowledgeBase__mdt.FieldTokenName__c);
        System.debug('AAAAAAAAAAAAAAAAAAAAAA: '+nFieldsFound);
        return nFieldsFound.size() > 0 ? nFieldsFound[0]:'';
    }

List<EmailToCaseKnowledgeBase__mdt> fieldsMetadata = new List<EmailToCaseKnowledgeBase__mdt>([SELECT Id, MasterLabel, FieldTokenName__c FROM EmailToCaseKnowledgeBase__mdt]);
List<String> e =  new List<String>{'Severity','Membership','Priority'};
List<String> optsMembership = getValuesFromPicklist(Case.Membership__c);
System.debug('AAAAAAAAAAAAAAAAAAAAAA: '+isA(fieldsMetadata,optsMembership,'gol'));