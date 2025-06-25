# matflow-configs
Configurations for different clusters.

> [!WARNING]
> The files in this repository are not _full_ configuration files. In other words, you should not replace your MatFlow configuration file with one of these files. Instead, they are individual configurations, of which you may have many within your configuration file, corresponding to, for example, different computing clusters that are accessible from some shared network home space.

Import one of these configs, using the CLI like this (where `[FILE NAME]` is one of the YAML files in this repository):

```console
matflow config import github://hpcflow:matflow-configs@main/[FILE NAME]
```

Or use the Python API like this:

```python
import matflow as mf

mf.config.import_from_file("github://hpcflow:matflow-configs@main/[FILE NAME]")
```

> [!NOTE]
> You can also specify the config invocation name you wish to update if you have multiple invocations defined in your config file.

> [!NOTE]
> You can also pass a local file path to the `config import` / `mf.config.import_from_file` command.

> [!NOTE]
> If you want to use a different branch (other than `main`), you must not use slashes in the branch name, because `fsspec` will not correctly interpret the file location. 
