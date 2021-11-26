@isTest
private class CaseTriggerTest { 
	public static testMethod void testEmailToCaseRandom(){
    	// GET USER FROM USER TABLE...
        User u = [select name, Id  FROM user LIMIT 1];
        
    	// RUN AS USER...
    	System.runAs(u)
	    {
			// Picklist values
			// Could be improved by getting the actual values in case they change in the future
			String[] mem_opts = new String[]{'Silver','Gold','Vip'};
			String[] pri_opts = new String[]{'High','Medium','Low'};

			// In case of having multiple Routing Addresses...
			// Addapt this values/logic to send email to every single address
			// String[] msg_Email = [SELECT Id,AuthorizedSenders,EmailDomainName,IsActive,LocalPart FROM EmailServicesAddress]
			String mem_rnd = mem_opts[String.valueOf((Math.random() * mem_opts.size()))];
			String prio_rnd = pri_opts[String.valueOf((Math.random() * pri_opts.size()))];
            String sev_rnd = String.valueOf((Math.random() * 5)+1); // Severity goes from 1-6

			String msg_Email = 'fito18_97@0-2wuzruxmb2rd5a9stxswxoh9t0u5qqfrvl6l0x6d4ihgds3y8c.21-lvjaeag.cs26.case.sandbox.salesforce.com';
			String msg_Subject = 'Basic Test'+String.valueOf((Math.random() * 9999));
			String msg_Content = 'Priority: '+prio_rnd+'\nSeverity:'+sev_rnd+'\nMembership:'+mem_rnd;

			// Rewrite sendMail() so it is called Asynchronously so...
			// only once it is sent, you can then verify if the case was created
			EmailManager em = new EmailManager();
            em.sendMail(msg_Email, msg_Subject, msg_Content);
		    // TEST ADDING EMAIL-TO-CASE...
	        System.debug('----->>> EMAIL SENT TO : ' + msg_Email);
	        
	        // READ CASE...
	    	Case a = [SELECT Id, Priority, Severity, Membership, SuppliedEmail FROM Case WHERE name = :msg_Subject LIMIT 1];
	        System.debug('----->>> END READING CASE: ' + a);
	    }
	    system.debug('----->>> RUNNING AS USER: ' + u.name);

   }        
        
}