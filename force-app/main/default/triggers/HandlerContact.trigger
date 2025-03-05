trigger HandlerContact on Contact (before  insert,before update,after insert,after update,after undelete,after delete) {

    switch on Trigger.operationtype{
        when before_insert{
            ContactHandler.ValidationRule(trigger.new);
        }
        when before_update{
            ContactHandler.ValidationRule(trigger.new);
        }
        when After_insert{
            ContactHandler.AccountUpdate(trigger.new,null);
        }
        when After_update{
             ContactHandler.AccountUpdate(trigger.new,trigger.oldMap);
        }
         when After_delete{
             ContactHandler.AccountUpdate(trigger.old,null);
        }
          when After_undelete{
             ContactHandler.AccountUpdate(trigger.new,null);
        }
    }
}