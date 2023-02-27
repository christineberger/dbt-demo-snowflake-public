# Method and Testing

This method uses the post_hook feature to delete records from snapshots. 
The deletion date is assigned in a project variable, which makes it 
less likely to change unless done explicitly.

Testing:
1. Run `dbt run -s dummy_snapshot_deletion_source` - because this example
   is about deletion, we are manually creating a dummy snapshot.