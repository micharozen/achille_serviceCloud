public virtual class TriggerHandler {
    private boolean triggerIsExecuting;
    private integer triggerSize;
    
    public TriggerHandler() {
        this.triggerIsExecuting = Trigger.isExecuting;
        this.triggerSize = Trigger.size;
    }
    
    public virtual void beforeInsert(List<SObject> newList) {}
    public virtual void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {}
    public virtual void beforeDelete(List<SObject> oldList) {}
    public virtual void afterInsert(List<SObject> newList) {}
    public virtual void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {}
    public virtual void afterDelete(List<SObject> oldList) {}
    public virtual void afterUndelete(List<SObject> newList) {}
    
    public void run() {
        if(triggerIsExecuting) {
            if(Trigger.isBefore) {
                if(Trigger.isInsert) beforeInsert(Trigger.new);
                if(Trigger.isUpdate) beforeUpdate(Trigger.new, Trigger.oldMap);
                if(Trigger.isDelete) beforeDelete(Trigger.old);
            }
            if(Trigger.isAfter) {
                if(Trigger.isInsert) afterInsert(Trigger.new);
                if(Trigger.isUpdate) afterUpdate(Trigger.new, Trigger.oldMap);
                if(Trigger.isDelete) afterDelete(Trigger.old);
                if(Trigger.isUndelete) afterUndelete(Trigger.new);
            }
        }
    }
} 