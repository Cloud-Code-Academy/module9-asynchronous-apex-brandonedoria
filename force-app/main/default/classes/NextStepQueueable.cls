/*
 * NextStepQueueable Class Description:
 * 
 * Implement the Queueable interface to process records asynchronously.
 * This example processes up to 10 accounts at a time.
 * It removes the Next Step from the accounts and related opportunities.
 *  
 * Benefits of using Queueable methods:
 * 
 * 1. Chaining Jobs: Allows for the chaining of jobs, meaning you can add another job to the queue from a running job.
 * 2. Stateful Execution: Supports stateful execution, which allows member variables to retain their values between job invocations.
 * 3. High Concurrency: Processes large sets of data without hitting governor limits.
 * 4. Flexibility: Useful for operations that need more flexibility in execution, especially when there's a possibility of chaining or performing related async operations.
 * 5. Enhanced Integration Capabilities: Useful for making asynchronous callouts to external systems, allowing for more extended processing times.
 * 
 * For more detailed information, refer to the official Salesforce documentation: https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_queueing_jobs.htm
 * 
 * Note: The class below contains placeholders for implementing a queueable job to update accounts and opportunities.
 */

public with sharing class NextStepQueueable implements Queueable {

    private Map<Id,Account> accounts;

    public NextStepQueueable(Map<Id,Account> accounts) {
        this.accounts = accounts;
    }

    public static void enqueueJob() {
        Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id, Next_Step__c, (SELECT Id, NextStep FROM Opportunities WHERE NextStep != null) FROM Account WHERE Next_Step__c != null LIMIT 10]);

        if (!accMap.isEmpty()) {
            System.enqueueJob(new NextStepQueueable(accMap));
        }
    }

    /*
     * Update/Uncomment the template code to create a method
     * Method to execute the queueable job
     */

    public void execute (QueueableContext context) {
        List<Opportunity> oppList = new List<Opportunity>();

        for (Account acc : accounts.values()) {
            List<Opportunity> oppsOfAccounts = acc.Opportunities;
            oppList.addAll(oppsOfAccounts);
        }
        
        for (Account acc : accounts.values()) {
            removeNextStep(acc);
        }
        
        update accounts.values();

        for (Opportunity opp : oppList) {
            removeNextStep(opp);
        }
        
        update oppList;

        enqueueJob();
    }

    private static void removeNextStep(Opportunity opp) {
        opp.NextStep = null;
    }

    private static void removeNextStep(Account acc) {
        acc.Next_Step__c = null;
    }
}