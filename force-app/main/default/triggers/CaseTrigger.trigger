trigger CaseTrigger on Case (before insert) {
    Case newCase = Trigger.New[0];

    if (newCase.Origin == 'Email' && Trigger.New.size() < 2) {
        String plainText = newCase.Description;

        String membership, priority, severity;

        String[] errors = new String[]{};

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