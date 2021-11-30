/* 
    Last Edited by Miguel López ~ 29/11/21
*/
public class CaseTriggerHandler extends TriggerHandler {
    private List<Case> newCaseMap;

    public CaseTriggerHandler() {
        this.newCaseMap = Trigger.New;
    }

    public override void beforeInsert(){
        maxOpenCases();
        uniqueSeverity();
        receiveEmailToCase();
    }

    private void maxOpenCases(){
        List<Case> ncase = newCaseMap;
        for(Case cs: ncase){
            Integer openCases = [SELECT COUNT() FROM CASE WHERE AccountId = :cs.AccountId AND Status <> 'Closed'];
            if(openCases>=5){
                cs.addError('You have reached the maximum number of open cases (5 cases)');
            }
        }
    }

    private void uniqueSeverity(){
        Case firstCase = newCaseMap[0];
        
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
        Case newCase = newCaseMap[0];
        if (newCase.Origin == 'Email' && Trigger.New.size() < 2) {
            String plainText = newCase.Description;
            
            String membership, priority, severity;

            List<String> opts_Severity = getValuesFromPicklist(Case.Severity__c);
            List<String> opts_Membership = getValuesFromPicklist(Case.Membership__c);
            List<String> opts_Priority = getValuesFromPicklist(Case.Priority);

            try {
                // Extract data from the Plain Text Email Body
                // which are their own entities, and are not getting their values from the email body   
                // here is how you might get it from the body content, as you seem to be trying to do
                if(plainText != Null && plainText != ''){
                    String[] emailBodyRows = plainText.split('\n');
                    for (String bodyRow:emailBodyRows) {
                        String[] rowContents = bodyRow.split(':');
                        String label = rowContents[0].trim().toLowerCase();
                        String value = rowContents[1].trim();
                        switch on label {
                            // TODO Create Exceptions & Reply with an Email to SuppliedEmail
                            when 'priority' {
                                //Validate that priority is one of the following values: High, Medium, Low
                                if (opts_Priority.contains(value)) {
                                    newCase.Priority = value;
                                }else {
                                    // Create exception with CODE: Priority
                                    throw new EmailFormatException('CODE: Priority');
                                }
                            }
                            when 'severity' {
                                //Validate that priority is between 1-5
                                if (opts_Severity.contains(value)) {
                                    newCase.Severity__c = value;
                                }else {
                                    // Create exception with CODE: Severity
                                    throw new EmailFormatException('CODE: Severity');
                                }
                            }
                            when 'membership' {
                                //Validate that priority is one of the following values: Vip, Gold, Silver
                                if (opts_Membership.contains(value)) {
                                    newCase.Membership__c = value;
                                }else {
                                    // Create exception with CODE: Membership
                                    throw new EmailFormatException('CODE: Membership');
                                }
                            }
                        }
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
        List<Schema.PicklistEntry> field_Options = field.getDescribe().getPicklistValues();
        List<String> options = new List<String>();
        for (Schema.PicklistEntry opt : field_Options) {
            options.add(opt.getValue()); // Turns it into String
        }
        return options;
    }
}