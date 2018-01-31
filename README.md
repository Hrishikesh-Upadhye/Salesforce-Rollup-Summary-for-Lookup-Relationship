# Salesforce-Rollup-Summary-for-Lookup-Relationship
<b>To Create Rollup Summary Field Through The Trigger In Lookup Relationship.</b>

Rollup summary fields are entirely normal necessity in force.com customizations and application development. 
Rollups can be created easily on Master-Detail relationship as it is available as field type.
But there are certain limitations so that we need to write Apex code for rolling up the child information for common purposes like SUM, COUNT, AVG, MAX/MIN etc.

Some of the limitations are:

<ul><li>Just 10 rollup summary fields permitted per object on Master-Detail relationships.</li>

<li>Rollup child sobject records some portion of a lookup relationship.</li> 

<li>Native rollup summary fields are not accessible on LOOKUP relationships.</li></ul>

In this approach we are using Apex code to rolling up the child information and SUM into parent field.

<b>Parent Object: Object_A__c</b>

<b>Parent Field: Amount_Invested_as_Primary__c</b>

<b>Child Object: Object_B__c</b>

<b>Child Field: Transaction_Amount__c</b>

Here, we are rolling up all values of Transaction_Amount__c from Child object i.e. Object_B__c and SUM up to Amount_Invested_as_Primary__c which is the field present on Object_A__c.
