trigger TriggerOnObject_B on Object_B__c (after insert,after update,before delete) {
  Object_B_Handler.updateObject_ARollups(Trigger.New, Trigger.NewMap,Trigger.old, Trigger.oldmap);
}