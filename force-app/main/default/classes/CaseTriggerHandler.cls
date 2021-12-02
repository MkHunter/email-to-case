/* 
    Last Edited by Miguel López ~ 29/11/21
*/
public class CaseTriggerHandler extends TriggerHandler {
    private List<Case> newCaseList;

    public CaseTriggerHandler() {
        this.newCaseList = Trigger.New;
    }

    public override void beforeInsert(){
        maxOpenCases();
        uniqueSeverity();
        receiveEmailToCase();
    }

    private void maxOpenCases(){
        List<Case> ncase = newCaseList;
        for(Case cs: ncase){
            Integer openCases = [SELECT COUNT() FROM CASE WHERE AccountId = :cs.AccountId AND Status <> 'Closed'];
            if(openCases>=5){
                cs.addError('You have reached the maximum number of open cases (5 cases)');
            }
        }
    }

    private void uniqueSeverity(){
        Case firstCase = newCaseList[0];
        
        List<Case> openCases = [SELECT Id, AccountId, Severity__c FROM Case WHERE Status <> 'Closed' AND AccountID = :firstCase.AccountId];
        List<String> useSev = new List<String>();
        List<String> avSev = new List<String>();

        List<String> listOfSeverities = getValuesFromPicklist(Case.Severity__c);
        
        for(Case cs: openCases){
            useSev.add(cs.Severity__c);
        }
        for(String severity: listOfSeverities){
            if(!useSev.contains(severity)){
                avSev.add(severity);
            }
        }
        if(useSev.contains(firstCase.Severity__c)){
            if(avSev.size()>1){
                firstCase.addError('Severity already used, the severities availables are ' + avSev.toString());
            }
            else{
                firstCase.addError('You have reached the maximum number of open cases (5 cases)');
            }
        }
    }

    class EmailFormatException extends Exception{}

    private void receiveEmailToCase(){
        Case newCase = newCaseList[0];
        if (newCase.Origin == 'Email' && newCaseList.size() < 2) {
            String plainText = newCase.Description;
            
            String membership, priority, severity;

            List<String> optsSeverity = getValuesFromPicklist(Case.Severity__c);
            List<String> optsMembership = getValuesFromPicklist(Case.Membership__c);
            List<String> optsPriority = getValuesFromPicklist(Case.Priority);

            List<EmailToCaseKnowledgeBase__mdt> fieldsMetadata = new List<EmailToCaseKnowledgeBase__mdt>([SELECT Id, MasterLabel, FieldTokenName__c FROM EmailToCaseKnowledgeBase__mdt]);

            try {
                // Extract data from the Plain Text Email Body
                // which are their own entities, and are not getting their values from the email body   
                // here is how you might get it from the body content, as you seem to be trying to do
                if(plainText != Null && plainText != ''){
                    String[] emailBodyRows = plainText.split('\n');
                    for (String bodyRow:emailBodyRows) {
                        String[] rowContents = bodyRow.split(':');
                        String proposedLabel = rowContents[0].trim().toLowerCase();
                        String proposedValue = rowContents[1].trim().toLowerCase();

                        String label = findMetadataTokenOfValue(fieldsMetadata,new List<String>{'Severity','Membership','Priority'}, proposedLabel);
                        System.debug('proposedLabel : '+proposedLabel+' proposedValue'+proposedValue);
                        System.debug('LABEL : '+label);
                        // In case a label = '' then it means it wasn't found in the EmailToCaseKnowledgeBase__mdt object
                        List<String> searchListOption = new List<String>();
                        switch on label {
                            // TODO Create Exceptions & Reply with an Email to SuppliedEmail
                            when 'Priority' {
                                searchListOption = optsPriority;
                            }
                            when 'Severity' {
                                searchListOption = optsSeverity;
                            }
                            when 'Membership' {
                                searchListOption = optsMembership;
                            }
                        }
                        System.debug('ListOption: '+searchListOption);
                        String value = findMetadataTokenOfValue(fieldsMetadata,searchListOption, proposedValue);
                        // In case a value = '' then it means it wasn't found in the EmailToCaseKnowledgeBase__mdt object
                        System.debug('VALUE: '+value);
                        newCase.Membership__c = value;
                    }
                    // Insert the new Case
                    System.debug('NEW CASE: '+newCase);
                    insert newCase;
                }
                System.debug('New Case Object: ' + newCase );
            }
            // If an exception occurs when the query accesses 
            // the contact record, a QueryException is called.
            // The exception is written to the Apex debug log.
            catch (Exception e) {
                System.debug('Format Issue: ' + e);
                // TODO Reply to the email when...
                // a. Empty Priority, Severity or Membership
                // b. Not supported values for Priority, Severity or Membership
                // c. Not the correct format of email
            }
        }
    }

    private List<String> getValuesFromPicklist(SObjectField field){
        List<Schema.PicklistEntry> fieldOptions = field.getDescribe().getPicklistValues();
        List<String> options = new List<String>();
        for (Schema.PicklistEntry opt : fieldOptions) {
            options.add(opt.getValue()); // Turns it into String
        }
        return options;
    }

    private String findMetadataTokenOfValue(List<EmailToCaseKnowledgeBase__mdt> fieldsMetadata, List<String> fieldTokens, String proposedString){
        List<String> nFieldsFound = (List<String>) Collection.of(fieldsMetadata)
                                        .filter(EmailToCaseKnowledgeBase__mdt.FieldTokenName__c).isIn(fieldTokens)
                                        .filter(EmailToCaseKnowledgeBase__mdt.MasterLabel).equals(proposedString)
                                        .listOf(EmailToCaseKnowledgeBase__mdt.FieldTokenName__c);
        System.debug('AAAAAAAAAAAAAAAAAAAAAA: '+nFieldsFound);
        return nFieldsFound.size() > 0 ? nFieldsFound[0]:'';
    }
}