# Notion Setup for Tidy

## Connect Notion to Claude Code

1. Go to https://www.notion.so/profile/integrations
2. Click **New integration** → name it "Tidy Dev"
3. Copy the **Internal Integration Token**
4. Run in terminal:
   ```bash
   claude mcp add notion -- npx -y @notionhq/notion-mcp-server
   ```
5. When prompted for environment variables, set:
   ```
   OPENAPI_MCP_HEADERS={"Authorization": "Bearer <your-token>", "Notion-Version": "2022-06-28"}
   ```

## Notion Workspace Structure (recommended)

```
Tidy/
├── 📋 Changelog          ← auto-updated on each code change
├── 🏗 Architecture       ← design decisions
├── 🐛 Bug Tracker        ← issues and fixes
├── 🗺 Roadmap            ← features and milestones
└── 📖 Dev Log            ← session notes
```

## Auto-documentation hook

Once Notion MCP is connected, add this to `.claude/settings.json` hooks
to auto-log every significant change to the Notion Changelog page.
