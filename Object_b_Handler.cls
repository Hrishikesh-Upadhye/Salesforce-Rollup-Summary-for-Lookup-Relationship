public class Object_B_Handler
{
   /*****************************************************************************
    Name - updateObject_ARollups
    Description - Method created to Rollup the Amount values on Object_A Level, 
    this will help as indicator on Object_A to decide on Issued Amount to the investor
	Object
	Input Parameters - Trigger.New, Trigger.NewMap,Trigger.old, Trigger.oldmap
    Return - void
    ******************************************************************************/
    public static void updateObject_ARollups(List<Object_B> newList,map<Id,Object_B> newMap,List<Object_B> oldList,map<Id,Object_B> oldMap){
        //Set of Con Ids to be Updated
        Set<Id> setConIds = new Set<Id>();

        //Put the exception code to try - catch exceptions
        try{
            // Iterate through new Object_B records to get the Object_A id list
            if(newList!=null){
                for(Object_B bRec : newList){
                    if(Trigger.isInsert){
                        // COnsider all the Object_B records which are inserted with Object_A populated, valid Amount value 
                        // and valid Stage Values
                        if(bRec.Object_A__c!=null && bRec.Transaction_Amount__c!=null ){
                            setConIds.add(bRec.Object_A__c);
                        }
                    }
                    else if(Trigger.isUpdate){
                        //First validation to check if Object_A is changed, if not changed, do not enter
                        if(oldMap.get(bRec.Id).Object_A__c!=bRec.Object_A__c){
                            // If Object_A values are present, then only add to the set
                            if(oldMap.get(bRec.Id).Object_A__c!=null)
                                setConIds.add(oldMap.get(bRec.Id).Object_A__c);
                            if(bRec.Object_A__c!=null)
                                setConIds.add(bRec.Object_A__c);
                        }
                        // Second validation is if Transaction_Status or Transaction Amount is changing on the Object_B, Enter in the if.
                        else if(oldMap.get(bRec.Id).Transaction_Amount__c!=bRec.Transaction_Amount__c ){
                            //Add the Object_A record lookupId from the Object_B
                            setConIds.add(bRec.Object_A__c);
                        }
                    }
                }
            }

            //Iterate through the old Object_B records to get the Object_A id List.
            if(Trigger.isDelete && oldList!=null){
                for(Object_B bRec : oldList){
                    if(bRec.Object_A__c!=null)
                        setConIds.add(bRec.Object_A__c);
                }
            }

            //Variable to hold the temporary sum of Object_B Transaction Amount in the map with Object_A Id as Key
            map<Id,Decimal> mapObject_A_Vs_Amount = new map<Id,Decimal>();
            //Variable to hold the Object_A records to be updated
            List<Object_A> updateList = new List<Object_A>();
            //Query through the Oxpportunities and prepare the sum of amount and Object_A to be updated map
            if(setConIds!=null && setConIds.size()>0){
                for(AggregateResult aggRec : [Select SUM(Transaction_Amount__c) sum,Object_A__c
                                         FROM Object_B WHERE Object_A__c IN :setConIds
                                         AND Transaction_Amount__c!=null GROUP BY Object_A__c]){
                    
                        System.debug('--Object_A__c--'+aggRec.get('Object_A__c'));
                        System.debug('--Amount--'+aggRec.get('sum'));
                        // Prepare the Map for Object_A Id and amount to be updated
                        mapObject_A_Vs_Amount.put(String.valueOf(aggRec.get('Object_A__c')),(Decimal)aggRec.get('sum'));
                }
            }

            // Check if the map size is not null, then query the corresponding Object_A Records and update the Amount value
            if(mapObject_A_Vs_Amount!=null && mapObject_A_Vs_Amount.size()>0){
                for(Object_A conRec : [SELECT Id,Name, Amount_Invested_as_Primary__c
                                    FROM Object_A WHERE Id IN: mapObject_A_Vs_Amount.keyset()]){
                    // Check if the total amount from Opportunities is different from Funded Amount on Object_A, update the Object_A
                    if(mapObject_A_Vs_Amount.get(conRec.Id)!=conRec.Amount_Invested_as_Primary__c){
                        conRec.Amount_Invested_as_Primary__c = mapObject_A_Vs_Amount.get(conRec.Id);
                        // Add the Object_A to the List to update later.
                        updateList.add(conRec); 
                    }
                }
            }

            //Update the Object_A List
            if(updateList!=null && updateList.size()>0){
                update updateList;
            }
        }
        //Handle Exceptions
        catch(Exception ex){
            ErrorLogUtility.CreateLogRecs(ex,'Trigger-Object_BBefore','updateObject_ARollups');
        }
    }
    // Method End - updateObject_ARollups
   


}