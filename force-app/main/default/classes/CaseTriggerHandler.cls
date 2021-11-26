/* 
    Last Edited by Miguel López ~ 25/11/21
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
        if(useSev.contains(firstCase.Severity__c)){
            if(avSev.size()>1){
                firstCase.addError('Severity already used, the severities availables are ' + avSev.toString());
            }
            else{
                firstCase.addError('You have reached the maximum number of open cases (5 cases)');
            }
        }
    }

    private void receiveEmailToCase(){
        Case newCase = newCaseMap[0];
        if (newCase.Origin == 'Email' && Trigger.New.size() < 2) {
            String plainText = newCase.Description;

            String membership, priority, severity;

            try {
                // Extract data from the Plain Text Email Body
                // which are their own entities, and are not getting their values from the email body   
                // here is how you might get it from the body content, as you seem to be trying to do
                if(plainText != Null && plainText != ''){
                    String[] emailBodyRows = plainText.split('\n');
                    for (String bodyRow:emailBodyRows) {
                        String[] rowContents = bodyRow.split(':');
                        String label = rowContents[0].trim();
                        String value = rowContents[1].trim();
                        switch on label {
                            // TODO Validations
                            when 'Priority' {
                                //Validate that priority is one of the following values: High, Medium, Low
                                newCase.Priority = value;
                            }
                            when 'Severity' {
                                //Validate that priority is between 1-5
                                newCase.Severity__c = value;
                            }
                            when 'Membership' {
                                //Validate that priority is one of the following values: Vip, Gold, Silver
                                newCase.Membership__c = value;
                            }
                        }
                    }
                    // Insert the new Case
                    System.debug(newCase);
                    insert newCase;
                }
                System.debug('New Case Object: ' + newCase );
            }
            // If an exception occurs when the query accesses 
            // the contact record, a QueryException is called.
            // The exception is written to the Apex debug log.
            catch (Exception e) {
                System.debug('Query Issue: ' + e);
                // TODO Reply to the email when...
                // a. Empty Priority, Severity or Membership
                // b. Not supported values for Priority, Severity or Membership
                // c. Not the correct format of email
            }
        }
    }
}