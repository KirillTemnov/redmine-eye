# Teams

Team is a set of redmine users, grouped by any way you like.

For team you can do actions

- add member
- remove member
- show members

Adding first member to team will create it. Removing last member to the team will remove it.

```bash
ry team [TEAM-NAME] list
ry team [TEAM-NAME] add [ID(s)]
ry team [TEAM-NAME] del [ID(s)]
```

May add several id values. Comma separated, no spaces. E.g.: `1,2,3,4`.

### NOTE

- Teams data will be storen in config

- If you call library functions with teams, don't forget add teams to config!



## Use teams

### List all teams

```bash
ry teams
```

### Create new team

Add members to team for create it.
Team members are comma separated ids **without space**

```bash
ry team NAME add 3
ry team NAME add 6,7
```

### List team members

```bash
ry team NAME list
```

### Remove team member

```bash
ry team NAME del 3,7
```

After remove last team member, team will be erased.
