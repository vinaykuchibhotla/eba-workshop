# Starting the DMS Migration Task

## Current Status

Your CloudFormation stack has successfully deployed all the necessary DMS infrastructure components. The DMS replication instance is running, both source and target endpoints have been configured, and the migration task itself has been created. Everything is in place and ready to go. However, the migration task is currently sitting in a "Ready" state and hasn't started moving any data yet. This is by design - AWS DMS creates the task but waits for you to manually trigger it before beginning the actual migration process.

---

## Task Objective

You need to start the DMS migration task so it can begin moving your OrchardLite CMS database from the RDS MySQL instance to the new Aurora Serverless cluster. Once started, the task will first perform a full load of all existing data, copying every table and row from source to target. After that initial load completes, it will switch into Change Data Capture mode, continuously monitoring the source database and replicating any new changes in near real-time. By the end of this process, you'll have a complete copy of your database in Aurora with ongoing synchronization keeping both databases in sync.

---

## Steps for Manual Intervention

You'll need to log into the AWS DMS Console and manually start the migration task. Before clicking start, it's a good idea to test the connections to both your source and target databases to make sure everything can communicate properly. Once you start the task, you'll want to monitor its progress through the console, watching as it loads each table and eventually transitions to continuous replication mode. The whole process should take just a few minutes of your time to initiate, though the actual data migration will take anywhere from 5 to 30 minutes depending on how much data you're moving.

---

## Step 1: Verify Stack Deployment

1. Open the **AWS CloudFormation Console**
2. Locate the stack: `db-dms-setup-eba` (or your custom stack name)
3. Verify the stack status shows **CREATE_COMPLETE** or **UPDATE_COMPLETE**
4. Check the **Outputs** tab to confirm:
   - `DMSReplicationInstanceArn` is present
   - `DMSMigrationTaskArn` is present
   - `MigrationStatus` shows: "READY - Task created but not started"

---

## Step 2: Navigate to DMS Console

1. Open the **AWS DMS Console**: https://console.aws.amazon.com/dms/
2. Ensure you're in the correct AWS region (e.g., `us-east-1`)
3. From the left navigation menu, click **Database migration tasks**

---

## Step 3: Locate Your Migration Task

1. In the migration tasks list, find: **`orchardlite-migration-task`**
2. Check the task status - it should show **"Ready"** or **"Stopped"**
3. Click on the task name to view details

---

## Step 4: Verify Task Configuration (Optional but Recommended)

Before starting, review the task configuration:

1. **Migration type**: Should be `full-load-and-cdc` (full load + ongoing replication)
2. **Source endpoint**: `orchardlite-source-rds-endpoint`
3. **Target endpoint**: `orchardlite-target-aurora-endpoint`
4. **Table mappings**: Should include all tables from `OrchardLiteDB` schema

---

## Step 5: Test Endpoint Connections (Recommended)

1. From the task details page, scroll to **Endpoints**
2. Click **Test connection** for both source and target endpoints
3. Wait for both tests to show **"successful"** status
4. If either test fails, troubleshoot connectivity before proceeding

**Common issues:**
- Security group rules not allowing DMS access
- Incorrect database credentials
- Database not in "Available" state

---

## Step 6: Start the Migration Task

1. From the task details page, click the **"Start/Resume"** button (top right)
2. In the confirmation dialog, select start type:
   - **Start**: Begins the migration from scratch
   - **Resume**: Continues from where it left off (if previously stopped)
   - **Reload target**: Drops and recreates target tables
3. For first-time migration, select **"Start"**
4. Click **"Start task"** to confirm

---

## Step 7: Monitor Migration Progress

Once started, the task will go through these phases:

### Phase 1: Full Load
- Status: **"Load complete"** or **"Running"**
- Duration: Varies based on database size (typically 5-30 minutes for small databases)
- Monitor the **Table statistics** tab to see progress per table

### Phase 2: Change Data Capture (CDC)
- Status: **"Running"**
- The task continuously replicates ongoing changes
- Check **CDC latency** - should be under 10 seconds for healthy replication

### Key Metrics to Watch:
- **Full load progress**: Percentage of tables loaded
- **CDC latency**: Time lag between source and target
- **Errors**: Should remain at 0

---

## Step 8: Verify Migration Success

1. Check **Table statistics** tab:
   - All tables show **"Table completed"** status
   - Row counts match between source and target
   
2. Review **CloudWatch logs** (optional):
   - Click **View CloudWatch logs** to see detailed migration logs
   - Look for any warnings or errors

3. Validate data in target database:
   - Connect to Aurora Serverless database
   - Run sample queries to verify data integrity

---

## Troubleshooting

### Task Fails to Start
- **Check replication instance status**: Must be "Available"
- **Verify endpoint connections**: Both must test successfully
- **Review IAM permissions**: DMS service role must have proper permissions

### Migration Errors During Full Load
- Check **Table statistics** for specific table errors
- Review CloudWatch logs for detailed error messages
- Common issues: Data type mismatches, constraint violations

### High CDC Latency
- Source database may have high transaction volume
- Consider increasing replication instance size
- Check network connectivity between DMS and databases

### Task Stops Unexpectedly
- Review CloudWatch logs for error details
- Check source database availability
- Verify target database has sufficient storage

---

## Post-Migration Steps

Once the full load completes and CDC is running smoothly:

1. **Monitor CDC for 15-30 minutes** to ensure ongoing replication is stable
2. **Validate critical data** in the target database
3. **Plan application cutover** when ready to switch to Aurora
4. **Stop the task** when migration is complete (if not doing continuous replication)

---

## Quick Reference: Console Navigation

```
AWS Console → DMS → Database migration tasks → orchardlite-migration-task → Start/Resume
```

---

## Additional Resources

- [AWS DMS User Guide](https://docs.aws.amazon.com/dms/latest/userguide/)
- [Monitoring DMS Tasks](https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Monitoring.html)
- [Troubleshooting DMS](https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Troubleshooting.html)

---

## Summary

Starting the DMS migration task is straightforward:

1. ✅ Verify CloudFormation stack is complete
2. ✅ Navigate to DMS Console → Database migration tasks
3. ✅ Find `orchardlite-migration-task`
4. ✅ Test endpoint connections (recommended)
5. ✅ Click **Start/Resume** → Select **Start** → Confirm
6. ✅ Monitor progress in Table statistics tab
7. ✅ Verify data after full load completes

**Estimated Time**: 2-3 minutes to start + 5-30 minutes for full load (depending on database size)
