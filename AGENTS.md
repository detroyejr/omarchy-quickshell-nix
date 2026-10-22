# Subagents

- When requesting substantial or parallelizable work, use subagents to reduce context in the main thread.
- Give each subagent the context and scope needed to complete its task.
- When work is done, report the results back to the main thread.
