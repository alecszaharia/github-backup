### How wo run

```
./backup.sh {github username} {gituhb personal token} {target path}
```

The script will clone all found repositories with --bare and --mirror.
All cloned repositories can be imported in a new account using  the following steps:

1. Create a new repository on GitHub. You'll import your old Git repository to this new repository.
   ```ex: git@github.com:USER/NEW-REPO.git```

2. Push the locally cloned repository to GitHub using the "mirror" option, which ensures that all references, such as branches and tags, are copied to the imported repository.
```
$ cd REPO.git
$ git push --mirror git@github.com:USER/NEW-REPO.git
# Pushes the mirror to the new repository on GitHub.com
```


### Create a cron

The following crontab will run every Sunday at 3:00

```shell
0 3 * * 0 bash /full_path_to_backup_script/backup.sh {github username} {gituhb personal token} {target path}
```

